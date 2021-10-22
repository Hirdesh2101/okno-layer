import 'package:flutter/material.dart';
import 'package:oknoapp/pages/brand/brand_detilstab.dart';
import 'package:oknoapp/pages/brand/brand_videostab.dart';

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
    return Column(
      children: [
        TabBar(
          isScrollable: false,
          tabs: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'DashBoard',
                style: TextStyle(color: Theme.of(context).iconTheme.color),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Videos',
                style: TextStyle(color: Theme.of(context).iconTheme.color),
              ),
            ),
          ],
          labelColor: Theme.of(context).iconTheme.color,
          unselectedLabelColor: Colors.white24,
          indicatorColor: Theme.of(context).iconTheme.color,
          controller: _tabController,
          onTap: (int index) {
            setState(() {
              selectedIndex = index;
              _tabController!.animateTo(index);
            });
          },
        ),
        Divider(
          height: 0,
          color: Theme.of(context).iconTheme.color,
        ),
        Expanded(
          child: IndexedStack(
            children: <Widget>[
              Visibility(
                child: BrandSpecifications(widget.switchval),
                visible: selectedIndex == 0,
                maintainState: true,
              ),
              Visibility(
                child: const BrandTab(),
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
