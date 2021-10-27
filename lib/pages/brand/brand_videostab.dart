import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get_it/get_it.dart';
import 'package:oknoapp/pages/brand/brand_videopage.dart';
import 'package:oknoapp/services/web_placeholder.dart';
import '../../services/cache_service.dart';
import '../../models/brand_videos.dart';
import '../../providers/brand_provider.dart';

class BrandTab extends StatefulWidget {
  const BrandTab({Key? key}) : super(key: key);

  @override
  _BrandTabState createState() => _BrandTabState();
}

class _BrandTabState extends State<BrandTab>
    with AutomaticKeepAliveClientMixin<BrandTab> {
  List<BrandVideos> videosData = [];
  bool isLoading = false;

  final feedViewModel2 = GetIt.instance<BrandVideoProvider>();

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
      child: isLoading && feedViewModel2.videoSource!.flag == 0
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : videosData.isEmpty
              ? const Center(
                  child: Text('No Videos from your brand yet!!'),
                )
              : GridView.builder(
                  //key: Key(feedViewModel.videoSource!.listVideos.length.toString()),
                  //shrinkWrap: true,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: feedViewModel2.videoSource!.hasMore &&
                          feedViewModel2.videoSource!.listData.length >= 10
                      ? videosData.length + 1
                      : videosData.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
                    childAspectRatio: 9 / 15,
                  ),
                  itemBuilder: (context, index) {
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
                            return BrandScroll(index);
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
                                          image: feedViewModel2.videoSource!
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
                                          imageUrl: feedViewModel2.videoSource!
                                              .listData[index].thumbnail,
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
