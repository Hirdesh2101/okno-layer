import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oknoapp/pages/change_theme.dart';
import 'package:oknoapp/pages/edit_profile.dart';
import 'package:oknoapp/pages/tab_saved.dart';
import 'package:oknoapp/pages/tabmyvideo.dart';
import 'package:ionicons/ionicons.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:oknoapp/services/web_placeholder.dart';
import 'video_page.dart';
import 'package:tuple/tuple.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile_page';
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final List<Tuple2> _pages = [
    const Tuple2(
        MyVideoTab(),
        Icon(
          Ionicons.grid_outline,
        )),
    const Tuple2(
        SavedTab(),
        Icon(
          Ionicons.bookmark_outline,
        )),
  ];
  @override
  void initState() {
    _tabController = TabController(length: _pages.length, vsync: this);
    _tabController!.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final user = FirebaseAuth.instance.currentUser!.uid;
    // final _firebase =
    //     FirebaseFirestore.instance.collection("UsersData").doc(user);
    // final feedViewModel2 = GetIt.instance<MySavedVideosProvider>();
    return
        // appBar: AppBar(
        //   actions: [
        //     PopupMenuButton(itemBuilder: (BuildContext context) {
        //       return <PopupMenuEntry>[
        //         const PopupMenuItem(
        //           child: Text('Settings'),
        //           value: 1,
        //         ),
        //       ];
        //     }, onSelected: (value) async {
        //       if (value == 1) {
        //         Navigator.of(context).push(
        //             MaterialPageRoute(builder: (ctx) => const ThemeScreen()));
        //       }
        //     })
        //   ],
        // ),
        Scaffold(
      body: NestedScrollView(
          // controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              const PortfolioSliverAppBar(),
              SliverPersistentHeader(
                  delegate: SliverPersistentHeaderDelegateImpl(
                      tabBar: TabBar(
                labelColor: Theme.of(context).iconTheme.color,
                indicatorColor: Theme.of(context).iconTheme.color,
                controller: _tabController,
                tabs: _pages
                    .map<Tab>((Tuple2 page) => Tab(
                          icon: page.item2,
                        ))
                    .toList(),
              )))
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: _pages.map<Widget>((Tuple2 page) => page.item1).toList(),
          )),
    );
  }
}

// WillPopScope(
//   onWillPop: () async {
//     feedViewModel2.videoSource!.listVideos.clear();
//     feedViewModel2.videoSource!.listData.clear();
//     feedViewModel2.videoSource!.isRunning = false;
//     // if (_key.currentState!.canPop()) {
//     //   _key.currentState!.pop();
//     //   return false;
//     // }
//     return true;
//   },

class SliverPersistentHeaderDelegateImpl
    extends SliverPersistentHeaderDelegate {
  final TabBar? tabBar;
  final Color color;

  const SliverPersistentHeaderDelegateImpl({
    Color color = Colors.transparent,
    @required this.tabBar,
    // ignore: prefer_initializing_formals
  }) : color = color;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: color,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar!.preferredSize.height;

  @override
  double get minExtent => tabBar!.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class PortfolioSliverAppBar extends StatefulWidget {
  const PortfolioSliverAppBar({
    Key? key,
  }) : super(key: key);

  @override
  State<PortfolioSliverAppBar> createState() => _PortfolioSliverAppBarState();
}

class _PortfolioSliverAppBarState extends State<PortfolioSliverAppBar> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!.uid;
    final _firebase =
        FirebaseFirestore.instance.collection("UsersData").doc(user);
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    return SliverAppBar(
      iconTheme: Theme.of(context).iconTheme,
      actions: [
        PopupMenuButton(itemBuilder: (BuildContext context) {
          return <PopupMenuEntry>[
            const PopupMenuItem(
              child: Text('Settings'),
              value: 1,
            ),
          ];
        }, onSelected: (value) async {
          if (value == 1) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (ctx) => const ThemeScreen()));
          }
        })
      ],
      expandedHeight: 270,
      pinned: true,
      floating: true,
      flexibleSpace: FlexibleSpaceBar(
        background: FutureBuilder(
            future: _firebase.get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              dynamic data = snapshot.data;
              return ListView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(
                    height: 25,
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          (data['Image'] == 'Male' || data['Image'] == 'Female')
                              ? data['Image'] == 'Male'
                                  ? const CircleAvatar(
                                      radius: 50,
                                      backgroundImage:
                                          AssetImage("assets/male.jpg"))
                                  : const CircleAvatar(
                                      radius: 50,
                                      backgroundImage:
                                          AssetImage("assets/female.jpg"))
                              : ClipOval(
                                  child: kIsWeb
                                      ? FadeInImage.memoryNetwork(
                                          placeholder: kTransparentImage,
                                          image: data['Image'],
                                          height: 100.0,
                                          fit: BoxFit.cover,
                                          width: 100.0,
                                        )
                                      : CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          imageUrl: data['Image'],
                                          height: 100.0,
                                          width: 100.0,
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
                      Text(
                        "${data['Name']}",
                        style: const TextStyle(
                            // color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "${data['Email']}",
                        style: const TextStyle(
                            // color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(),
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(EditProfile.routeName);
                            },
                            child: const Center(
                              child: Text(
                                "Edit profile",
                                style: TextStyle(
                                    //   color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          if (data['Creator'] == true && !kIsWeb)
                            IconButton(
                              icon: Center(
                                  child: Icon(
                                Icons.add_a_photo_outlined,
                                size: MediaQuery.of(context).size.width * 0.075,
                                //color: Colors.white,
                              )),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const VideoRecorder()),
                                );
                              },
                            ),
                          if (data['Creator'] == false)
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(),
                              onPressed: () async {
                                await _firebase
                                    .update({'Creator': true}).whenComplete(() {
                                  setState(() {});
                                });
                                await _firebase.update({'topic': "creator"});
                                await _firebaseMessaging
                                    .unsubscribeFromTopic('viewer');
                                await _firebaseMessaging
                                    .subscribeToTopic('creator');
                                // Navigator.of(context)
                                //     .push(MaterialPageRoute(builder: (cotext) {
                                //   return const WebViewPage(
                                //       title: 'Terms and Conditions',
                                //       url: 'https://www.oknoapp.com/');
                                // })).whenComplete(() {
                                //   setState(() {});
                                // });
                              },
                              child: const Center(
                                child: Text(
                                  "Become a Creator",
                                  style: TextStyle(
                                      //color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                ],
              );
            }),
      ),
    );
  }
}
