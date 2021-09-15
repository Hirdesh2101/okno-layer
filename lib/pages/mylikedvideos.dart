import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../providers/feedviewprovider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class MyLikedVideos extends StatefulWidget {
  static const routeName = '/my_likevideos';
  const MyLikedVideos({Key? key}) : super(key: key);

  @override
  _MyLikedVideosState createState() => _MyLikedVideosState();
}

class _MyLikedVideosState extends State<MyLikedVideos> {
  final locator = GetIt.instance;
  final feedViewModel = GetIt.instance<FeedViewModel>();

  late String _tempDir;
  late String filePath;

  void _init() async {
    await getTemporaryDirectory()
        .then((d) => _tempDir = d.path)
        .whenComplete(() {
      setState(() {});
    });
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: GridView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: feedViewModel.length(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 1.5,
          mainAxisSpacing: 1.5,
          childAspectRatio: 0.70,
        ),
        itemBuilder: (
          context,
          index,
        ) {
          return GestureDetector(
              onTap: () {
                //Navigator.of(context).pushNamed(RouteName.GridViewCustom);
              },
              child: FutureBuilder(
                builder: (ctx, snapshot) {
                  if (snapshot.hasData) {
                    final file = File(snapshot.data.toString());
                    filePath = file.path;
                    return FittedBox(fit: BoxFit.fill, child: Image.file(file));
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
                future: VideoThumbnail.thumbnailFile(
                  video: feedViewModel.videoSource!.listVideos[index].url,
                  thumbnailPath: _tempDir,
                  imageFormat: ImageFormat
                      .PNG, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
                  quality: 25,
                ),
              ));
        },
      ),
    );
  }
}
