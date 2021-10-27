import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get_it/get_it.dart';
import 'package:oknoapp/services/web_placeholder.dart';
import '../providers/savedvideoprovider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/cache_service.dart';
import '../providers/myvideosprovider.dart';
import '../services/launch_url.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase functions/sidebar_fun.dart';

class CreatorAndSavedProductDetails {
  final feedViewModel = GetIt.instance<MySavedVideosProvider>();
  final feedViewModel2 = GetIt.instance<MyVideosProvider>();
  SideBarFirebase firebasefun = SideBarFirebase();
  final TextEditingController _textEditingController = TextEditingController();

  Future<String> getname(String id) async {
    return await FirebaseFirestore.instance
        .collection('BrandData')
        .doc(id.trim())
        .get()
        .then((value) {
      return value.data()!['Name'];
    });
  }

  void sheet(context, int index, bool isApproved, bool isNonApproved,
      bool isSavedVideo) async {
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
                        color: Colors.grey,
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
                                  child: kIsWeb
                                      ? FadeInImage.memoryNetwork(
                                          placeholder: kTransparentImage,
                                          image: isApproved || isNonApproved
                                              ? isApproved
                                                  ? feedViewModel2
                                                      .videoSource!
                                                      .approvedData[index]
                                                      .product1
                                                  : feedViewModel2
                                                      .videoSource!
                                                      .nonapprovedData[index]
                                                      .product1
                                              : feedViewModel.videoSource!
                                                  .listData[index].product1,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.2,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.2,
                                          fit: BoxFit.contain,
                                        )
                                      : CachedNetworkImage(
                                          placeholder: (context, url) =>
                                              Container(
                                                  //color: Colors.grey,
                                                  ),
                                          cacheManager:
                                              CustomCacheManager.instance2,
                                          imageUrl: isApproved || isNonApproved
                                              ? isApproved
                                                  ? feedViewModel2
                                                      .videoSource!
                                                      .approvedData[index]
                                                      .product1
                                                  : feedViewModel2
                                                      .videoSource!
                                                      .nonapprovedData[index]
                                                      .product1
                                              : feedViewModel.videoSource!
                                                  .listData[index].product1,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.2,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.2,
                                          fit: BoxFit.contain,
                                        ),
                                ),
                                Text(isApproved || isNonApproved
                                    ? isApproved
                                        ? feedViewModel2.videoSource!
                                            .approvedData[index].p1name
                                        : feedViewModel2.videoSource!
                                            .nonapprovedData[index].p1name
                                    : feedViewModel
                                        .videoSource!.listData[index].p1name),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                    'Price - ₹${isApproved || isNonApproved ? isApproved ? feedViewModel2.videoSource!.approvedData[index].price : feedViewModel2.videoSource!.nonapprovedData[index].price : feedViewModel.videoSource!.listData[index].price}'),
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
                          final url = isApproved || isNonApproved
                              ? isApproved
                                  ? feedViewModel2
                                      .videoSource!.approvedData[index].store
                                  : feedViewModel2
                                      .videoSource!.nonapprovedData[index].store
                              : feedViewModel
                                  .videoSource!.listData[index].store;
                          launchURL(context, url);
                          if (isSavedVideo) {
                            await firebasefun.viewedUrl(feedViewModel
                                .videoSource!.listData[index].id
                                .trim());
                          }
                        },
                        child: const Text('Visit Store')),
                  )),
              if (isApproved)
                SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: ElevatedButton(
                          onPressed: () async {
                            //     keyBoard(true);
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Edit Store Link'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    //color: Colors.white24
                                                    )),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: TextFormField(
                                                controller:
                                                    _textEditingController,
                                                decoration:
                                                    const InputDecoration(
                                                  labelText:
                                                      'Please provide a proper url',
                                                  enabledBorder:
                                                      UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .grey)),
                                                  focusedBorder:
                                                      UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .grey)),
                                                ),
                                              ),
                                            )),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                //    keyBoard(false);
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                                child: const Text('Submit'),
                                                onPressed: () async {
                                                  if (_textEditingController
                                                      .text
                                                      .trim()
                                                      .isNotEmpty) {
                                                    FirebaseFirestore.instance
                                                        .collection(
                                                            'VideosData')
                                                        .doc(feedViewModel2
                                                            .videoSource!
                                                            .approvedData[index]
                                                            .id)
                                                        .update({
                                                      'store':
                                                          _textEditingController
                                                              .text
                                                              .trim()
                                                              .toString()
                                                    });
                                                    Navigator.of(context).pop();
                                                    //   keyBoard(false);
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Url can't be empty",
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity:
                                                            ToastGravity.BOTTOM,
                                                        timeInSecForIosWeb: 1,
                                                        // backgroundColor: Colors.red,
                                                        // textColor: Colors.white,
                                                        fontSize: 16.0);
                                                  }
                                                }),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }).whenComplete(() {
                              Navigator.of(context).pop();
                            });
                          },
                          child: const Text('Edit Store Link')),
                    )),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: FutureBuilder(
                    future: getname(isApproved || isNonApproved
                        ? isApproved
                            ? feedViewModel2
                                .videoSource!.approvedData[index].seller
                            : feedViewModel2
                                .videoSource!.nonapprovedData[index].seller
                        : feedViewModel.videoSource!.listData[index].seller),
                    builder: (context, snapsot) {
                      if (snapsot.connectionState == ConnectionState.waiting) {
                        return const Text('Loading');
                      }
                      return Text(snapsot.data.toString());
                    }),
              ),
            ],
          );
        }).whenComplete(() => isApproved || isNonApproved
        ? isApproved
            ? feedViewModel2.playDrawer(true, false)
            : feedViewModel2.playDrawer(false, true)
        : feedViewModel.playVideo(index));
  }
}
