import 'package:flutter/material.dart';
import 'package:oknoapp/firebase%20functions/sidebar_fun.dart';
import 'package:oknoapp/models/like_videos.dart';
import 'package:oknoapp/models/my_videos.dart';
import 'package:oknoapp/providers/myvideosprovider.dart';
import '../providers/feedviewprovider.dart';
import 'package:video_player/video_player.dart';
import './videoactiontoolbar.dart';
import 'package:get_it/get_it.dart';
import 'dart:async';
import '../services/dynamic_linkstream.dart';
import '../models/video.dart';
import 'package:stacked/stacked.dart';
import '../providers/filter_provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../services/dynamic_link.dart';
import '../providers/likedvideoprovider.dart';

class ScrollFeed extends StatefulWidget {
  final int startIndex;
  final bool likedPage;
  final bool myVideopage;
  const ScrollFeed(this.startIndex, this.likedPage, this.myVideopage,
      {Key? key})
      : super(key: key);

  @override
  _ScrollFeedState createState() => _ScrollFeedState();
}

class _ScrollFeedState extends State<ScrollFeed> {
  final feedViewModel = GetIt.instance<FeedViewModel>();
  final feedViewModel2 = GetIt.instance<LikeProvider>();
  final feedViewModel3 = GetIt.instance<MyVideosProvider>();
  final feedViewModel4 = GetIt.instance<FilterViewModel>();
  final SideBarFirebase firebaseServices = SideBarFirebase();
  final DynamicLinkService _dynamicLinkService = DynamicLinkService();
  bool filterPage = false;
  bool filterVideoView = false;
  bool filterRunning = false;
  String? dynamicId = '';
  Stream stream = controller.stream;
  List<String> countList = [
    "Ethenics",
    "Western",
    "Festive",
    "Casuals",
  ];
  List<String> selectedCountList = [];
  void filterOpened(bool value) {
    setState(() {
      filterPage = value;
    });
  }

  Future<void> submitFun(list) async {
    setState(() {
      selectedCountList = List.from(list);
      if (selectedCountList.isEmpty) {
        filterVideoView = false;
      } else {
        filterVideoView = true;
      }
    });
    if (selectedCountList.isNotEmpty) {
      await feedViewModel4.initial(list);
    } else {
      await feedViewModel.initial();
      await feedViewModel4.disposingall();
      feedViewModel4.currentscreen = 0;
      feedViewModel.playDrawer();
    }
    if (!filterRunning) {
      await feedViewModel.disposingall();
      feedViewModel.currentscreen = 0;
    }
    setState(() {
      if (selectedCountList.isNotEmpty) {
        filterRunning = true;
      } else {
        filterRunning = false;
      }
    });
  }

