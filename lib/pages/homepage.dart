import 'package:flutter/material.dart';
import 'package:oknoapp/pages/creator_section.dart';
import 'package:oknoapp/pages/mylikedvideos.dart';
import 'package:oknoapp/pages/profile_page.dart';
import 'package:oknoapp/providers/likedvideoprovider.dart';
import '../providers/myvideosprovider.dart';
import 'scrollfeed.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get_it/get_it.dart';
import '../providers/feedviewprovider.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home_page';
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final locator = GetIt.instance;
  final feedViewModel = GetIt.instance<FeedViewModel>();
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
              const DrawerHeader(
                child: Text("Header"),
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
          future: FirebaseFirestore.instance
              .collection("VideosData")
              .where('Approved', isEqualTo: true)
              .limit(10)
              .get(),
          builder: (ctx, snapshot) {
            return snapshot.hasData
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
