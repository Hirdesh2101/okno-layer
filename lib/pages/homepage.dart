import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oknoapp/pages/contact_page.dart';
import 'package:oknoapp/pages/creator_section.dart';
import 'package:oknoapp/pages/legalpage.dart';
import 'package:oknoapp/pages/mylikedvideos.dart';
import 'package:oknoapp/pages/profile_page.dart';
import 'package:oknoapp/providers/likedvideoprovider.dart';
import 'package:oknoapp/services/web_placeholder.dart';
import '../providers/myvideosprovider.dart';
import 'scrollfeed.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import '../providers/feedviewprovider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/filter_provider.dart';
import 'package:ionicons/ionicons.dart';

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
  final feedViewModel4 = GetIt.instance<FilterViewModel>();
  final firebaseAuth = FirebaseAuth.instance;
  var user = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool homepressed = false;
  // ignore: prefer_typing_uninitialized_variables
  var future;
  init() async {
    //subscribe to topic on each app start-up
    FirebaseAnalytics().logEvent(name: 'login', parameters: null);
    FirebaseAnalytics().logEvent(name: 'main_feed', parameters: null);
    await FirebaseFirestore.instance
        .collection('UsersData')
        .doc(user)
        .get()
        .then((value) async {
      await FirebaseAnalytics().setUserProperty(
          name: 'category', value: '${value.data()!['topic']}');
      await _firebaseMessaging.subscribeToTopic('${value.data()!['topic']}');
    });
  }

  @override
  void initState() {
    future = feedViewModel.videoSource!.load(0);
    init();
    super.initState();
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
        isOpened ? feedViewModel4.pauseDrawer() : feedViewModel4.playDrawer();
        isOpened ? feedViewModel.pauseDrawer() : feedViewModel.playDrawer();
      },
      drawer: Container(
        margin: MediaQuery.of(context).padding,
        child: Drawer(
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                child: FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('UsersData')
                        .doc(user)
                        .get(),
                    builder: (context, snapshot) {
                      dynamic data = snapshot.data;
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                (data['Image'] == 'Male' ||
                                        data['Image'] == 'Female')
                                    ? data['Image'] == 'Male'
                                        ? const CircleAvatar(
                                            radius: 45,
                                            backgroundImage:
                                                AssetImage("assets/male.jpg"))
                                        : const CircleAvatar(
                                            radius: 45,
                                            backgroundImage:
                                                AssetImage("assets/female.jpg"))
                                    : ClipOval(
                                        child: kIsWeb
                                            ? FadeInImage.memoryNetwork(
                                                placeholder: kTransparentImage,
                                                image: data['Image'],
                                                height: 90.0,
                                                fit: BoxFit.cover,
                                                width: 90.0,
                                              )
                                            : CachedNetworkImage(
                                                fit: BoxFit.cover,
                                                imageUrl: data['Image'],
                                                height: 90.0,
                                                width: 90.0,
                                                placeholder: (context, url) =>
                                                    const CircularProgressIndicator(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(Icons.error),
                                              ),
                                      ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  '${data['Name']}',
                                  style: const TextStyle(
                                      //  color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ]);
                    }),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  setState(() {
                    homepressed = true;
                  });
                  Navigator.of(context).pop();
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
                leading: const Icon(Icons.thumb_up),
                title: const Text('Liked Videos'),
                onTap: () {
                  Navigator.of(context).pushNamed(MyLikedVideos.routeName);
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
                leading: const Icon(Ionicons.information_circle_outline),
                title: const Text('Contact Us'),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const ContactPage()));
                  feedViewModel.pauseDrawer();
                },
              ),
              ListTile(
                leading: const Icon(Ionicons.flag_outline),
                title: const Text('Legal'),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const LegalPage()));
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
          future: future,
          builder: (ctx, snapshot) {
            return snapshot.connectionState == ConnectionState.done
                ? SafeArea(
                    child: Stack(
                      children: [
                        ScrollFeed(
                          0,
                          false,
                          false,
                          homepressed,
                        ),
                        Positioned(
                          left: 10,
                          top: 20,
                          child: IconButton(
                              icon: const Icon(
                                Icons.menu,
                                color: Colors.white,
                              ),
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