  void init() async {
    stream.listen((event) {
      if (event != '') {
        submitFun(List.filled(1, event));
      }
    });
    if (!widget.likedPage && !widget.myVideopage) {
      feedViewModel.initial();
    }
    if (widget.likedPage) {
      feedViewModel2.initial(widget.startIndex);
    }
    if (widget.myVideopage) {
      feedViewModel3.initial(widget.startIndex, false, false);
    }
    feedViewModel.setBusy(true);
    _dynamicLinkService.retrieveDynamicLink(context);
    feedViewModel.setBusy(false);
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(child: feedVideos()),
      ],
    );
  }

  Widget feedVideos() {
    final PageController pageController = PageController(
      keepPage: true,
      initialPage:
          widget.likedPage || widget.myVideopage ? widget.startIndex : 0,
      viewportFraction: 1,
    );
    return Stack(
      children: [
        ViewModelBuilder.reactive(
            disposeViewModel: false,
            viewModelBuilder: () => widget.likedPage || widget.myVideopage
                ? widget.likedPage
                    ? feedViewModel2
                    : feedViewModel3
                : filterVideoView
                    ? feedViewModel4
                    : feedViewModel,
            builder: (context, model, child) {
              return !feedViewModel.isBusy &&
                      !feedViewModel2.isBusy &&
                      !feedViewModel3.isBusy &&
                      !feedViewModel4.isBusy
                  ? !widget.likedPage &&
                          !widget.myVideopage &&
                          feedViewModel.videoSource!.listVideos.isEmpty
                      ? filterVideoView
                          ? const Center(
                              child: Text('No Videos For this Filter'),
                            )
                          : RefreshIndicator(
                              onRefresh: () {
                                feedViewModel.videoSource!.delete();
                                return feedViewModel.videoSource!
                                    .load(0)
                                    .then((val) {
                                  init();
                                  setState(() {});
                                });
                              },
                              child: SingleChildScrollView(
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.height,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Text('You Are All Caught Up'),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text('Pull To Refresh')
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                      : PageView.builder(
                          physics: const BouncingScrollPhysics(),
                          controller: pageController,
                          itemCount: widget.likedPage || widget.myVideopage
                              ? widget.likedPage
                                  ? feedViewModel2.length()
                                  : feedViewModel3.videoSource!.listData.length
                              : filterVideoView
                                  ? feedViewModel4.length()
                                  : feedViewModel.length(),
                          onPageChanged: (index) {
                            widget.likedPage || widget.myVideopage
                                ? widget.likedPage
                                    ? feedViewModel2.onpageChanged(index)
                                    : feedViewModel3.onpageChanged(
                                        index, false, false)
                                : filterVideoView
                                    ? feedViewModel4.onpageChanged(index)
                                    : feedViewModel.onpageChanged(index);
                          },
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, index) {
                            return Stack(children: [
                              widget.likedPage || widget.myVideopage
                                  ? widget.likedPage
                                      ? videoCard2(feedViewModel2
                                          .videoSource!.listData[index])
                                      : videoCard3(feedViewModel3
                                          .videoSource!.listData[index])
                                  : filterVideoView
                                      ? videoCard(
                                          feedViewModel4
                                              .videoSource!.listVideos[index],
                                          feedViewModel4.videoSource!
                                              .listVideos[index].id)
                                      : videoCard(
                                          feedViewModel
                                              .videoSource!.listVideos[index],
                                          feedViewModel.videoSource!
                                              .listVideos[index].id),
                              !widget.myVideopage
                                  ? ActionToolBar(
                                      index,
                                      widget.likedPage,
                                      widget.myVideopage,
                                      filterVideoView,
                                      context,
                                      countList,
                                      selectedCountList,
                                      submitFun,
                                      filterOpened,
                                      filterVideoView,
                                    )
                                  : (widget.myVideopage &&
                                          !feedViewModel3.videoSource!
                                              .listData[index].approved)
                                      ? Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: const [
                                              Text('Approval Pending'),
                                              SizedBox(
                                                height: 8,
                                              )
                                            ],
                                          ))
                                      : ActionToolBar(
                                          index,
                                          widget.likedPage,
                                          widget.myVideopage,
                                          filterVideoView,
                                          context,
                                          countList,
                                          selectedCountList,
                                          submitFun,
                                          filterOpened,
                                          filterVideoView,
                                        ),
                              feedViewModel.creatingLink! ||
                                      feedViewModel4.creatingLink!
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : const SizedBox(
                                      width: 0,
                                      height: 0,
                                    ),
                            ]);
                          })
                  : const Center(
                      child: CircularProgressIndicator(),
                    );
            }),
      ],
    );
  }

  Widget videoCard(Video video, var id) {
    return video.controller != null && video.controller!.value.isInitialized
        ? VisibilityDetector(
            key: Key(video.id),
            onVisibilityChanged: (info) {
              var visiblePercentage = info.visibleFraction * 100;
              if (visiblePercentage < 50) {
                if (video.controller!.value.isPlaying) {
                  if (filterVideoView) {
                    feedViewModel4.pauseDrawer();
                  } else {
                    feedViewModel.pauseDrawer();
                  }
                }
              } else {
                if (!video.controller!.value.isPlaying) {
                  if (Scaffold.of(context).isDrawerOpen || filterPage) {
                    if (filterVideoView) {
                      feedViewModel4.pauseDrawer();
                    } else {
                      feedViewModel.pauseDrawer();
                    }
                  } else {
                    if (filterVideoView) {
                      feedViewModel4.playDrawer();
                    } else {
                      feedViewModel.playDrawer();
                    }
                  }
                }
              }
            },
            child: Stack(children: [
              GestureDetector(
                onTap: () {
                  if (video.controller!.value.isPlaying) {
                    video.controller?.pause();
                  } else {
                    video.controller?.play();
                  }
                },
                child: SizedBox.expand(
                    child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: video.controller?.value.size.width ?? 0,
                    height: video.controller?.value.size.height ?? 0,
                    child: VideoPlayer(video.controller!),
                  ),
                )),
              ),
            ]),
          )
        : const Center(
            child: Text('Loading'),
          );
  }

  Widget videoCard2(LikeVideo video) {
    return video.controller != null && video.controller!.value.isInitialized
        ? Stack(children: [
            GestureDetector(
              onTap: () {
                if (video.controller!.value.isPlaying) {
                  video.controller?.pause();
                } else {
                  video.controller?.play();
                }
              },
              child: SizedBox.expand(
                  child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: video.controller?.value.size.width ?? 0,
                  height: video.controller?.value.size.height ?? 0,
                  child: VideoPlayer(video.controller!),
                ),
              )),
            ),
          ])
        : const Center(
            child: Text('Loading'),
          );
  }

  Widget videoCard3(MyVideos video) {
    return video.controller != null && video.controller!.value.isInitialized
        ? Stack(children: [
            GestureDetector(
              onTap: () {
                if (video.controller!.value.isPlaying) {
                  video.controller?.pause();
                } else {
                  video.controller?.play();
                }
              },
              child: SizedBox.expand(
                  child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: video.controller?.value.size.width ?? 0,
                  height: video.controller?.value.size.height ?? 0,
                  child: VideoPlayer(video.controller!),
                ),
              )),
            ),
          ])
        : const Center(
            child: Text('Loading'),
          );
  }
}
