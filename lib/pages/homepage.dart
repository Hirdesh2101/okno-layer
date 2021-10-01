import 'dart:async';
import 'package:flutter/material.dart';
import 'package:oknoapp/pages/creator_section.dart';
import 'package:oknoapp/pages/mylikedvideos.dart';
import 'package:oknoapp/pages/profile_page.dart';
import 'package:oknoapp/providers/likedvideoprovider.dart';
import '../providers/myvideosprovider.dart';
import 'scrollfeed.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get_it/get_it.dart';
import '../providers/feedviewprovider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/dynamic_link.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home_page';
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final locator = GetIt.instance;
  final feedViewModel = GetIt.instance<FeedViewModel>();
  final DynamicLinkService _dynamicLinkService = DynamicLinkService();
  Timer? _timerLink;

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _timerLink = Timer(
        const Duration(milliseconds: 1000),
        () {
          _dynamicLinkService.retrieveDynamicLink(context);
        },
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    if (_timerLink != null) {
      _timerLink!.cancel();
    }
    super.dispose();
  }

//   final snackBar = SnackBar(
//   backgroundColor: Colors.transparent,
//   elevation: 0,
//   content: Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: Colors.greenAccent,
//         border: Border.all(color: Colors.green, width: 3),
//         boxShadow: const [
//           BoxShadow(
//             color: Color(0x19000000),
//             spreadRadius: 2.0,
//             blurRadius: 8.0,
//             offset: Offset(2, 4),
//           )
//         ],
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Row(
//         children: const [
//           Icon(Icons.error_outline, color: Colors.red ),
//           Padding(
//             padding: EdgeInsets.only(left: 8.0),
//             child: Text('Yay! A SnackBar!\nYou did great!', style: TextStyle(color: Colors.green)),
//           ),
//           Spacer(),
//           // TextButton(onPressed: () => , child: const Text("Close"))
//         ],
//       )
//   ),
// );
  @override
  Widget build(BuildContext context) {
    return videoScreen();
  }

  Widget videoScreen() {
    return Scaffold(
      key: _scaffoldKey,
      drawerEnableOpenDragGesture: false,
      onDrawerChanged: (isOpened) {
        isOpened ? feedViewModel.pauseDrawer() : feedViewModel.playDrawer();
      },
      drawer: Container(
        margin: MediaQuery.of(context).padding,
        child: Drawer(
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ClipOval(
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl:
                                  "https://q5n8c8q9.rocketcdn.me/wp-content/uploads/2018/08/The-20-Best-Royalty-Free-Music-Sites-in-2018.png",
                              height: 90.0,
                              width: 90.0,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            "${['Name']}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ]),
              ),
              ListTile(
                leading: const Icon(Icons.thumb_up),
                title: const Text('Liked Videos'),
                onTap: () {
                  Navigator.of(context).pushNamed(MyLikedVideos.routeName);
                  feedViewModel.pauseDrawer();
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('My Profile'),
                onTap: () {
                  Navigator.of(context).pushNamed(ProfileScreen.routeName);
                  feedViewModel.pauseDrawer();
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Creator Page'),
                onTap: () {
                  Navigator.of(context).pushNamed(CreatorPage.routeName);
                  feedViewModel.pauseDrawer();
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text("Logout"),
                onTap: () async {
                  final FirebaseAuth _firebase = FirebaseAuth.instance;
                  final GoogleSignIn _googleSignIn = GoogleSignIn();
                  User user = _firebase.currentUser!;
                  await feedViewModel.pauseDrawer();
                  if (user.providerData[0].providerId == 'google.com') {
                    await _googleSignIn.signOut();
                  }
                  //await InternetAddress.lookup('google.com');
                  // if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                  await _firebase.signOut();
                  await feedViewModel.disposingall();
                  Navigator.pop(context);
                  locator<FeedViewModel>().removeListener(() {
                    setState(() {});
                  });
                  locator<LikeProvider>().removeListener(() {
                    setState(() {});
                  });
                  locator<MyVideosProvider>().removeListener(() {
                    setState(() {});
                  });
                },
              )
            ],
          ),
        ),
      ),
      body: FutureBuilder(
          future: Future.wait(feedViewModel.videoSource!.loading()),
          builder: (ctx, snapshot) {
            return snapshot.connectionState == ConnectionState.done
                ? SafeArea(
                    child: Stack(
                      children: [
                        const ScrollFeed(0, false, false),
                        Positioned(
                          left: 10,
                          top: 20,
                          child: IconButton(
                              icon: const Icon(Icons.menu),
                              onPressed: () {
                                _scaffoldKey.currentState!.openDrawer();
                              }),
                        ),
                      ],
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  );
          }),
    );
  }
}
