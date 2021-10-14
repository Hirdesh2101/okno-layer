import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:get_it/get_it.dart';
import 'package:stacked/stacked.dart';
import '../../models/brand_videos.dart';
import '../../providers/brand_provider.dart';
import '../videoactiontoolbar.dart';
import 'package:visibility_detector/visibility_detector.dart';

class BrandFeed extends StatefulWidget {
  final int startIndex;
  const BrandFeed(this.startIndex, {Key? key}) : super(key: key);

  @override
  _BrandFeedState createState() => _BrandFeedState();
}

class _BrandFeedState extends State<BrandFeed> {
  final feedViewModel = GetIt.instance<BrandVideoProvider>();
  void init() {
    feedViewModel.initial(widget.startIndex);
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
      initialPage: feedViewModel.currentscreen,
      viewportFraction: 1,
    );
    return Stack(
      children: [
        ViewModelBuilder.reactive(
            disposeViewModel: false,
            viewModelBuilder: () => feedViewModel,
            builder: (context, model, child) {
              return !feedViewModel.isBusy
                  ? PageView.builder(
                      physics: const BouncingScrollPhysics(),
                      controller: pageController,
                      itemCount: feedViewModel.length(),
                      onPageChanged: (index) {
                        feedViewModel.onpageChanged(index);
                      },
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return Stack(children: [
                          videoCard(feedViewModel.videoSource!.listData[index],
                              feedViewModel.videoSource!.listData[index].id),
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

  Widget videoCard(BrandVideos video, var id) {
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
}
