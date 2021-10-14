import 'package:flutter/material.dart';
import 'package:oknoapp/pages/creatorandsavedfeed.dart';
import 'package:oknoapp/providers/myvideosprovider.dart';
import 'package:oknoapp/providers/savedvideoprovider.dart';
import 'package:get_it/get_it.dart';

class CreatorandSavedScroll extends StatefulWidget {
  final bool isSavedVideo;
  final bool isapproved;
  final bool isnonapproved;
  final int indexofgrid;
  const CreatorandSavedScroll(
      this.indexofgrid, this.isSavedVideo, this.isapproved, this.isnonapproved,
      {Key? key})
      : super(key: key);

  @override
  _CreatorandSavedScrollState createState() => _CreatorandSavedScrollState();
}

class _CreatorandSavedScrollState extends State<CreatorandSavedScroll> {
  final feedViewModel = GetIt.instance<MyVideosProvider>();
  final feedViewModel2 = GetIt.instance<MySavedVideosProvider>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            if (widget.isSavedVideo) {
              await feedViewModel2.pauseDrawer();
              await feedViewModel2.disposingall();
            } else {
              if (widget.isapproved) {
                await feedViewModel.pauseDrawer(true, false);
                await feedViewModel.disposingall(true, false);
              } else {
                await feedViewModel.pauseDrawer(false, true);
                await feedViewModel.disposingall(false, true);
              }
            }
            return true;
          },
          child: Stack(
            children: [
              if (widget.isSavedVideo)
                CreatorAndSavedFeed(widget.indexofgrid, true, false, false),
              if (widget.isapproved)
                CreatorAndSavedFeed(widget.indexofgrid, false, true, false),
              if (widget.isnonapproved)
                CreatorAndSavedFeed(widget.indexofgrid, false, false, true),
              Positioned(
                child: Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          if (widget.isSavedVideo) {
                            feedViewModel2.disposingall();
                          } else {
                            if (widget.isapproved) {
                              feedViewModel.disposingall(true, false);
                            } else {
                              feedViewModel.disposingall(false, true);
                            }
                          }
                          Navigator.of(context).pop();
                        }),
                    const SizedBox(
                      width: 10,
                    ),
                    (widget.isSavedVideo)
                        ? const Text('SavedVideo')
                        : const Text('My Creations')
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
