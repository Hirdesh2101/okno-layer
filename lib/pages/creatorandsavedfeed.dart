import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:get_it/get_it.dart';
import 'package:stacked/stacked.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../providers/savedvideoprovider.dart';
import '../providers/myvideosprovider.dart';
import '../models/my_saved.dart';
import '../models/my_videos.dart';

class CreatorAndSavedFeed extends StatefulWidget {
  final int startIndex;
  final bool isSavedVideo;
  final bool isApproved;
  final bool isNonApproved;
  const CreatorAndSavedFeed(
      this.startIndex, this.isSavedVideo, this.isApproved, this.isNonApproved,
      {Key? key})
      : super(key: key);

  @override
  _CreatorAndSavedFeedState createState() => _CreatorAndSavedFeedState();
}

class _CreatorAndSavedFeedState extends State<CreatorAndSavedFeed> {
  final feedViewModel = GetIt.instance<MySavedVideosProvider>();
  final feedViewModel2 = GetIt.instance<MyVideosProvider>();
  void init() {
    if (widget.isSavedVideo) {
      feedViewModel.initial(widget.startIndex);
    } else {
      if (widget.isApproved) {
        feedViewModel2.initial(widget.startIndex, true, false);
      } else {
        feedViewModel2.initial(widget.startIndex, false, true);
      }
    }
  }

  @override
  void initState() {
    init();
    super.initState();
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
      initialPage: widget.isSavedVideo
          ? feedViewModel.currentscreen
          : feedViewModel2.currentscreen,
      viewportFraction: 1,
    );
    return Stack(
      children: [
        ViewModelBuilder.reactive(
            disposeViewModel: false,
            viewModelBuilder: () =>
                widget.isSavedVideo ? feedViewModel : feedViewModel2,
            builder: (context, model, child) {
              return !feedViewModel.isBusy || !feedViewModel2.isBusy
                  ? PageView.builder(
                      physics: const BouncingScrollPhysics(),
                      controller: pageController,
                      itemCount: widget.isSavedVideo
                          ? feedViewModel.length()
                          : widget.isApproved
                              ? feedViewModel2.videoSource!.approvedData.length
                              : feedViewModel2
                                  .videoSource!.nonapprovedData.length,
                      onPageChanged: (index) {
                        widget.isSavedVideo
                            ? feedViewModel.onpageChanged(index)
                            : widget.isApproved
                                ? feedViewModel2.onpageChanged(
                                    index, true, false)
                                : feedViewModel2.onpageChanged(
                                    index, false, true);
                      },
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return Stack(children: [
                          widget.isSavedVideo
                              ? videoCard(
                                  feedViewModel.videoSource!.listData[index],
                                  feedViewModel.videoSource!.listData[index].id)
                              : widget.isApproved
                                  ? videoCard2(
                                      feedViewModel2
                                          .videoSource!.approvedData[index],
                                      feedViewModel2
                                          .videoSource!.approvedData[index].id)
                                  : videoCard2(
                                      feedViewModel2
                                          .videoSource!.nonapprovedData[index],
                                      feedViewModel2.videoSource!
                                          .nonapprovedData[index].id)
                          // ActionToolBar(index, false, false, context),
                        ]);
                      })
                  : const Center(
                      child: CircularProgressIndicator(),
                    );
            }),
      ],
    );
  }

  Widget videoCard(MySavedVideos video, var id) {
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

  Widget videoCard2(MyVideos video, var id) {
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
