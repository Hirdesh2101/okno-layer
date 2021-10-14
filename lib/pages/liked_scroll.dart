import 'package:flutter/material.dart';
import 'package:oknoapp/providers/myvideosprovider.dart';
import './scrollfeed.dart';
import 'package:get_it/get_it.dart';
import '../providers/likedvideoprovider.dart';

class LikeScroll extends StatefulWidget {
  final bool isMyVideo;
  final int indexofgrid;
  static const routeName = '/like_scroll';
  const LikeScroll(this.indexofgrid, this.isMyVideo, {Key? key})
      : super(key: key);

  @override
  _LikeScrollState createState() => _LikeScrollState();
}

class _LikeScrollState extends State<LikeScroll> {
  final feedViewModel = GetIt.instance<LikeProvider>();
  final feedViewModel2 = GetIt.instance<MyVideosProvider>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            if (widget.isMyVideo) {
              await feedViewModel2.pauseDrawer(false, false);
              await feedViewModel2.disposingall(false, false);
            } else {
              await feedViewModel.pauseDrawer();
              await feedViewModel.disposingall();
            }
            return true;
          },
          child: Stack(
            children: [
              if (widget.isMyVideo) ScrollFeed(widget.indexofgrid, false, true),
              if (!widget.isMyVideo)
                ScrollFeed(widget.indexofgrid, true, false),
              Positioned(
                child: Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          if (widget.isMyVideo) {
                            feedViewModel2.disposingall(false, false);
                          } else {
                            feedViewModel.disposingall();
                          }
                          Navigator.of(context).pop();
                        }),
                    const SizedBox(
                      width: 10,
                    ),
                    (widget.isMyVideo)
                        ? const Text('My Creation')
                        : const Text('Liked Videos')
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
