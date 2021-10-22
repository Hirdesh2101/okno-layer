import 'package:flutter/material.dart';
import 'package:oknoapp/models/my_saved.dart';
import 'package:oknoapp/pages/tab_approvedvideo.dart';
import 'package:oknoapp/pages/tab_saved.dart';
import 'package:oknoapp/pages/tabmyvideo.dart';
import 'package:oknoapp/pages/tabnonapproved.dart';
import 'package:oknoapp/providers/myvideosprovider.dart';
import 'package:get_it/get_it.dart';
import '../providers/savedvideoprovider.dart';
import 'package:ionicons/ionicons.dart';
import '../firebase functions/sidebar_fun.dart';

class TabBarControllerWidget extends StatefulWidget {
  final bool isCretorPage;
  const TabBarControllerWidget(this.isCretorPage, {Key? key}) : super(key: key);
  @override
  _TabBarControllerWidgetState createState() => _TabBarControllerWidgetState();
}

class _TabBarControllerWidgetState extends State<TabBarControllerWidget> {
  int selectedIndex = 0;
  List<MySavedVideos> videosData = [];
  bool isLoading = false;

  final feedViewModel2 = GetIt.instance<MySavedVideosProvider>();
  final feedViewModel = GetIt.instance<MyVideosProvider>();

  final SideBarFirebase firebaseServices = SideBarFirebase();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: selectedIndex,
      length: 2,
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          TabBar(
            tabs: [
              widget.isCretorPage
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Ionicons.grid_outline,
                      ),
                    )
                  : const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Ionicons.apps_outline,
                      ),
                    ),
              widget.isCretorPage
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Ionicons.hardware_chip_outline,
                      ),
                    )
                  : const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Ionicons.bookmark_outline,
                      ),
                    ),
            ],
            isScrollable: false,
            onTap: (int index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),
          const Divider(height: 0),
          IndexedStack(
            children: <Widget>[
              Visibility(
                child: widget.isCretorPage
                    ? const ApprovedVideoTab()
                    : const MyVideoTab(),
                maintainState: true,
                visible: selectedIndex == 0,
              ),
              Visibility(
                child: widget.isCretorPage
                    ? const NonApprovedVideoTab()
                    : const SavedTab(),
                maintainState: true,
                visible: selectedIndex == 1,
              ),
            ],
            index: selectedIndex,
          ),
        ],
      ),
    );
  }
}
