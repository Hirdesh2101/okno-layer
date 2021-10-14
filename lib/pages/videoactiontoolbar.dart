import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:oknoapp/pages/comments.dart';
import 'package:oknoapp/services/dynamic_link.dart';
import '../providers/feedviewprovider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:like_button/like_button.dart';
import './bottomsheet.dart';
import '../firebase functions/sidebar_fun.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/likedvideoprovider.dart';
import 'package:ionicons/ionicons.dart';
import '../constants/themes.dart';
import '../providers/myvideosprovider.dart';
import 'package:share_plus/share_plus.dart';

class ActionToolBar extends StatelessWidget {
  final int index;
  final bool likedPage;
  final bool mypage;
  final BuildContext context;
  ActionToolBar(this.index, this.likedPage, this.mypage, this.context,
      {Key? key})
      : super(key: key);

  final feedViewModel = GetIt.instance<FeedViewModel>();
  final feedViewMode2 = GetIt.instance<LikeProvider>();
  final feedViewMode3 = GetIt.instance<MyVideosProvider>();
  final SideBarFirebase firebaseServices = SideBarFirebase();
  final DynamicLinkService dynamicLinkService = DynamicLinkService();

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
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
          onPressed: () async {
            likedPage || mypage
                ? likedPage
                    ? feedViewMode2.pauseDrawer()
                    : feedViewMode3.pauseDrawer(false, false)
                : feedViewModel.pauseDrawer();
            ProductDetails().sheet(context, index, likedPage, mypage);
            await firebaseServices.viewedProduct(likedPage
                ? feedViewMode2.videoSource!.listVideos[index]
                : feedViewModel.videoSource!.listVideos[index].id.trim());
          },
        ),
      ),
      if (!likedPage && !mypage)
        Positioned(
          right: 0,
          bottom: 0,
          child: sideButtons(),
        )
    ]);
  }

  sideButtons() {
    return Column(children: [
      FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection('VideosData').get(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.085,
              );
            }
            final documents = snapshot.data!.docs.where((element) {
              return element.id ==
                  feedViewModel.videoSource!.listVideos[index].id.trim();
            });
            List<dynamic> list = documents.first['Likes'] ?? [];

            Future<bool> likeFunc(bool init) async {
              firebaseServices.add(
                  likedPage
                      ? feedViewMode2.videoSource!.listVideos[index]
                      : feedViewModel.videoSource!.listVideos[index].id.trim(),
                  list.contains(firebaseServices.user) ? true : false);
              return !init;
            }

            return Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  child: LikeButton(
                    size: MediaQuery.of(context).size.width * 0.085,
                    likeBuilder: (bool isLiked) {
                      return Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked
                            ? Colors.red
                            : Theme.of(context).iconTheme.color,
                        size: MediaQuery.of(context).size.width * 0.085,
                      );
                    },
                    isLiked:
                        list.contains(firebaseServices.user) ? true : false,
                    onTap: likeFunc,
                  ),
                ));
          }),
      IconButton(
          onPressed: () {
            feedViewModel.pauseDrawer();
            Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (context) => Comments(feedViewModel
                        .videoSource!.listVideos[index].id
                        .trim())))
                .then((value) {
              feedViewModel.seekZero();
              feedViewModel.playDrawer();
              // });
            });
          },
          icon: Icon(
            Ionicons.chatbubble_outline,
            size: MediaQuery.of(context).size.width * 0.085,
          )),
      const SizedBox(
        height: 10,
      ),
      IconButton(
          onPressed: () async {
            feedViewModel.pauseDrawer();
            feedViewModel.startCircularProgess();
            Uri uri = await dynamicLinkService
                .createDynamicLink(
                    feedViewModel.videoSource!.listVideos[index].id.trim())
                .whenComplete(() {
              feedViewModel.endCircularProgess();
            });
            await Share.share('Look at this video!${uri.toString()}',
                subject: 'Look at this video!');
          },
          icon: Icon(
            Ionicons.paper_plane_outline,
            size: MediaQuery.of(context).size.width * 0.085,
          )),
      const SizedBox(
        height: 10,
      ),
      IconButton(
          onPressed: () {
            feedViewModel.pauseDrawer();
            showModalBottomSheet(
                context: context,
                barrierColor: Colors.black.withOpacity(0.3),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                elevation: 10,
                builder: (context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0.0, 8, 0, 0),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.01,
                            width: MediaQuery.of(context).size.width * 0.10,
                            decoration: const BoxDecoration(
                                //   color: Colors.grey,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(children: [
                          ListTile(
                            leading: const Icon(Ionicons.bookmark_outline),
                            title: const Text('Save Video'),
                            onTap: () {
                              firebaseServices
                                  .saveVideo(feedViewModel
                                      .videoSource!.listVideos[index].id
                                      .trim())
                                  .whenComplete(() {
                                Fluttertoast.showToast(
                                    msg: "Saved",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    fontSize: 16.0);
                              });
                            },
                          ),
                          ListTile(
                            leading: const Icon(Ionicons.alert_circle_outline),
                            title: const Text('Report Video'),
                            onTap: () {
                              Fluttertoast.showToast(
                                  msg: "Please Wait",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  fontSize: 16.0);
                              firebaseServices
                                  .reportVideo(feedViewModel
                                      .videoSource!.listVideos[index].id
                                      .trim())
                                  .whenComplete(() {
                                Fluttertoast.showToast(
                                    msg: "Reported Successfully",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    fontSize: 16.0);
                              });
                            },
                          ),
                        ]),
                      )
                    ],
                  );
                }).whenComplete(() => feedViewModel.playDrawer());
          },
          icon: Icon(
            Ionicons.ellipsis_vertical_outline,
            size: MediaQuery.of(context).size.width * 0.085,
          )),
    ]);
  }
}
