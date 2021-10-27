import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:oknoapp/services/web_placeholder.dart';
import '../firebase functions/sidebar_fun.dart';
import '../models/my_videos.dart';
import '../providers/myvideosprovider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get_it/get_it.dart';
import '../services/cache_service.dart';
import './liked_scroll.dart';

class MyVideoTab extends StatefulWidget {
  const MyVideoTab({Key? key}) : super(key: key);

  @override
  _MyVideoTabState createState() => _MyVideoTabState();
}

class _MyVideoTabState extends State<MyVideoTab>
    with AutomaticKeepAliveClientMixin<MyVideoTab> {
  List<MyVideos> videosData = [];
  bool isLoading = false;

  final feedViewModel2 = GetIt.instance<MyVideosProvider>();

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
                  child: Text('No Videos Created'),
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
                                    return LikeScroll(index, true);
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
                                                      .thumbnail,
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
                                                      .thumbnail,
                                                ),
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
