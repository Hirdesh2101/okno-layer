import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
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
    feedViewModel2.videoSource!.flag = 0;
    feedViewModel2.videoSource!.hasMore = true;
    feedViewModel2.videoSource!.lastitemIndex = 0;
    _loadMoreSavedVertical();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LazyLoadScrollView(
      onEndOfPage: () => _loadMoreSavedVertical(),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : videosData.isEmpty
              ? const Center(
                  child: Text('No Videos Created'),
                )
              : GridView.builder(
                  //key: Key(feedViewModel.videoSource!.listVideos.length.toString()),
                  //shrinkWrap: true,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: videosData.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
                    childAspectRatio: 9 / 15,
                  ),
                  itemBuilder: (context, index) {
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
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) => Container(
                                        // color: Colors.grey,
                                        ),
                                    fit: BoxFit.fitHeight,
                                    cacheManager: CustomCacheManager.instance2,
                                    imageUrl: feedViewModel2
                                        .videoSource!.listData[index].thumbnail,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ));
                  }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
