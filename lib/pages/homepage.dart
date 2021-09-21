import 'package:flutter/material.dart';
import 'package:oknoapp/pages/mylikedvideos.dart';
import 'package:oknoapp/pages/profile_page.dart';
import 'package:oknoapp/providers/likedvideoprovider.dart';
import 'scrollfeed.dart';
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
                leading: const Icon(Icons.exit_to_app),
                title: const Text("Logout"),
                onTap: () async {
                  final FirebaseAuth _firebase = FirebaseAuth.instance;
                  final GoogleSignIn _googleSignIn = GoogleSignIn();
                  User user = _firebase.currentUser!;
                  // if (user.providerData[1].providerId == 'google.com') {
                  //   await _googleSignIn.signOut();
                  // }
                  await _firebase.signOut();
                  await feedViewModel.pauseDrawer();
                  await feedViewModel.disposingall();
                  Navigator.pop(context);
                  locator<FeedViewModel>().removeListener(() {
                    setState(() {});
                  });
                  locator<LikeProvider>().removeListener(() {
                    setState(() {});
                  });
                },
              )
            ],
          ),
        ),
      ),
      body: FutureBuilder(
          future: feedViewModel.videoSource!.getVideoList(),
          builder: (ctx, snapshot) {
            return snapshot.hasData
                ? SafeArea(
                    child: Stack(
                      children: [
                        const ScrollFeed(0, false),
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
