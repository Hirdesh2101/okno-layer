import 'package:flutter/material.dart';
import 'package:oknoapp/models/like_videos.dart';
import '../providers/feedviewprovider.dart';
import 'package:video_player/video_player.dart';
import './videoactiontoolbar.dart';
import 'package:get_it/get_it.dart';
import '../models/video.dart';
import 'package:stacked/stacked.dart';
import '../providers/likedvideoprovider.dart';

class ScrollFeed extends StatefulWidget {
  final int startIndex;
  final bool likedPage;
  const ScrollFeed(this.startIndex, this.likedPage, {Key? key})
      : super(key: key);

  @override
  _ScrollFeedState createState() => _ScrollFeedState();
}

class _ScrollFeedState extends State<ScrollFeed> {
  final feedViewModel = GetIt.instance<FeedViewModel>();
  final feedViewModel2 = GetIt.instance<LikeProvider>();
  @override
  void initState() {
    if (!widget.likedPage) {
      feedViewModel.initial();
    }
    if (widget.likedPage) {
      feedViewModel2.initial(widget.startIndex);
    }
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
        ViewModelBuilder.reactive(
            disposeViewModel: false,
            viewModelBuilder: () =>
                widget.likedPage ? feedViewModel2 : feedViewModel,
            builder: (context, model, child) {
              return !feedViewModel.isBusy && !feedViewModel2.isBusy
                  ? PageView.builder(
                      controller: PageController(
                        initialPage: widget.likedPage ? widget.startIndex : 0,
                        viewportFraction: 1,
                      ),
                      itemCount: widget.likedPage
                          ? feedViewModel2.length()
                          : feedViewModel.length(),
                      onPageChanged: (index) {
                        widget.likedPage
                            ? feedViewModel2.onpageChanged(index)
                            : feedViewModel.onpageChanged(index);
                      },
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return Stack(children: [
                          widget.likedPage
                              ? videoCard2(
                                  feedViewModel2.videoSource!.listData[index])
                              : videoCard(
                                  feedViewModel.videoSource!.listVideos[index]),
                          ActionToolBar(index, widget.likedPage),
                        ]);
                      })
                  : const Center(
                      child: CircularProgressIndicator(),
                    );
            }),
      ],
    );
  }

  Widget videoCard(Video video) {
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
}
