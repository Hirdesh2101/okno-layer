import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../providers/likedvideoprovider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import '../data/liked_firebase.dart';

class MyLikedVideos extends StatefulWidget {
  static const routeName = '/my_likevideos';
  const MyLikedVideos({Key? key}) : super(key: key);

  @override
  _MyLikedVideosState createState() => _MyLikedVideosState();
}

class _MyLikedVideosState extends State<MyLikedVideos> {
  //final locator = GetIt.instance;
  final feedViewModel = GetIt.instance<LikeProvider>();

  late String _tempDir;
  late String filePath;
  LikedVideosAPI? likedVideosAPI;

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
    likedVideosAPI = LikedVideosAPI();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: GridView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: feedViewModel.likedVideosAPI!.listVideos.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 1.5,
          mainAxisSpacing: 1.5,
          childAspectRatio: 9 / 15,
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
                    return FittedBox(
                        fit: BoxFit.fill,
                        child: Card(elevation: 3, child: Image.file(file)));
                  }
                  return Card(
                    elevation: 3,
                    child: Container(
                      color: Colors.grey,
                    ),
                  );
                },
                future: VideoThumbnail.thumbnailFile(
                  video:
                      'https://firebasestorage.googleapis.com/v0/b/okno-1ae24.appspot.com/o/Videos%2F1.mp4?alt=media&token=f6772532-7fc0-48c1-a876-5e174d1eea4a',
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
