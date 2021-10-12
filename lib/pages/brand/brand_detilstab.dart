import 'package:flutter/material.dart';
import '../../providers/branddetailsprovider.dart';
import 'package:get_it/get_it.dart';
import 'package:stacked/stacked.dart';

class BrandSpecifications extends StatefulWidget {
  const BrandSpecifications({Key? key}) : super(key: key);

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
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text('No of users viewed product:'),
                          Text('$viewedproduct'),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text('No of users viewed url:'),
                          Text('$viewedurl'),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text('No of users reporting video:'),
                          Text('$reported'),
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text('Total Views:'),
                          Text('$viewedvideo'),
                        ],
                      ),
                    ],
                  ));
        });
  }
}
