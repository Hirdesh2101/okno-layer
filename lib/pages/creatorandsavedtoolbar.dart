import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:oknoapp/pages/comments.dart';
import 'package:oknoapp/services/dynamic_link.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:like_button/like_button.dart';
import '../firebase functions/sidebar_fun.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/savedvideoprovider.dart';
import 'package:ionicons/ionicons.dart';
import '../providers/myvideosprovider.dart';
import 'package:share_plus/share_plus.dart';
import './creatorandsavedbottomsheet.dart';

class CreatorandSavedActionToolBar extends StatelessWidget {
  final int index;
  final bool isSavedVideo;
  final bool isApproved;
  final bool isNonApproved;
  final BuildContext context;
  CreatorandSavedActionToolBar(this.index, this.isSavedVideo, this.isApproved,
      this.isNonApproved, this.context,
      {Key? key})
      : super(key: key);
  final feedViewModel = GetIt.instance<MySavedVideosProvider>();
  final feedViewModel2 = GetIt.instance<MyVideosProvider>();
  final SideBarFirebase firebaseServices = SideBarFirebase();
  final DynamicLinkService dynamicLinkService = DynamicLinkService();
  //List<String>? selectedCountList = [];

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      isNonApproved
          ? const Padding(
              padding: EdgeInsets.all(10.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text('Approval Pending'),
              ),
            )
          : Align(
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
                  isSavedVideo
                      ? feedViewModel.pauseDrawer()
                      : feedViewModel2.pauseDrawer(true, false);

                  CreatorAndSavedProductDetails().sheet(
                      context, index, isApproved, isNonApproved, isSavedVideo);
                  // ProductDetails()
                  //     .sheet(context, index, likedPage, mypage, filterScreen);
                  if (isSavedVideo) {
                    await firebaseServices.viewedProduct(
                        feedViewModel.videoSource!.listData[index].id.trim());
                  }
                },
              ),
            ),
      if (!isNonApproved)
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
              return isSavedVideo
                  ? element.id ==
                      feedViewModel.videoSource!.listData[index].id.trim()
                  : element.id ==
                      feedViewModel2.videoSource!.approvedData[index].id.trim();
            });
            List<dynamic> list = documents.first['Likes'] ?? [];

            Future<bool> likeFunc(bool init) async {
              firebaseServices.add(
                  isSavedVideo
                      ? feedViewModel.videoSource!.listData[index].id
                      : feedViewModel2.videoSource!.approvedData[index].id
                          .trim(),
                  list.contains(firebaseServices.user) ? true : false);
              return !init;
            }

            return Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  child: LikeButton(
                    size: MediaQuery.of(context).size.width * 0.1,
                    likeBuilder: (bool isLiked) {
                      return Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.white,
                        size: MediaQuery.of(context).size.width * 0.1,
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
            isSavedVideo
                ? feedViewModel.pauseDrawer()
                : feedViewModel2.pauseDrawer(true, false);
            Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (context) => Comments(isSavedVideo
                        ? feedViewModel.videoSource!.listData[index].id.trim()
                        : feedViewModel2.videoSource!.approvedData[index].id
                            .trim())))
                .then((value) {
              if (isSavedVideo) {
                feedViewModel.seekZero();
                feedViewModel.playDrawer();
              } else {
                feedViewModel2.seekZero(true);
                feedViewModel2.playDrawer(true, false);
              }
              // });
            });
          },
          icon: Icon(
            Ionicons.chatbubble_outline,
            color: Colors.white,
            size: MediaQuery.of(context).size.width * 0.085,
          )),
      const SizedBox(
        height: 10,
      ),
      IconButton(
          onPressed: () async {
            if (isSavedVideo) {
              feedViewModel.pauseDrawer();
              //feedViewModel.startCircularProgess();
              Uri uri = await dynamicLinkService
                  .createDynamicLink(
                      feedViewModel.videoSource!.listData[index].id.trim())
                  .whenComplete(() {
                //feedViewModel.endCircularProgess();
              });
              await Share.share('Look at this video!${uri.toString()}',
                  subject: 'Look at this video!');
            } else {
              feedViewModel2.pauseDrawer(true, false);
              //feedViewModel.startCircularProgess();
              Uri uri = await dynamicLinkService
                  .createDynamicLink(
                      feedViewModel2.videoSource!.approvedData[index].id.trim())
                  .whenComplete(() {
                // feedViewModel.endCircularProgess();
              });
              await Share.share('Look at this video!${uri.toString()}',
                  subject: 'Look at this video!');
            }
          },
          icon: Icon(
            Ionicons.paper_plane_outline,
            color: Colors.white,
            size: MediaQuery.of(context).size.width * 0.085,
          )),
      const SizedBox(
        height: 10,
      ),
      IconButton(
          onPressed: () {
            if (isSavedVideo) {
              feedViewModel.pauseDrawer();
            } else {
              feedViewModel2.pauseDrawer(true, false);
            }
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
                                color: Colors.grey,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(children: [
                          if (!isSavedVideo)
                            ListTile(
                              leading: const Icon(Ionicons.bookmark_outline),
                              title: const Text('Save Video'),
                              onTap: () {
                                firebaseServices
                                    .saveVideo(feedViewModel2
                                        .videoSource!.approvedData[index].id
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
                                  .reportVideo(isSavedVideo
                                      ? feedViewModel
                                          .videoSource!.listData[index].id
                                          .trim()
                                      : feedViewModel2
                                          .videoSource!.approvedData[index].id
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
                      ),
                    ],
                  );
                }).whenComplete(() {
              isSavedVideo
                  ? feedViewModel.playDrawer()
                  : feedViewModel2.playDrawer(true, false);
            });
          },
          icon: Icon(
            Ionicons.ellipsis_vertical_outline,
            color: Colors.white,
            size: MediaQuery.of(context).size.width * 0.085,
          )),
    ]);
  }
}
