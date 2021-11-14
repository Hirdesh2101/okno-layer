import 'package:flutter/foundation.dart';
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
import '../providers/myvideosprovider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/filter_provider.dart';
import 'package:filter_list/filter_list.dart';

// ignore: must_be_immutable
class ActionToolBar extends StatelessWidget {
  final int index;
  final bool likedPage;
  final bool mypage;
  final bool filterScreen;
  final List<String> countList;
  final List<String> selectedCountList;
  final bool filterApplied;
  final Function(List<String>? selectedCountList) appliedFunction;
  final Function(bool status) filterOpened;
  final BuildContext context;
  ActionToolBar(
      this.index,
      this.likedPage,
      this.mypage,
      this.filterScreen,
      this.context,
      this.countList,
      this.selectedCountList,
      this.appliedFunction,
      this.filterOpened,
      this.filterApplied,
      {Key? key})
      : super(key: key);

  final feedViewModel = GetIt.instance<FeedViewModel>();
  final feedViewMode2 = GetIt.instance<LikeProvider>();
  final feedViewMode3 = GetIt.instance<MyVideosProvider>();
  final feedViewMode4 = GetIt.instance<FilterViewModel>();
  final SideBarFirebase firebaseServices = SideBarFirebase();
  final DynamicLinkService dynamicLinkService = DynamicLinkService();
  //List<String>? selectedCountList = [];
  Future<void> submitFunct(List<String>? selectedCountList) async {
    await appliedFunction(selectedCountList);
  }

  void statusCheck(bool value) {
    filterOpened(value);
  }

