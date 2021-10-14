import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get_it/get_it.dart';
import '../providers/feedviewprovider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/cache_service.dart';
import '../providers/likedvideoprovider.dart';
import '../providers/myvideosprovider.dart';
import '../services/launch_url.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase functions/sidebar_fun.dart';

class ProductDetails {
  final feedViewModel = GetIt.instance<FeedViewModel>();
  final feedViewModel2 = GetIt.instance<LikeProvider>();
  final feedViewModel3 = GetIt.instance<MyVideosProvider>();
  SideBarFirebase firebasefun = SideBarFirebase();

  Future<String> getname(String id) async {
    return await FirebaseFirestore.instance
        .collection('BrandData')
        .doc(id.trim())
        .get()
        .then((value) {
      return value.data()!['Name'];
    });
  }

  void sheet(context, int index, bool likedVideo, bool myVideo) async {
    showModalBottomSheet(
        context: context,
        //barrierColor: Colors.black.withOpacity(0.3),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 10,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 8, 0, 0),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.01,
                    width: MediaQuery.of(context).size.width * 0.10,
                    decoration: const BoxDecoration(
                        //color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                  ),
                ),
              ),
              const Center(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
                  child: Text(
                    'Products',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
              AnimationLimiter(
                child: Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (ctx, ind) {
                      return AnimationConfiguration.staggeredList(
                        position: ind,
                        duration: const Duration(milliseconds: 800),
                        child: SlideAnimation(
                          horizontalOffset:
                              MediaQuery.of(context).size.width / 2,
                          child: FadeInAnimation(
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(9, 18, 9, 18),
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) => Container(
                                        //color: Colors.grey,
                                        ),
                                    cacheManager: CustomCacheManager.instance2,
                                    imageUrl: likedVideo || myVideo
                                        ? likedVideo
                                            ? feedViewModel2.videoSource!
                                                .listData[index].product1
                                            : feedViewModel3.videoSource!
                                                .listData[index].product1
                                        : feedViewModel.videoSource!
                                            .listVideos[index].product1,
                                    height: MediaQuery.of(context).size.height *
                                        0.2,
                                    width: MediaQuery.of(context).size.height *
                                        0.2,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Text(likedVideo || myVideo
                                    ? likedVideo
                                        ? feedViewModel2
                                            .videoSource!.listData[index].p1name
                                        : feedViewModel3
                                            .videoSource!.listData[index].p1name
                                    : feedViewModel
                                        .videoSource!.listVideos[index].p1name),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                    'Price - ₹${likedVideo || myVideo ? likedVideo ? feedViewModel2.videoSource!.listData[index].price : feedViewModel3.videoSource!.listData[index].price : feedViewModel.videoSource!.listVideos[index].price}'),
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
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: () async {
                          final url = likedVideo || myVideo
                              ? likedVideo
                                  ? feedViewModel2
                                      .videoSource!.listData[index].store
                                  : feedViewModel3
                                      .videoSource!.listData[index].store
                              : feedViewModel
                                  .videoSource!.listVideos[index].store;
                          launchURL(context, url);
                          await firebasefun.viewedUrl(likedVideo
                              ? feedViewModel2.videoSource!.listVideos[index]
                              : feedViewModel.videoSource!.listVideos[index].id
                                  .trim());
                        },
                        child: const Text('Visit Store')),
                  )),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: FutureBuilder(
                    future: getname(likedVideo || myVideo
                        ? likedVideo
                            ? feedViewModel2.videoSource!.listData[index].seller
                            : feedViewModel3.videoSource!.listData[index].seller
                        : feedViewModel.videoSource!.listVideos[index].seller),
                    builder: (context, snapsot) {
                      if (snapsot.connectionState == ConnectionState.waiting) {
                        return const Text('Loading');
                      }
                      return Text(snapsot.data.toString());
                    }),
              ),
            ],
          );
        }).whenComplete(() => likedVideo || myVideo
        ? likedVideo
            ? feedViewModel2.playVideo(index)
            : feedViewModel3.playDrawer(false, false)
        : feedViewModel.playVideo(index));
  }
}
