import 'package:flutter/material.dart';
import '../providers/feedviewprovider.dart';
import 'package:video_player/video_player.dart';
import './videoactiontoolbar.dart';
import 'package:get_it/get_it.dart';
import '../data/video.dart';

import 'package:stacked/stacked.dart';

class ScrollFeed extends StatefulWidget {
  const ScrollFeed({Key? key}) : super(key: key);

  @override
  _ScrollFeedState createState() => _ScrollFeedState();
}

class _ScrollFeedState extends State<ScrollFeed> {
  final locator = GetIt.instance;
  final feedViewModel = GetIt.instance<FeedViewModel>();
  @override
  void initState() {
    feedViewModel.initial();
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
    return Stack(
      children: [
        PageView.builder(
          controller: PageController(
            initialPage: 0,
            viewportFraction: 1,
          ),
          itemCount: feedViewModel.length(),
          onPageChanged: (index) {
            feedViewModel.onpageChanged(index);
          },
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            return Stack(children: [
              videoCard(feedViewModel.videoSource!.listVideos[index]),
              ActionToolBar(index),
            ]);
          },
        ),
      ],
    );
  }

  Widget videoCard(Video video) {
    return ViewModelBuilder<FeedViewModel>.reactive(
        disposeViewModel: false,
        viewModelBuilder: () => feedViewModel,
        builder: (context, model, child) =>
            video.controller != null && video.controller!.value.isInitialized
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
                    if (video.controller!.value.isBuffering)
                      const Center(
                        child: CircularProgressIndicator(),
                      )
                  ])
                : const Center(
                    child: Text('Loading'),
                  ));
  }
}
