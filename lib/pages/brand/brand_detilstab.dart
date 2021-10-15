import 'package:flutter/material.dart';
import '../../providers/branddetailsprovider.dart';
import 'package:get_it/get_it.dart';
import 'package:stacked/stacked.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BrandSpecifications extends StatefulWidget {
  final bool switchvalue;
  const BrandSpecifications(this.switchvalue, {Key? key}) : super(key: key);

  @override
  _BrandSpecificationsState createState() => _BrandSpecificationsState();
}

class _BrandSpecificationsState extends State<BrandSpecifications> {
  final feedViewModel = GetIt.instance<BrandDetailsProvider>();

  final user = FirebaseAuth.instance.currentUser!.uid;
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

  Future<String> getname() async {
    dynamic storeid;
    await FirebaseFirestore.instance
        .collection('UsersData')
        .doc(user)
        .get()
        .then((value) {
      storeid = value.data()!['BrandAssociated'];
    });
    return await FirebaseFirestore.instance
        .collection('BrandData')
        .doc(storeid.first)
        .get()
        .then((value) {
      return value.data()!['balance'].toString();
    });
  }

  @override
  void initState() {
    // init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.switchvalue) {
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
                      FutureBuilder(
                          future: getname(),
                          builder: (context, snapsot) {
                            if (snapsot.connectionState ==
                                ConnectionState.waiting) {
                              return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: const [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('Total Balance:'),
                                      ),
                                      Divider(),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('Loading...',
                                            style: TextStyle(fontSize: 25)),
                                      ),
                                    ],
                                  ));
                            }
                            return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Total Balance:'),
                                    ),
                                    const Divider(),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(snapsot.data.toString(),
                                          style: const TextStyle(fontSize: 25)),
                                    ),
                                  ],
                                ));
                          }),
                      GridView(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 16 / 12, crossAxisCount: 2),
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('No of users viewed product:'),
                                ),
                                const Divider(),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  '$viewedproduct',
                                  style: const TextStyle(fontSize: 25),
                                ),
                              ],
                            ),
                          ),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: SizedBox(
                              width: 200,
                              height: 200,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('No of users viewed url:'),
                                  ),
                                  const Divider(),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    '$viewedurl',
                                    style: const TextStyle(fontSize: 25),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: SizedBox(
                              width: 200,
                              height: 200,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('No of users reporting video:'),
                                  ),
                                  const Divider(),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    '$reported',
                                    style: const TextStyle(fontSize: 25),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: SizedBox(
                              width: 200,
                              height: 200,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Total Views:'),
                                  ),
                                  const Divider(),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    '$viewedvideo',
                                    style: const TextStyle(fontSize: 25),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ));
        });
  }
}
