import 'package:flutter/material.dart';
import '../models/feedviewmodel.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
              Align(
                alignment: Alignment.bottomCenter,
                child: OutlinedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (states) => Colors.black.withOpacity(0.5))),
                  child: const Text(
                    'View Product',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    feedViewModel.pauseVideo(index);
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
                                  child: Text(
                                    'Products',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: AnimationLimiter(
                                  child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (ctx, ind) {
                                      return AnimationConfiguration
                                          .staggeredList(
                                        position: ind,
                                        duration:
                                            const Duration(milliseconds: 800),
                                        child: SlideAnimation(
                                          horizontalOffset:
                                              MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2,
                                          child: FadeInAnimation(
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          9, 18, 9, 18),
                                                  child: Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .height,
                                                    constraints:
                                                        const BoxConstraints(
                                                            maxHeight: 140,
                                                            minWidth: 140),
                                                    child: Image.network(
                                                        feedViewModel
                                                            .videoSource!
                                                            .listVideos[index]
                                                            .product1),
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                Text(
                                                    'Product name -${feedViewModel.videoSource!.listVideos[index].seller}'),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                    'Product price -${feedViewModel.videoSource!.listVideos[index].price}')
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    itemCount: 1,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                  onPressed: () {},
                                  child: const Text('Visit Store'))
                            ],
                          );
                        }).whenComplete(() => feedViewModel.playVideo(index));
                  },
                ),
              ),
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
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    //children: <Widget>[
                    //VideoDescription(video.user,video.videoTitle,video.songName),
                    //ActionsToolbar(video.likes, video.comments,
                    //  "https://www.andersonsobelcosmetic.com/wp-content/uploads/2018/09/chin-implant-vs-fillers-best-for-improving-profile-bellevue-washington-chin-surgery.jpg"),
                    //  ],
                  ),
                  const SizedBox(height: 20)
                ],
              ),
            ],
          )
        : const Center(
            child: Text('Wait'),
          );
  }
}
