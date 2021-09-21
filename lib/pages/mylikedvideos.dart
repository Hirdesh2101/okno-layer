import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:oknoapp/pages/liked_scroll.dart';
import '../providers/likedvideoprovider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/cache_service.dart';
import 'package:stacked/stacked.dart';
import '../firebase functions/sidebar_fun.dart';

class MyLikedVideos extends StatefulWidget {
  static const routeName = '/my_likevideos';
  const MyLikedVideos({Key? key}) : super(key: key);

  @override
  _MyLikedVideosState createState() => _MyLikedVideosState();
}

class _MyLikedVideosState extends State<MyLikedVideos> {
  //final locator = GetIt.instance;
  final feedViewModel = GetIt.instance<LikeProvider>();
  final SideBarFirebase firebaseServices = SideBarFirebase();

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
          : ViewModelBuilder.reactive(
              disposeViewModel: false,
              viewModelBuilder: () => feedViewModel,
              builder: (context, model, child) {
                return GridView.builder(
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
                          child: Stack(
                            children: [
                              SizedBox.expand(
                                //fit: FlexFit.tight,
                                // fit: BoxFit.fill,
                                child: FittedBox(
                                  fit: BoxFit.fill,
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey,
                                    ),
                                    fit: BoxFit.fill,
                                    cacheManager: CustomCacheManager.instance2,
                                    imageUrl: feedViewModel
                                        .videoSource!.listData[index].product1,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                child: PopupMenuButton(
                                  itemBuilder: (BuildContext context) {
                                    return <PopupMenuEntry>[
                                      const PopupMenuItem(
                                        child: Text('Remove'),
                                        value: 1,
                                      ),
                                    ];
                                  },
                                  onSelected: (value) async {
                                    if (value == 1) {
                                      await firebaseServices
                                          .add(
                                              feedViewModel.videoSource!
                                                  .listVideos[index],
                                              true)
                                          .whenComplete(
                                              () => feedViewModel.refresh());
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ));
                  },
                );
              }),
    );
  }
}

class ScreenArguments {
  final int indexofgrid;
  ScreenArguments(this.indexofgrid);
}
