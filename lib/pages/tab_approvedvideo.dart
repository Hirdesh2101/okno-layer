import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import '../firebase functions/sidebar_fun.dart';
import '../models/my_videos.dart';
import '../providers/myvideosprovider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get_it/get_it.dart';
import '../services/cache_service.dart';
import '../pages/creatorandsavedscroll.dart';

class ApprovedVideoTab extends StatefulWidget {
  const ApprovedVideoTab({Key? key}) : super(key: key);

  @override
  _ApprovedVideoTabState createState() => _ApprovedVideoTabState();
}

class _ApprovedVideoTabState extends State<ApprovedVideoTab>
    with AutomaticKeepAliveClientMixin<ApprovedVideoTab> {
  List<MyVideos> videosData = [];
  bool isLoading = false;

  final feedViewModel2 = GetIt.instance<MyVideosProvider>();

  final SideBarFirebase firebaseServices = SideBarFirebase();

  Future _loadMoreSavedVertical() async {
    if (feedViewModel2.videoSource!.hasMoreapproved) {
      setState(() {
        isLoading = true;
      });
      await feedViewModel2.videoSource!.loadapproved();
      videosData = (feedViewModel2.videoSource!.approvedData);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    feedViewModel2.videoSource!.flagapproved = 0;
    feedViewModel2.videoSource!.hasMoreapproved = true;
    feedViewModel2.videoSource!.lastitemIndexapproved = 0;
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
                  child: Text('No Approved Videos'),
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
                            return CreatorandSavedScroll(
                                index, false, true, false);
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
                                    imageUrl: feedViewModel2.videoSource!
                                        .approvedData[index].thumbnail,
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
                                          .removeMyVideo(feedViewModel2
                                              .videoSource!
                                              .approvedData[index]
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
                  }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
