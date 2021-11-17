import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oknoapp/firebase%20functions/sidebar_fun.dart';
import 'package:oknoapp/models/like_videos.dart';
import 'package:oknoapp/models/my_videos.dart';
import 'package:oknoapp/providers/myvideosprovider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../providers/feedviewprovider.dart';
import 'package:video_player/video_player.dart';
import './videoactiontoolbar.dart';
import 'package:get_it/get_it.dart';
import 'dart:async';
import '../services/dynamic_linkstream.dart';
import 'package:ionicons/ionicons.dart';
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
  bool homepressed;
  ScrollFeed(
      this.startIndex, this.likedPage, this.myVideopage, this.homepressed,
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
  bool loadingNotification = false;
  bool filterRunning = false;
  String? dynamicId = '';
  Stream stream = controller.stream;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
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

  Future<void> removeFilter() async {
    if (filterRunning) {
      setState(() {
        filterVideoView = false;
        filterRunning = false;
      });

      selectedCountList.clear();
      await feedViewModel.initial();
      await feedViewModel4.disposingall();
      feedViewModel.playDrawer();
    }
    widget.homepressed = false;
  }

  Future<void> _handleBckground(RemoteMessage remoteMessage) async {}
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
      feedViewModel4.currentscreen = 0;
      await feedViewModel4.initial(list);
    } else {
      feedViewModel.currentscreen = 0;
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
    if (!widget.likedPage && !widget.myVideopage) {
      stream.listen((event) {
        if (event != '') {
          submitFun(List.filled(1, event));
        }
      });
    }
    if (!widget.likedPage && !widget.myVideopage) {
      feedViewModel.initial();
    }
    if (widget.likedPage) {
      feedViewModel2.initial(widget.startIndex);
    }
    if (widget.myVideopage) {
      feedViewModel3.initial(widget.startIndex, false, false);
    }
    if (!widget.likedPage && !widget.myVideopage) {
      feedViewModel.setBusy(true);
      _dynamicLinkService.retrieveDynamicLink(context);
      feedViewModel.setBusy(false);
      await FirebaseMessaging.instance.getToken();
      FirebaseMessaging.onBackgroundMessage(_handleBckground);
      // return showDialog(
      //     context: context,
      //     builder: (context) {
      //       return AlertDialog(
      //         title: Text(message.notification!.title!),
      //         content: Text(message.notification!.body!),
      //         actions: [
      //           TextButton(onPressed: () {}, child: const Text('Cancel')),
      //           TextButton(
      //               onPressed: () {
      //                 launch(message.data.entries.first.value);
      //               },
      //               child: const Text('Visit'))
      //         ],
      //       );
      //     });
      FirebaseMessaging.onMessage.listen((message) {
        if (message.data.isNotEmpty) {
          showDialog(
              context: context,
              builder: (context) {
                if (!widget.likedPage && !widget.myVideopage) {
                  feedViewModel.pauseDrawer();
                }
                if (widget.likedPage) {
                  feedViewModel2.pauseDrawer();
                }
                if (widget.myVideopage) {
                  feedViewModel3.pauseDrawer(false, false);
                }
                return Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (message.data.entries.last.key == 'image')
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child:
                                Image.network(message.data.entries.last.value),
                          ),
                        Text(
                          message.notification!.title!,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 4, 8, 8),
                          child: Text(message.notification!.body!),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel')),
                            TextButton(
                                onPressed: () async {
                                  await submitFun(List.filled(
                                      1, message.data.entries.first.value));
                                  // await launchURL(
                                  //   context,
                                  // );
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Visit'))
                          ],
                        )
                      ],
                    ));
              }).whenComplete(() {
            if (!widget.likedPage && !widget.myVideopage) {
              feedViewModel.playDrawer();
            }
            if (widget.likedPage) {
              feedViewModel2.playDrawer();
            }
            if (widget.myVideopage) {
              feedViewModel3.playDrawer(false, false);
            }
          });
        }
      });
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        if (message.data.isNotEmpty) {
          showDialog(
              context: context,
              builder: (context) {
                if (!widget.likedPage && !widget.myVideopage) {
                  feedViewModel.pauseDrawer();
                }
                if (widget.likedPage) {
                  feedViewModel2.pauseDrawer();
                }
                if (widget.myVideopage) {
                  feedViewModel3.pauseDrawer(false, false);
                }
                return Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (message.data.entries.last.key == 'image')
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child:
                                Image.network(message.data.entries.last.value),
                          ),
                        Text(
                          message.notification!.title!,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 4, 8, 8),
                          child: Text(message.notification!.body!),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel')),
                            TextButton(
                                onPressed: () async {
                                  await submitFun(List.filled(
                                      1, message.data.entries.first.value));
                                  // await launchURL(
                                  //   context,
                                  // );
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Visit'))
                          ],
                        )
                      ],
                    ));
              }).whenComplete(() {
            if (!widget.likedPage && !widget.myVideopage) {
              feedViewModel.playDrawer();
            }
            if (widget.likedPage) {
              feedViewModel2.playDrawer();
            }
            if (widget.myVideopage) {
              feedViewModel3.playDrawer(false, false);
            }
          });
        }
      });
      _firebaseMessaging.getInitialMessage().then((message) {
        if (message != null) {
          return showDialog(
              context: context,
              builder: (context) {
                if (!widget.likedPage && !widget.myVideopage) {
                  feedViewModel.pauseDrawer();
                }
                if (widget.likedPage) {
                  feedViewModel2.pauseDrawer();
                }
                if (widget.myVideopage) {
                  feedViewModel3.pauseDrawer(false, false);
                }
                return Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (message.data.entries.last.key == 'image')
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child:
                                Image.network(message.data.entries.last.value),
                          ),
                        Text(
                          message.notification!.title!,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 4, 8, 8),
                          child: Text(message.notification!.body!),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel')),
                            TextButton(
                                onPressed: () async {
                                  await submitFun(List.filled(
                                      1, message.data.entries.first.value));
                                  // await launchURL(
                                  //   context,
                                  // );
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Visit'))
                          ],
                        )
                      ],
                    ));
              }).whenComplete(() {
            if (!widget.likedPage && !widget.myVideopage) {
              feedViewModel.playDrawer();
            }
            if (widget.likedPage) {
              feedViewModel2.playDrawer();
            }
            if (widget.myVideopage) {
              feedViewModel3.playDrawer(false, false);
            }
          });
        }
      });
    }
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
    if (widget.homepressed) {
      removeFilter();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        kIsWeb &&
                (defaultTargetPlatform == TargetPlatform.windows ||
                    defaultTargetPlatform == TargetPlatform.macOS ||
                    defaultTargetPlatform == TargetPlatform.linux)
            ? Expanded(
                child: AspectRatio(aspectRatio: 9 / 16, child: feedVideos()),
              )
            : Expanded(child: feedVideos()),
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
                                physics: const BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics()),
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.height,
                                  child: Center(
                                    child: kIsWeb &&
                                            (defaultTargetPlatform ==
                                                    TargetPlatform.windows ||
                                                defaultTargetPlatform ==
                                                    TargetPlatform.macOS ||
                                                defaultTargetPlatform ==
                                                    TargetPlatform.linux)
                                        ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                  'You Are All Caught Up'),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              IconButton(
                                                  onPressed: () {
                                                    feedViewModel.videoSource!
                                                        .delete();
                                                    feedViewModel.videoSource!
                                                        .load(0)
                                                        .then((val) {
                                                      init();
                                                      setState(() {});
                                                    });
                                                  },
                                                  icon: const Icon(
                                                      Ionicons.refresh_outline))
                                            ],
                                          )
                                        : Column(
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
                behavior: HitTestBehavior.opaque,
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
