import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:oknoapp/services/web_placeholder.dart';
import '../models/my_saved.dart';
import '../firebase functions/sidebar_fun.dart';
import '../providers/savedvideoprovider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get_it/get_it.dart';
import '../services/cache_service.dart';
import '../pages/creatorandsavedscroll.dart';

class SavedTab extends StatefulWidget {
  const SavedTab({Key? key}) : super(key: key);

  @override
  _SavedTabState createState() => _SavedTabState();
}

class _SavedTabState extends State<SavedTab>
    with AutomaticKeepAliveClientMixin<SavedTab> {
  List<MySavedVideos> videosData = [];
  bool isLoading = false;

  final feedViewModel2 = GetIt.instance<MySavedVideosProvider>();

  final SideBarFirebase firebaseServices = SideBarFirebase();

  Future _loadMoreSavedVertical() async {
    if (feedViewModel2.videoSource!.hasMore) {
      setState(() {
        isLoading = true;
      });
      await feedViewModel2.videoSource!.load();
      videosData = (feedViewModel2.videoSource!.listData);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    feedViewModel2.videoSource!.hasMore = true;
    if (feedViewModel2.videoSource!.listData.isEmpty) {
      _loadMoreSavedVertical();
    } else {
      videosData = feedViewModel2.videoSource!.listData;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LazyLoadScrollView(
      onEndOfPage: () => _loadMoreSavedVertical(),
      child: isLoading && feedViewModel2.videoSource!.flag == 0
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : videosData.isEmpty
              ? const Center(
                  child: Text('No Saved Videos'),
                )
              : CustomScrollView(
                  slivers: <Widget>[
                    SliverPadding(
                      padding: const EdgeInsets.all(2),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 1,
                          mainAxisSpacing: 1,
                          childAspectRatio: 9 / 15,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == videosData.length &&
                                feedViewModel2.videoSource!.hasMore) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return GestureDetector(
                                key: UniqueKey(),
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return CreatorandSavedScroll(
                                        index, true, false, false);
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
                                                  placeholder:
                                                      kTransparentImage,
                                                  image: feedViewModel2
                                                      .videoSource!
                                                      .listData[index]
                                                      .product1,
                                                  fit: BoxFit.fitHeight,
                                                )
                                              : CachedNetworkImage(
                                                  placeholder: (context, url) =>
                                                      Container(
                                                          // color: Colors.grey,
                                                          ),
                                                  fit: BoxFit.fitHeight,
                                                  cacheManager:
                                                      CustomCacheManager
                                                          .instance2,
                                                  imageUrl: feedViewModel2
                                                      .videoSource!
                                                      .listData[index]
                                                      .product1,
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
                                                  .removeSaved(feedViewModel2
                                                      .videoSource!
                                                      .listData[index]
                                                      .id)
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
                          },
                          childCount: feedViewModel2.videoSource!.hasMore &&
                                  feedViewModel2.videoSource!.listData.length >=
                                      10
                              ? videosData.length + 1
                              : videosData.length,
                        ),
                      ),
                    )
                  ],
                ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
