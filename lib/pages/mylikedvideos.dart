import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:oknoapp/models/like_videos.dart';
import 'package:oknoapp/pages/liked_scroll.dart';
import 'package:oknoapp/services/service_locator.dart';
import 'package:oknoapp/services/web_placeholder.dart';
import '../providers/likedvideoprovider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/cache_service.dart';
import '../firebase functions/sidebar_fun.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

class MyLikedVideos extends StatefulWidget {
  static const routeName = '/my_likevideos';
  const MyLikedVideos({Key? key}) : super(key: key);

  @override
  _MyLikedVideosState createState() => _MyLikedVideosState();
}

class _MyLikedVideosState extends State<MyLikedVideos> {
  List<LikeVideo> videosData = [];
  bool isLoading = false;
  @override
  void initState() {
    //setupLike();
    feedViewModel.videoSource!.listVideos.clear();
    feedViewModel.videoSource!.listData.clear();
    feedViewModel.videoSource!.flag = 0;
    feedViewModel.videoSource!.hasMore = true;
    feedViewModel.videoSource!.lastitemIndex = 0;
    _loadMoreVertical();
    super.initState();
  }

  Future _loadMoreVertical() async {
    if (feedViewModel.videoSource!.hasMore) {
      setState(() {
        isLoading = true;
      });
      await feedViewModel.videoSource!.load();
      videosData = (feedViewModel.videoSource!.listData);
      setState(() {
        isLoading = false;
      });
    }
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
      body: LazyLoadScrollView(
        onEndOfPage: () => _loadMoreVertical(),
        child: isLoading && feedViewModel.videoSource!.flag == 0
            ? const Center(child: CircularProgressIndicator())
            : videosData.isEmpty
                ? const Center(
                    child: Text('No Liked Videos'),
                  )
                : GridView.builder(
                    //key: Key(feedViewModel.videoSource!.listVideos.length.toString()),
                    //shrinkWrap: true,
                    shrinkWrap: true,
                    //physics: const NeverScrollableScrollPhysics(),
                    itemCount: feedViewModel.videoSource!.hasMore
                        ? videosData.length + 1
                        : videosData.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                      childAspectRatio: 9 / 15,
                    ),
                    itemBuilder: (context, index) {
                      if (index == videosData.length &&
                          feedViewModel.videoSource!.hasMore) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
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
                                    child: kIsWeb
                                        ? FadeInImage.memoryNetwork(
                                            placeholder: kTransparentImage,
                                            image: feedViewModel.videoSource!
                                                .listData[index].thumbnail,
                                            fit: BoxFit.fitHeight,
                                          )
                                        : CachedNetworkImage(
                                            placeholder: (context, url) =>
                                                Container(
                                                    // color: Colors.grey,
                                                    ),
                                            fit: BoxFit.fitHeight,
                                            cacheManager:
                                                CustomCacheManager.instance2,
                                            imageUrl: feedViewModel.videoSource!
                                                .listData[index].thumbnail,
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
                                          setState(() {
                                            videosData.removeAt(index);
                                          });
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ));
                    }),
      ),
    );
  }
}
