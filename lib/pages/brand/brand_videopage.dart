import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import './brand_feed.dart';
import '../../providers/brand_provider.dart';

class BrandScroll extends StatefulWidget {
  final int indexofgrid;
  const BrandScroll(this.indexofgrid, {Key? key}) : super(key: key);

  @override
  _BrandScrollState createState() => _BrandScrollState();
}

class _BrandScrollState extends State<BrandScroll> {
  final feedViewModel = GetIt.instance<BrandVideoProvider>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            await feedViewModel.pauseDrawer();
            await feedViewModel.disposingall();
            return true;
          },
          child: Stack(
            children: [
              BrandFeed(widget.indexofgrid),
              Positioned(
                child: Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          feedViewModel.disposingall();

                          Navigator.of(context).pop();
                        }),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text('Brand Videos')
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
