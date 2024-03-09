import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oknoapp/pages/comments.dart';
import 'package:oknoapp/services/dynamic_link.dart';
import 'package:provider/provider.dart';
import '../providers/feedviewprovider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:like_button/like_button.dart';
import './bottomsheet.dart';
import '../firebase functions/sidebar_fun.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ionicons/ionicons.dart';
import 'package:share_plus/share_plus.dart';

class ActionToolBar extends StatefulWidget {
  final int index;
  final List<String> countList;
  final List<String> selectedCountList;
  final BuildContext context;
  final bool showProduct;
  const ActionToolBar(
      this.index, this.context, this.countList, this.selectedCountList,this.showProduct,
      {Key? key})
      : super(key: key);

  @override
  State<ActionToolBar> createState() => _ActionToolBarState();
}

class _ActionToolBarState extends State<ActionToolBar> {

  final SideBarFirebase firebaseServices = SideBarFirebase();

  final DynamicLinkService dynamicLinkService = DynamicLinkService();
  FirebaseApp otherFirebase = Firebase.app('okno');

  bool _status = true;

  @override
  Widget build(BuildContext context) {
    final feedViewModel = Provider.of<FeedViewModel>(context,listen: false);
    return Stack(children: [
      if(widget.showProduct)
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
            feedViewModel.pauseDrawer();
            ProductDetails().sheet(context, widget.index);
            await firebaseServices.viewedProduct(
                feedViewModel.listVideos[widget.index].id.trim());
          },
        ),
      ),
      Positioned(
        right: 0,
        bottom: 0,
        child: sideButtons(),
      )
    ]);
  }

  Widget sideButtons() {
    final feedViewModel = Provider.of<FeedViewModel>(context,listen: false);
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.35,
      width: MediaQuery.of(context).size.height * 0.12,
      child: Column(
        children: [
          if (kIsWeb)
            Expanded(
              child: StatefulBuilder(builder: (context, setState) {
                return IconButton(
                    onPressed: () {
                      if (_status) {
                        feedViewModel.pauseDrawer();

                        setState(() {
                          _status = !_status;
                        });
                      } else {
                        feedViewModel.playDrawer();

                        setState(() {
                          _status = !_status;
                        });
                      }
                    },
                    icon: Icon(
                      _status ? Ionicons.pause_outline : Ionicons.play_outline,
                      color: Colors.white,
                      // size: MediaQuery.of(context).size.height * 0.070,
                    ));
              }),
            ),
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
                future:
                    FirebaseFirestore.instanceFor(app: otherFirebase).collection('VideosData').get(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return IconButton(
                      icon: const Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                        // size: kIsWeb &&
                        //         (defaultTargetPlatform ==
                        //                 TargetPlatform.windows ||
                        //             defaultTargetPlatform ==
                        //                 TargetPlatform.macOS ||
                        //             defaultTargetPlatform ==
                        //                 TargetPlatform.linux)
                        //     ? MediaQuery.of(context).size.height * 0.070
                        //     : MediaQuery.of(context).size.width * 0.070,
                      ),
                      onPressed: () {},
                    );
                  }
                  final documents = snapshot.data!.docs.where((element) {
                    return element.id ==
                        feedViewModel.listVideos[widget.index].id
                            .trim();
                  });
                  List<dynamic> list =
                      documents.isEmpty ? [] : documents.first['Likes'] ?? [];

                  Future<bool> likeFunc(bool init) async {
                    firebaseServices.add(
                        feedViewModel.listVideos[widget.index].id
                            .trim(),
                        list.contains(firebaseServices.user) ? true : false);
                    return !init;
                  }

                  return LikeButton(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // circleSize: MediaQuery.of(context).size.width * 0.1,
                    // bubblesSize: MediaQuery.of(context).size.width * 0.1,
                    // countPostion: CountPostion.bottom,
                    padding: const EdgeInsets.all(0.0),
                    // size: kIsWeb &&
                    //         (defaultTargetPlatform == TargetPlatform.windows ||
                    //             defaultTargetPlatform == TargetPlatform.macOS ||
                    //             defaultTargetPlatform == TargetPlatform.linux)
                    //     ? MediaQuery.of(context).size.height * 0.070
                    //     : MediaQuery.of(context).size.width * 0.070,
                    likeBuilder: (bool isLiked) {
                      return Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.white,
                        // size: kIsWeb &&
                        //         (defaultTargetPlatform ==
                        //                 TargetPlatform.windows ||
                        //             defaultTargetPlatform ==
                        //                 TargetPlatform.macOS ||
                        //             defaultTargetPlatform ==
                        //                 TargetPlatform.linux)
                        //     ? MediaQuery.of(context).size.height * 0.070
                        //     : MediaQuery.of(context).size.width * 0.070,
                      );
                    },
                    isLiked:
                        list.contains(firebaseServices.user) ? true : false,
                    onTap: likeFunc,
                  );
                }),
          ),
          Expanded(
            child: IconButton(
                onPressed: () {
                  feedViewModel.pauseDrawer();
                  Navigator.of(widget.context)
                      .push(MaterialPageRoute(
                          builder: (context) => Comments(feedViewModel
                              .listVideos[widget.index].id
                              .trim())))
                      .then((value) {
                    feedViewModel.seekZero();
                    feedViewModel.playDrawer();
                    // });
                  });
                },
                icon: const Icon(
                  Ionicons.chatbubble_outline,
                  color: Colors.white,
                  // size: kIsWeb &&
                  //         (defaultTargetPlatform == TargetPlatform.windows ||
                  //             defaultTargetPlatform == TargetPlatform.macOS ||
                  //             defaultTargetPlatform == TargetPlatform.linux)
                  //     ? MediaQuery.of(context).size.height * 0.065
                  //     : MediaQuery.of(widget.context).size.width * 0.065,
                )),
          ),
          if (!kIsWeb)
            Expanded(
              child: IconButton(
                  onPressed: () async {
                    feedViewModel.pauseDrawer();
                    feedViewModel.startCircularProgess();
                    Uri uri = await dynamicLinkService
                        .createDynamicLink(feedViewModel
                            .listVideos[widget.index].id
                            .trim())
                        .whenComplete(() {
                      feedViewModel.endCircularProgess();
                    });
                    await Share.share('Look at this video!${uri.toString()}',
                        subject: 'Look at this video!');
                  },
                  icon: const Icon(
                    Ionicons.paper_plane_outline,
                    color: Colors.white,
                    // size: kIsWeb &&
                    //         (defaultTargetPlatform == TargetPlatform.windows ||
                    //             defaultTargetPlatform == TargetPlatform.macOS ||
                    //             defaultTargetPlatform == TargetPlatform.linux)
                    //     ? MediaQuery.of(context).size.height * 0.065
                    //     : MediaQuery.of(widget.context).size.width * 0.065,
                  )),
            ),
          Expanded(
            child: IconButton(
                onPressed: () {
                  feedViewModel.pauseDrawer();

                  showModalBottomSheet(
                      context: widget.context,
                      barrierColor: Colors.black.withOpacity(0.3),
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(10)),
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      elevation: 10,
                      builder: (context) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0.0, 8, 0, 0),
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.01,
                                  width:
                                      MediaQuery.of(context).size.width * 0.10,
                                  decoration: const BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(children: [
                                ListTile(
                                  leading:
                                      const Icon(Ionicons.bookmark_outline),
                                  title: const Text('Save Video'),
                                  onTap: () {
                                    firebaseServices
                                        .saveVideo(feedViewModel
                                            .listVideos[widget.index].id
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
                                  leading:
                                      const Icon(Ionicons.alert_circle_outline),
                                  title: const Text('Report Video'),
                                  onTap: () {
                                    Fluttertoast.showToast(
                                        msg: "Please Wait",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        fontSize: 16.0);
                                    firebaseServices
                                        .reportVideo(feedViewModel
                                            .listVideos[widget.index].id
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
                    feedViewModel.playDrawer();
                  });
                },
                icon: const Icon(
                  Ionicons.ellipsis_vertical_outline,
                  color: Colors.white,
                  // size: kIsWeb &&
                  //         (defaultTargetPlatform == TargetPlatform.windows ||
                  //             defaultTargetPlatform == TargetPlatform.macOS ||
                  //             defaultTargetPlatform == TargetPlatform.linux)
                  //     ? MediaQuery.of(context).size.height * 0.070
                  //     : MediaQuery.of(widget.context).size.width * 0.070,
                )),
          )
        ],
      ),
    );
  }
}
