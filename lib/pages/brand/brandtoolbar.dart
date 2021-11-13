import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../firebase functions/sidebar_fun.dart';
import 'package:ionicons/ionicons.dart';
import '../../providers/brand_provider.dart';

class BrandActionToolBar extends StatelessWidget {
  final int index;
  final BuildContext context;
  BrandActionToolBar(this.index, this.context, {Key? key}) : super(key: key);
  final feedViewModel = GetIt.instance<BrandVideoProvider>();
  final SideBarFirebase firebaseServices = SideBarFirebase();
  //List<String>? selectedCountList = [];

  @override
  Widget build(BuildContext context) {
    return sideButtons();
  }

  sideButtons() {
    return IconButton(
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
                          leading: const Icon(Ionicons.alert_circle_outline),
                          title: const Text('Report Video'),
                          onTap: () {
                            Fluttertoast.showToast(
                                msg: "Please Wait",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                fontSize: 16.0);
                            firebaseServices
                                .brandreportVideo(
                              feedViewModel.videoSource!.listData[index].id
                                  .trim(),
                            )
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
        icon: Icon(
          Ionicons.ellipsis_vertical_outline,
          color: Colors.white,
          size: MediaQuery.of(context).size.width * 0.085,
        ));
  }
}
