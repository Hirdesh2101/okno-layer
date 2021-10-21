import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:oknoapp/models/like_videos.dart';
import 'package:oknoapp/pages/liked_scroll.dart';
import '../providers/likedvideoprovider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/cache_service.dart';
import '../firebase functions/sidebar_fun.dart';
import '../services/service_locator.dart';

class MyLikedVideos extends StatefulWidget {
  static const routeName = '/my_likevideos';
  const MyLikedVideos({Key? key}) : super(key: key);

  @override
  _MyLikedVideosState createState() => _MyLikedVideosState();
}

class _MyLikedVideosState extends State<MyLikedVideos> {
  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    setupLike();
    super.initState();
  }

  final feedViewModel = GetIt.instance<LikeProvider>();
  final SideBarFirebase firebaseServices = SideBarFirebase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Liked Videos'),
          elevation: 0,
        ),
        body: FutureBuilder(
            future: feedViewModel.videoSource!.load(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              List<LikeVideo> videos = feedViewModel.videoSource!.listData;
              return videos.isEmpty
                  ? const Center(
                      child: Text('No Liked Videos'),
                    )
                  : GridView.count(
                      //key: Key(feedViewModel.videoSource!.listVideos.length.toString()),
                      //shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      crossAxisCount: 3,
                      childAspectRatio: 9 / 15,
                      crossAxisSpacing: 1.5,
                      mainAxisSpacing: 1.5,
                      children: List.generate(videos.length, (index) {
                        {
                          return GestureDetector(
                              key: UniqueKey(),
                              onTap: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return LikeScroll(index, false);
                                }));
                              },
                              child: Card(
                                elevation: 3,
                                child: Stack(
                                  children: [
                                    SizedBox.expand(
                                      child: FittedBox(
                                        fit: BoxFit.fill,
                                        child: CachedNetworkImage(
                                          placeholder: (context, url) =>
                                              Container(
                                                  // color: Colors.grey,
                                                  ),
                                          fit: BoxFit.fitHeight,
                                          cacheManager:
                                              CustomCacheManager.instance2,
                                          imageUrl: feedViewModel.videoSource!
                                              .listData[index].product1,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      child: PopupMenuButton(
                                        itemBuilder: (BuildContext context) {
                                          return <PopupMenuEntry>[
                                            const PopupMenuItem(
                                              child: Text('Remove'),
                                              value: 1,
                                            ),
                                          ];
                                        },
                                        onSelected: (value) async {
                                          if (value == 1) {
                                            await firebaseServices
                                                .add(
                                                    feedViewModel.videoSource!
                                                        .listData[index].id,
                                                    true)
                                                .then((value) {
                                              setState(() {});
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ));
                        }
                      }),
                    );
            }));
  }
}