  bool _status = true;
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
                : filterScreen
                    ? feedViewMode4.pauseDrawer()
                    : feedViewModel.pauseDrawer();
            ProductDetails()
                .sheet(context, index, likedPage, mypage, filterScreen);
            await firebaseServices.viewedProduct(likedPage
                ? feedViewMode2.videoSource!.listData[index].id
                : filterScreen
                    ? feedViewMode4.videoSource!.listVideos[index].id.trim()
                    : feedViewModel.videoSource!.listVideos[index].id.trim());
          },
        ),
      ),
      if (!likedPage && !mypage)
        Positioned(
          right: 0,
          bottom: 0,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: sideButtons(),
          ),
        )
    ]);
  }

  Widget sideButtons() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      if (kIsWeb)
        IconButton(
            onPressed: () {
              if (_status) {
                if (filterScreen) {
                  feedViewMode4.pauseDrawer();
                } else {
                  feedViewModel.pauseDrawer();
                }
                _status = !_status;
              } else {
                if (filterScreen) {
                  feedViewMode4.playDrawer();
                } else {
                  feedViewModel.playDrawer();
                }
                _status = !_status;
              }
            },
            icon: const Icon(
              Ionicons.play_outline,
              color: Colors.white,
              size: 40,
            )),
      if (kIsWeb)
        const SizedBox(
          height: 10,
        ),
      FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection('VideosData').get(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return IconButton(
                icon: Icon(
                  Icons.favorite_border,
                  color: Colors.white,
                  size: kIsWeb ? 40 : MediaQuery.of(context).size.width * 0.1,
                ),
                onPressed: () {},
              );
            }
            final documents = snapshot.data!.docs.where((element) {
              return filterScreen
                  ? element.id ==
                      feedViewMode4.videoSource!.listVideos[index].id.trim()
                  : element.id ==
                      feedViewModel.videoSource!.listVideos[index].id.trim();
            });
            List<dynamic> list = documents.first['Likes'] ?? [];

            Future<bool> likeFunc(bool init) async {
              firebaseServices.add(
                  likedPage
                      ? feedViewMode2.videoSource!.listData[index].id
                      : filterScreen
                          ? feedViewMode4.videoSource!.listVideos[index].id
                              .trim()
                          : feedViewModel.videoSource!.listVideos[index].id
                              .trim(),
                  list.contains(firebaseServices.user) ? true : false);
              return !init;
            }

            return LikeButton(
              padding: const EdgeInsets.all(0),
              size: kIsWeb ? 40 : MediaQuery.of(context).size.width * 0.1,
              likeBuilder: (bool isLiked) {
                return Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.white,
                  size: kIsWeb ? 40 : MediaQuery.of(context).size.width * 0.1,
                );
              },
              isLiked: list.contains(firebaseServices.user) ? true : false,
              onTap: likeFunc,
            );
          }),
      const SizedBox(
        height: 10,
      ),
      IconButton(
          onPressed: () {
            filterScreen
                ? feedViewMode4.pauseDrawer()
                : feedViewModel.pauseDrawer();
            Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (context) => Comments(filterScreen
                        ? feedViewMode4.videoSource!.listVideos[index].id.trim()
                        : feedViewModel.videoSource!.listVideos[index].id
                            .trim())))
                .then((value) {
              if (filterScreen) {
                feedViewMode4.seekZero();
                feedViewMode4.playDrawer();
              } else {
                feedViewModel.seekZero();
                feedViewModel.playDrawer();
              }
              // });
            });
          },
          icon: Icon(
            Ionicons.chatbubble_outline,
            color: Colors.white,
            size: kIsWeb ? 40 : MediaQuery.of(context).size.width * 0.085,
          )),
      const SizedBox(
        height: 10,
      ),
      if (!kIsWeb)
        IconButton(
            onPressed: () async {
              if (filterScreen) {
                feedViewMode4.pauseDrawer();
                feedViewMode4.startCircularProgess();
                Uri uri = await dynamicLinkService
                    .createDynamicLink(
                        feedViewMode4.videoSource!.listVideos[index].id.trim())
                    .whenComplete(() {
                  feedViewMode4.endCircularProgess();
                });
                await Share.share('Look at this video!${uri.toString()}',
                    subject: 'Look at this video!');
              } else {
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
              }
            },
            icon: Icon(
              Ionicons.paper_plane_outline,
              color: Colors.white,
              size: kIsWeb ? 40 : MediaQuery.of(context).size.width * 0.085,
            )),
      const SizedBox(
        height: 10,
      ),
      IconButton(
          onPressed: () {
            if (filterScreen) {
              feedViewMode4.pauseDrawer();
            } else {
              feedViewModel.pauseDrawer();
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
                          ListTile(
                            leading: Icon(
                              Ionicons.filter_outline,
                              color: filterApplied
                                  ? Colors.green
                                  : Theme.of(context).iconTheme.color,
                            ),
                            title: const Text('Apply Filters'),
                            onTap: () async {
                              statusCheck(true);
                              await FilterListDialog.display<String>(context,
                                  listData: countList,
                                  selectedListData: selectedCountList,
                                  searchFieldTextStyle:
                                      const TextStyle(color: Colors.black),
                                  controlButtonTextStyle:
                                      const TextStyle(color: Colors.blue),
                                  height:
                                      MediaQuery.of(context).size.height * 0.6,
                                  controlContainerDecoration:
                                      const BoxDecoration(color: Colors.white),
                                  headlineText: "Select Filters",
                                  searchFieldHintText: "Search Here",
                                  applyButtonTextStyle:
                                      const TextStyle(color: Colors.white),
                                  selectedItemsText: 'Filters Selected',
                                  choiceChipLabel: (item) {
                                return item;
                              }, validateSelectedItem: (list, val) {
                                return list!.contains(val);
                              }, onItemSearch: (list, text) {
                                if (list!.any((element) => element
                                    .toLowerCase()
                                    .contains(text.toLowerCase()))) {
                                  return list
                                      .where((element) => element
                                          .toLowerCase()
                                          .contains(text.toLowerCase()))
                                      .toList();
                                } else {
                                  return [];
                                }
                              }, onApplyButtonClick: (list) async {
                                if (list != null) {
                                  await submitFunct(list);
                                }
                                Navigator.pop(context);
                              }).whenComplete(() {
                                statusCheck(false);
                                Navigator.pop(context);
                              });
                            },
                          ),
                          ListTile(
                            leading: const Icon(Ionicons.bookmark_outline),
                            title: const Text('Save Video'),
                            onTap: () {
                              firebaseServices
                                  .saveVideo(filterScreen
                                      ? feedViewMode4
                                          .videoSource!.listVideos[index].id
                                          .trim()
                                      : feedViewModel
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
                                  .reportVideo(filterScreen
                                      ? feedViewMode4
                                          .videoSource!.listVideos[index].id
                                          .trim()
                                      : feedViewModel
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
                      ),
                    ],
                  );
                }).whenComplete(() {
              filterApplied
                  ? feedViewMode4.playDrawer()
                  : feedViewModel.playDrawer();
            });
          },
          icon: Icon(
            filterApplied
                ? Ionicons.checkbox_outline
                : Ionicons.ellipsis_vertical_outline,
            color: filterApplied ? Colors.green : Colors.white,
            size: kIsWeb ? 40 : MediaQuery.of(context).size.width * 0.085,
          )),
    ]);
  }
}
