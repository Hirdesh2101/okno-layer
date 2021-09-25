import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    var user = FirebaseAuth.instance.currentUser!.uid;
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        TabBar(
          tabs: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.menu,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.favorite_border,
              ),
            ),
          ],
          isScrollable: true,
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
              child: FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('UsersData')
                    .doc(user)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  dynamic data = snapshot.data;
                  List temp = data['MyVideos'];
                  return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: data['MyVideos'].length,
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
                        return Card();
                      });
                },
              ),
              maintainState: true,
              visible: selectedIndex == 0,
            ),
            Visibility(
              child: Container(
                child: const Center(
                  child: Text('Content'),
                ),
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
