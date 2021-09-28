import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:oknoapp/providers/myvideosprovider.dart';
import 'package:get_it/get_it.dart';
import './liked_scroll.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/cache_service.dart';
import 'package:ionicons/ionicons.dart';

class TabBarControllerWidget extends StatefulWidget {
  const TabBarControllerWidget({Key? key}) : super(key: key);
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
  Widget build(BuildContext context) {
    final feedViewModel = GetIt.instance<MyVideosProvider>();
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        TabBar(
          tabs: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Ionicons.apps_outline,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.favorite_border,
              ),
            ),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white24,
          indicatorColor: Colors.white,
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
              child: feedViewModel.videoSource!.listVideos.isEmpty
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
                                feedViewModel.videoSource!.listVideos.length,
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
                                        MaterialPageRoute(builder: (context) {
                                      return LikeScroll(index, true);
                                    }));
                                  },
                                  child: Card(
                                    elevation: 3,
                                    child: SizedBox.expand(
                                      child: FittedBox(
                                        fit: BoxFit.fill,
                                        child: CachedNetworkImage(
                                          key: Key(feedViewModel.videoSource!
                                              .listData[index].thumbnail),
                                          placeholder: (context, url) =>
                                              Container(
                                            color: Colors.grey,
                                          ),
                                          fit: BoxFit.fill,
                                          cacheManager:
                                              CustomCacheManager.instance2,
                                          imageUrl: feedViewModel.videoSource!
                                              .listData[index].thumbnail,
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
              child: const Center(
                child: Text('Coming SOOn'),
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
