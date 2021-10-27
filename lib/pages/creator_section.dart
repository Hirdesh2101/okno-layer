import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oknoapp/pages/brand/brands_page.dart';
import 'package:oknoapp/pages/encashed_page.dart';
import 'package:oknoapp/pages/tab_approvedvideo.dart';
import 'package:oknoapp/pages/tabnonapproved.dart';
import 'video_page.dart';
import 'package:ionicons/ionicons.dart';
import '../services/service_locator.dart';
import 'package:tuple/tuple.dart';

class CreatorPage extends StatefulWidget {
  static const routeName = '/creator_page';
  const CreatorPage({Key? key}) : super(key: key);

  @override
  _CreatorPageState createState() => _CreatorPageState();
}

class _CreatorPageState extends State<CreatorPage>
    with SingleTickerProviderStateMixin {
  final List<Tuple2> _pages = [
    const Tuple2(ApprovedVideoTab(), Icon(Ionicons.apps_outline)),
    const Tuple2(NonApprovedVideoTab(), Icon(Ionicons.hardware_chip_outline)),
  ];
  TabController? _tabController;

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
    return Scaffold(
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
    return SliverAppBar(
      iconTheme: Theme.of(context).iconTheme,
      expandedHeight: 250,
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
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: (data['Image'] == 'Male' ||
                                    data['Image'] == 'Female')
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
                                    child: CachedNetworkImage(
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
                          ),
                          const SizedBox(
                            width: 25,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 30,
                              ),
                              Text("Encashed ${data['Encashed'] ?? '0.0'}"),
                              const SizedBox(
                                height: 5,
                              ),
                              Text("Balance ${data['Balance'] ?? '0.0'}"),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                  "Total Income ${data['Encashed'] + data['Balance'] ?? '0.0'}"),
                              const SizedBox(
                                height: 5,
                              ),
                              if (data['Creator'] == true)
                                OutlinedButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pushNamed(EncashedPage.routeName)
                                          .whenComplete(() {
                                        setState(() {});
                                      });
                                    },
                                    child: const Text('Encash'))
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (data['Creator'] == true)
                            Row(
                              children: [
                                IconButton(
                                  icon: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.1,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.1,
                                      decoration: const BoxDecoration(
                                          //  border: Border.all(color: Colors.white12)
                                          ),
                                      child: Center(
                                          child: Icon(
                                        Icons.add_a_photo_outlined,
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.075,
                                        //   color: Colors.white,
                                      ))),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const VideoRecorder()),
                                    );
                                  },
                                ),
                                if (data['BrandEnabled'] == true)
                                  IconButton(
                                    icon: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.1,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.1,
                                        decoration: const BoxDecoration(
                                            //  border: Border.all(color: Colors.white12)
                                            ),
                                        child: Center(
                                            child: Icon(
                                          Ionicons.storefront,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.075,
                                          //   color: Colors.white,
                                        ))),
                                    onPressed: () {
                                      setupBrand();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const BrandPage()),
                                      );
                                    },
                                  )
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      if (data['Creator'] == false)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(),
                              onPressed: () {
                                _firebase
                                    .update({'Creator': true}).whenComplete(() {
                                  setState(() {});
                                });
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
                                      // color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
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
