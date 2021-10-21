import 'package:flutter/material.dart';
import 'package:oknoapp/pages/creatorandsavedscroll.dart';
import 'package:stacked/stacked.dart';
import 'package:oknoapp/providers/myvideosprovider.dart';
import 'package:get_it/get_it.dart';
import './liked_scroll.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/cache_service.dart';
import '../providers/savedvideoprovider.dart';
import 'package:ionicons/ionicons.dart';

class TabBarControllerWidget extends StatefulWidget {
  final bool isCretorPage;
  const TabBarControllerWidget(this.isCretorPage, {Key? key}) : super(key: key);
  @override
  _TabBarControllerWidgetState createState() => _TabBarControllerWidgetState();
}

class _TabBarControllerWidgetState extends State<TabBarControllerWidget>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int selectedIndex = 0;

  @override
  void initState() {
    _tabController = TabController(
      initialIndex: selectedIndex,
      length: 2,
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedViewModel = GetIt.instance<MyVideosProvider>();
    final feedViewModel2 = GetIt.instance<MySavedVideosProvider>();
    return ListView(
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
          controller: _tabController,
          onTap: (int index) {
            setState(() {
              selectedIndex = index;
              _tabController!.animateTo(index);
            });
          },
        ),
        const Divider(height: 0),
        IndexedStack(
          children: <Widget>[
            Visibility(
              child: widget.isCretorPage
                  ? feedViewModel.videoSource!.approvedData.isEmpty
                      ? Center(
                          child: Column(
                            children: const [
                              SizedBox(
                                height: 50,
                              ),
                              Text('No Approved Videos')
                            ],
                          ),
                        )
                      : ViewModelBuilder.reactive(
                          disposeViewModel: false,
                          viewModelBuilder: () => feedViewModel,
                          builder: (context, model, child) {
                            return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: feedViewModel
                                    .videoSource!.approvedData.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
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
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return CreatorandSavedScroll(
                                              index, false, true, false);
                                        }));
                                      },
                                      child: Card(
                                        elevation: 3,
                                        child: SizedBox.expand(
                                          child: FittedBox(
                                            fit: BoxFit.fill,
                                            child: CachedNetworkImage(
                                              key: Key(feedViewModel
                                                  .videoSource!
                                                  .approvedData[index]
                                                  .thumbnail),
                                              placeholder: (context, url) =>
                                                  Container(
                                                      // color: Colors.grey,
                                                      ),
                                              fit: BoxFit.fill,
                                              cacheManager:
                                                  CustomCacheManager.instance2,
                                              imageUrl: feedViewModel
                                                  .videoSource!
                                                  .approvedData[index]
                                                  .thumbnail,
                                            ),
                                          ),
                                        ),
                                      ));
                                });
                          },
                        )
                  : feedViewModel.videoSource!.listData.isEmpty
                      ? Center(
                          child: Column(
                            children: const [
                              SizedBox(
                                height: 50,
                              ),
                              Text('No Videos Created'),
                            ],
                          ),
                        )
                      : ViewModelBuilder.reactive(
                          disposeViewModel: false,
                          viewModelBuilder: () => feedViewModel,
                          builder: (context, model, child) {
                            return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount:
                                    feedViewModel.videoSource!.listData.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
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
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return LikeScroll(index, true);
                                        }));
                                      },
                                      child: Card(
                                        elevation: 3,
                                        child: SizedBox.expand(
                                          child: FittedBox(
                                            fit: BoxFit.fill,
                                            child: CachedNetworkImage(
                                              key: Key(feedViewModel
                                                  .videoSource!
                                                  .listData[index]
                                                  .thumbnail),
                                              placeholder: (context, url) =>
                                                  Container(
                                                      // color: Colors.grey,
                                                      ),
                                              fit: BoxFit.fill,
                                              cacheManager:
                                                  CustomCacheManager.instance2,
                                              imageUrl: feedViewModel
                                                  .videoSource!
                                                  .listData[index]
                                                  .thumbnail,
                                            ),
                                          ),
                                        ),
                                      ));
                                });
                          },
                        ),
              maintainState: true,
              visible: selectedIndex == 0,
            ),
            Visibility(
              child: widget.isCretorPage
                  ? feedViewModel.videoSource!.nonapprovedData.isEmpty
                      ? Center(
                          child: Column(
                            children: const [
                              SizedBox(
                                height: 50,
                              ),
                              Text('No Videos waiting for approval')
                            ],
                          ),
                        )
                      : ViewModelBuilder.reactive(
                          disposeViewModel: false,
                          viewModelBuilder: () => feedViewModel,
                          builder: (context, model, child) {
                            return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: feedViewModel
                                    .videoSource!.nonapprovedData.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 1,
                                  mainAxisSpacing: 1,
                                  childAspectRatio: 9 / 15,
                                ),
                                itemBuilder: (
                                  context,
                                  index,
                                ) {
                                  return GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return CreatorandSavedScroll(
                                              index, false, false, true);
                                        }));
                                      },
                                      child: Card(
                                        elevation: 3,
                                        child: SizedBox.expand(
                                          child: FittedBox(
                                            fit: BoxFit.fill,
                                            child: CachedNetworkImage(
                                              key: Key(feedViewModel
                                                  .videoSource!
                                                  .nonapprovedData[index]
                                                  .thumbnail),
                                              placeholder: (context, url) =>
                                                  Container(
                                                      //: Colors.grey,
                                                      ),
                                              fit: BoxFit.fill,
                                              cacheManager:
                                                  CustomCacheManager.instance2,
                                              imageUrl: feedViewModel
                                                  .videoSource!
                                                  .nonapprovedData[index]
                                                  .thumbnail,
                                            ),
                                          ),
                                        ),
                                      ));
                                });
                          },
                        )
                  : feedViewModel2.videoSource!.listData.isEmpty
                      ? Center(
                          child: Column(
                            children: const [
                              SizedBox(
                                height: 50,
                              ),
                              Text('No Saved Videos'),
                            ],
                          ),
                        )
                      : ViewModelBuilder.reactive(
                          disposeViewModel: false,
                          viewModelBuilder: () => feedViewModel2,
                          builder: (context, model, child) {
                            return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount:
                                    feedViewModel2.videoSource!.listData.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 1,
                                  mainAxisSpacing: 1,
                                  childAspectRatio: 9 / 15,
                                ),
                                itemBuilder: (
                                  context,
                                  index,
                                ) {
                                  return GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return CreatorandSavedScroll(
                                              index, true, false, false);
                                        }));
                                      },
                                      child: Card(
                                        elevation: 3,
                                        child: SizedBox.expand(
                                          child: FittedBox(
                                            fit: BoxFit.fill,
                                            child: CachedNetworkImage(
                                              key: Key(feedViewModel2
                                                  .videoSource!
                                                  .listData[index]
                                                  .thumbnail),
                                              placeholder: (context, url) =>
                                                  Container(
                                                      //: Colors.grey,
                                                      ),
                                              fit: BoxFit.fill,
                                              cacheManager:
                                                  CustomCacheManager.instance2,
                                              imageUrl: feedViewModel2
                                                  .videoSource!
                                                  .listData[index]
                                                  .thumbnail,
                                            ),
                                          ),
                                        ),
                                      ));
                                });
                          },
                        ),
              maintainState: true,
              visible: selectedIndex == 1,
            ),
          ],
          index: selectedIndex,
        ),
      ],
    );
  }
}
