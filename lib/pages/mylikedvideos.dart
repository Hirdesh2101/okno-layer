import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:oknoapp/pages/liked_scroll.dart';
import '../providers/likedvideoprovider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/cache_service.dart';

class MyLikedVideos extends StatefulWidget {
  static const routeName = '/my_likevideos';
  const MyLikedVideos({Key? key}) : super(key: key);

  @override
  _MyLikedVideosState createState() => _MyLikedVideosState();
}

class _MyLikedVideosState extends State<MyLikedVideos> {
  //final locator = GetIt.instance;
  final feedViewModel = GetIt.instance<LikeProvider>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: feedViewModel.videoSource!.listVideos.isEmpty
          ? const Center(
              child: Text('No Liked Videos'),
            )
          : GridView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: feedViewModel.videoSource!.listVideos.length,
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
                      Navigator.of(context).pushNamed(LikeScroll.routeName,
                          arguments: ScreenArguments(index));
                    },
                    child: Card(
                      elevation: 3,
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          color: Colors.grey,
                        ),
                        fit: BoxFit.contain,
                        cacheManager: CustomCacheManager.instance2,
                        imageUrl:
                            feedViewModel.videoSource!.listData[index].product1,
                      ),
                    ));
              },
            ),
    );
  }
}

class ScreenArguments {
  final int indexofgrid;
  ScreenArguments(this.indexofgrid);
}
