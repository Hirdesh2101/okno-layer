import 'package:flutter/material.dart';
import '../../providers/branddetailsprovider.dart';
import 'package:get_it/get_it.dart';
import 'package:stacked/stacked.dart';

class BrandSpecifications extends StatefulWidget {
  final bool switchvalue;
  const BrandSpecifications(this.switchvalue, {Key? key}) : super(key: key);

  @override
  _BrandSpecificationsState createState() => _BrandSpecificationsState();
}

class _BrandSpecificationsState extends State<BrandSpecifications> {
  final feedViewModel = GetIt.instance<BrandDetailsProvider>();
  int viewedurl = 0;
  int reported = 0;
  int viewedproduct = 0;
  int viewedvideo = 0;
  init() {
    for (int i = 0; i < feedViewModel.videoSource!.listData.length; i++) {
      viewedurl += feedViewModel.videoSource!.listData[i].viewedurl.length;
      reported += feedViewModel.videoSource!.listData[i].reportedby.length;
      viewedproduct +=
          feedViewModel.videoSource!.listData[i].viewedproduct.length;
      viewedvideo += feedViewModel.videoSource!.listData[i].watchedvideo.length;
    }
  }

  @override
  void initState() {
    // init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.switchvalue) {
      feedViewModel.applyFilter();
      viewedurl = 0;
      reported = 0;
      viewedproduct = 0;
      viewedvideo = 0;
      init();
      feedViewModel.refresh();
    } else {
      feedViewModel.removeFilter();
      feedViewModel.refresh();
      viewedurl = 0;
      reported = 0;
      viewedproduct = 0;
      viewedvideo = 0;
      init();
    }
    return ViewModelBuilder.reactive(
        disposeViewModel: false,
        viewModelBuilder: () => feedViewModel,
        builder: (context, model, child) {
          return feedViewModel.isBusy
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    return await feedViewModel.refresh().then((value) {
                      setState(() {
                        viewedurl = 0;
                        reported = 0;
                        viewedproduct = 0;
                        viewedvideo = 0;
                        init();
                      });
                    });
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(8.0),
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text('No of users viewed product:'),
                          const Expanded(
                            child: SizedBox(),
                          ),
                          Text('$viewedproduct'),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text('No of users viewed url:'),
                          const Expanded(
                            child: SizedBox(),
                          ),
                          Text('$viewedurl'),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text('No of users reporting video:'),
                          const Expanded(
                            child: SizedBox(),
                          ),
                          Text('$reported'),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text('Total Views:'),
                          const Expanded(
                            child: SizedBox(),
                          ),
                          Text('$viewedvideo'),
                        ],
                      ),
                    ],
                  ));
        });
  }
}
