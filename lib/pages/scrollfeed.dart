import 'package:flutter/material.dart';
import '../models/feedviewmodel.dart';
import 'package:video_player/video_player.dart';
import './videoactiontoolbar.dart';
import 'package:get_it/get_it.dart';
import '../data/video.dart';

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
            //index = index % (feedViewModel.videoSource!.listVideos.length);
            feedViewModel.onpageChanged(index);
          },
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            //index = index % (feedViewModel.videoSource!.listVideos.length);
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
    return video.controller != null
        ? Stack(
            children: [
              video.controller != null
                  ? GestureDetector(
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
                    )
                  : Container(
                      color: Colors.black,
                      child: const Center(
                        child: Text(
                          "Loading",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
            ],
          )
        : const Center(
            child: Text('Wait'),
          );
  }
}
