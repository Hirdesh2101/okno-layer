import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:oknoapp/firebase%20functions/sidebar_fun.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import '../providers/feedviewprovider.dart';
import 'package:video_player/video_player.dart';
import './videoactiontoolbar.dart';
import 'dart:async';
import '../models/video.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../services/dynamic_link.dart';

// ignore: must_be_immutable
class ScrollFeed extends StatefulWidget {
  const ScrollFeed({Key? key}) : super(key: key);

  @override
  _ScrollFeedState createState() => _ScrollFeedState();
}

class _ScrollFeedState extends State<ScrollFeed> {
  final SideBarFirebase firebaseServices = SideBarFirebase();
  final DynamicLinkService _dynamicLinkService = DynamicLinkService();
  bool loadingNotification = false;
  String? dynamicId = '';
  //Stream stream = controller.stream;
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  List<String> countList = [
    "Ethenics",
    "Western",
    "Festive",
    "Casuals",
  ];
  List<String> selectedCountList = [];

  // Future<void> _handleBckground(RemoteMessage remoteMessage) async {}

  final PageController pageController = PageController(
    keepPage: true,
    initialPage: 0,
    viewportFraction: 1,
  );

  void init() async {
    // if (!widget.likedPage && !widget.myVideopage) {
    //   stream.listen((event) {
    //     if (event != '') {
    //       submitFun(List.filled(1, event));
    //     }
    //   });
    // }
    // if (!widget.likedPage && !widget.myVideopage) {
    //   feedViewModel.setBusy(true);
    //   _dynamicLinkService.retrieveDynamicLink(context);
    //   feedViewModel.setBusy(false);
    //   await FirebaseMessaging.instance.getToken();
    //   FirebaseMessaging.onBackgroundMessage(_handleBckground);
    //   // return showDialog(
    //   //     context: context,
    //   //     builder: (context) {
    //   //       return AlertDialog(
    //   //         title: Text(message.notification!.title!),
    //   //         content: Text(message.notification!.body!),
    //   //         actions: [
    //   //           TextButton(onPressed: () {}, child: const Text('Cancel')),
    //   //           TextButton(
    //   //               onPressed: () {
    //   //                 launch(message.data.entries.first.value);
    //   //               },
    //   //               child: const Text('Visit'))
    //   //         ],
    //   //       );
    //   //     });
    //   FirebaseMessaging.onMessage.listen((message) {
    //     if (message.data.isNotEmpty) {
    //       showDialog(
    //           context: context,
    //           builder: (context) {
    //             if (!widget.likedPage && !widget.myVideopage) {
    //               feedViewModel.pauseDrawer();
    //             }
    //             if (widget.likedPage) {
    //               feedViewModel2.pauseDrawer();
    //             }
    //             if (widget.myVideopage) {
    //               feedViewModel3.pauseDrawer(false, false);
    //             }
    //             return Dialog(
    //                 shape: RoundedRectangleBorder(
    //                     borderRadius: BorderRadius.circular(20.0)),
    //                 child: Column(
    //                   mainAxisSize: MainAxisSize.min,
    //                   children: [
    //                     if (message.data.entries.last.key == 'image')
    //                       Padding(
    //                         padding: const EdgeInsets.all(8.0),
    //                         child:
    //                             Image.network(message.data.entries.last.value),
    //                       ),
    //                     Text(
    //                       message.notification!.title!,
    //                       style: const TextStyle(
    //                           fontSize: 20, fontWeight: FontWeight.bold),
    //                     ),
    //                     Padding(
    //                       padding: const EdgeInsets.fromLTRB(8.0, 4, 8, 8),
    //                       child: Text(message.notification!.body!),
    //                     ),
    //                     Row(
    //                       mainAxisAlignment: MainAxisAlignment.end,
    //                       children: [
    //                         TextButton(
    //                             onPressed: () {
    //                               Navigator.of(context).pop();
    //                             },
    //                             child: const Text('Cancel')),
    //                         TextButton(
    //                             onPressed: () async {
    //                               await submitFun(List.filled(
    //                                   1, message.data.entries.first.value));
    //                               // await launchURL(
    //                               //   context,
    //                               // );
    //                               Navigator.of(context).pop();
    //                             },
    //                             child: const Text('Visit'))
    //                       ],
    //                     )
    //                   ],
    //                 ));
    //           }).whenComplete(() {
    //         if (!widget.likedPage && !widget.myVideopage) {
    //           feedViewModel.playDrawer();
    //         }
    //         if (widget.likedPage) {
    //           feedViewModel2.playDrawer();
    //         }
    //         if (widget.myVideopage) {
    //           feedViewModel3.playDrawer(false, false);
    //         }
    //       });
    //     }
    //   });
    //   FirebaseMessaging.onMessageOpenedApp.listen((message) {
    //     if (message.data.isNotEmpty) {
    //       showDialog(
    //           context: context,
    //           builder: (context) {
    //             if (!widget.likedPage && !widget.myVideopage) {
    //               feedViewModel.pauseDrawer();
    //             }
    //             if (widget.likedPage) {
    //               feedViewModel2.pauseDrawer();
    //             }
    //             if (widget.myVideopage) {
    //               feedViewModel3.pauseDrawer(false, false);
    //             }
    //             return Dialog(
    //                 shape: RoundedRectangleBorder(
    //                     borderRadius: BorderRadius.circular(20.0)),
    //                 child: Column(
    //                   mainAxisSize: MainAxisSize.min,
    //                   children: [
    //                     if (message.data.entries.last.key == 'image')
    //                       Padding(
    //                         padding: const EdgeInsets.all(8.0),
    //                         child:
    //                             Image.network(message.data.entries.last.value),
    //                       ),
    //                     Text(
    //                       message.notification!.title!,
    //                       style: const TextStyle(
    //                           fontSize: 20, fontWeight: FontWeight.bold),
    //                     ),
    //                     Padding(
    //                       padding: const EdgeInsets.fromLTRB(8.0, 4, 8, 8),
    //                       child: Text(message.notification!.body!),
    //                     ),
    //                     Row(
    //                       mainAxisAlignment: MainAxisAlignment.end,
    //                       children: [
    //                         TextButton(
    //                             onPressed: () {
    //                               Navigator.of(context).pop();
    //                             },
    //                             child: const Text('Cancel')),
    //                         TextButton(
    //                             onPressed: () async {
    //                               await submitFun(List.filled(
    //                                   1, message.data.entries.first.value));
    //                               // await launchURL(
    //                               //   context,
    //                               // );
    //                               Navigator.of(context).pop();
    //                             },
    //                             child: const Text('Visit'))
    //                       ],
    //                     )
    //                   ],
    //                 ));
    //           }).whenComplete(() {
    //         if (!widget.likedPage && !widget.myVideopage) {
    //           feedViewModel.playDrawer();
    //         }
    //         if (widget.likedPage) {
    //           feedViewModel2.playDrawer();
    //         }
    //         if (widget.myVideopage) {
    //           feedViewModel3.playDrawer(false, false);
    //         }
    //       });
    //     }
    //   });
    //   _firebaseMessaging.getInitialMessage().then((message) {
    //     if (message != null) {
    //       return showDialog(
    //           context: context,
    //           builder: (context) {
    //             if (!widget.likedPage && !widget.myVideopage) {
    //               feedViewModel.pauseDrawer();
    //             }
    //             if (widget.likedPage) {
    //               feedViewModel2.pauseDrawer();
    //             }
    //             if (widget.myVideopage) {
    //               feedViewModel3.pauseDrawer(false, false);
    //             }
    //             return Dialog(
    //                 shape: RoundedRectangleBorder(
    //                     borderRadius: BorderRadius.circular(20.0)),
    //                 child: Column(
    //                   mainAxisSize: MainAxisSize.min,
    //                   children: [
    //                     if (message.data.entries.last.key == 'image')
    //                       Padding(
    //                         padding: const EdgeInsets.all(8.0),
    //                         child:
    //                             Image.network(message.data.entries.last.value),
    //                       ),
    //                     Text(
    //                       message.notification!.title!,
    //                       style: const TextStyle(
    //                           fontSize: 20, fontWeight: FontWeight.bold),
    //                     ),
    //                     Padding(
    //                       padding: const EdgeInsets.fromLTRB(8.0, 4, 8, 8),
    //                       child: Text(message.notification!.body!),
    //                     ),
    //                     Row(
    //                       mainAxisAlignment: MainAxisAlignment.end,
    //                       children: [
    //                         TextButton(
    //                             onPressed: () {
    //                               Navigator.of(context).pop();
    //                             },
    //                             child: const Text('Cancel')),
    //                         TextButton(
    //                             onPressed: () async {
    //                               await submitFun(List.filled(
    //                                   1, message.data.entries.first.value));
    //                               // await launchURL(
    //                               //   context,
    //                               // );
    //                               Navigator.of(context).pop();
    //                             },
    //                             child: const Text('Visit'))
    //                       ],
    //                     )
    //                   ],
    //                 ));
    //           }).whenComplete(() {
    //         if (!widget.likedPage && !widget.myVideopage) {
    //           feedViewModel.playDrawer();
    //         }
    //         if (widget.likedPage) {
    //           feedViewModel2.playDrawer();
    //         }
    //         if (widget.myVideopage) {
    //           feedViewModel3.playDrawer(false, false);
    //         }
    //       });
    //     }
    //   });
    //}
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    final model = Provider.of<FeedViewModel>(context, listen: false);
    model.disposingall();
    pageController.dispose();
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
    return Stack(
      children: [
        Consumer<FeedViewModel>(builder: (context, feedViewModel, child) {
          return !feedViewModel.isBusy
              ? feedViewModel.listVideos.isEmpty
                  ? RefreshIndicator(
                      onRefresh: () {
                        feedViewModel.delete();
                        return feedViewModel.load(0).then((val) {
                          init();
                          setState(() {});
                        });
                      },
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
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
                      itemCount: feedViewModel.length(),
                      onPageChanged: (index) {
                        feedViewModel.onpageChanged(index);
                      },
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return Stack(children: [
                          Align(
                            alignment: AlignmentDirectional.bottomCenter,
                            child: videoCard(feedViewModel.listVideos[index],
                                feedViewModel.listVideos[index].id),
                          ),
                          ActionToolBar(
                            index,
                            context,
                            countList,
                            selectedCountList,
                          ),
                          feedViewModel.creatingLink!
                              ? const Center(child: CircularProgressIndicator())
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
    final feedViewModel = Provider.of<FeedViewModel>(context, listen: false);
    return video.controller != null && video.controller!.value.isInitialized
        ? VisibilityDetector(
            key: Key(video.id),
            onVisibilityChanged: (info) {
              var visiblePercentage = info.visibleFraction * 100;
              if (visiblePercentage < 50) {
                if (video.controller!.value.isPlaying) {
                  feedViewModel.pauseDrawer();
                }
              } else {
                if (!video.controller!.value.isPlaying) {
                  if (Scaffold.of(context).isDrawerOpen) {
                    feedViewModel.pauseDrawer();
                  } else {
                    feedViewModel.playDrawer();
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
}
