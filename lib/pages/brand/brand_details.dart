import 'package:flutter/material.dart';

class BrandDetails extends StatefulWidget {
  const BrandDetails({Key? key}) : super(key: key);

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
      length: 5,
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
    return Column(
      children: [
        TabBar(
          isScrollable: true,
          tabs: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Videos'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Views'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Likes'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Clicks'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Store Visit'),
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
              child: Container(
                child: Text('1'),
              ),
              visible: selectedIndex == 0,
              maintainState: true,
            ),
            Visibility(
              child: Container(
                child: Text('2'),
              ),
              visible: selectedIndex == 1,
              maintainState: true,
            ),
            Visibility(
              child: Container(
                child: Text('3'),
              ),
              visible: selectedIndex == 2,
              maintainState: true,
            ),
            Visibility(
              child: Container(
                child: Text('4'),
              ),
              visible: selectedIndex == 3,
              maintainState: true,
            ),
            Visibility(
              child: Container(
                child: Text('5'),
              ),
              visible: selectedIndex == 4,
              maintainState: true,
            ),
          ],
          index: selectedIndex,
        ),
      ],
    );
  }
}
