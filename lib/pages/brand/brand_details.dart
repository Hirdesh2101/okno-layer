import 'package:flutter/material.dart';
import 'package:oknoapp/pages/brand/brand_detilstab.dart';
import 'package:oknoapp/providers/brand_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/cache_service.dart';
import 'package:stacked/stacked.dart';

class BrandDetails extends StatefulWidget {
  final bool switchval;
  const BrandDetails(this.switchval, {Key? key}) : super(key: key);

  @override
  _BrandDetailsState createState() => _BrandDetailsState();
}

class _BrandDetailsState extends State<BrandDetails>
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
    final feedViewModel = GetIt.instance<BrandVideoProvider>();
    return Column(
      children: [
        TabBar(
          isScrollable: false,
          tabs: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('DashBoard'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Videos'),
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
        Expanded(
          child: IndexedStack(
            children: <Widget>[
              Visibility(
                child: BrandSpecifications(widget.switchval),
                visible: selectedIndex == 0,
                maintainState: true,
              ),
              Visibility(
                child: feedViewModel.videoSource!.listVideos.isEmpty
                    ? Center(
                        child: Column(
                          children: const [
                            SizedBox(
                              height: 50,
                            ),
                            Text('No Videos from your brand yet!!'),
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
                                      // Navigator.of(context).push(
                                      //     MaterialPageRoute(builder: (context) {
                                      //   return LikeScroll(index, true);
                                      // }));
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
                                                    // color: Colors.grey,
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
                visible: selectedIndex == 1,
              ),
            ],
            index: selectedIndex,
          ),
        ),
      ],
    );
  }
}
