import 'package:flutter/material.dart';
import 'package:oknoapp/pages/mylikedvideos.dart';
import './scrollfeed.dart';
import 'package:get_it/get_it.dart';
import '../providers/likedvideoprovider.dart';

class LikeScroll extends StatefulWidget {
  static const routeName = '/like_scroll';
  const LikeScroll({Key? key}) : super(key: key);

  @override
  _LikeScrollState createState() => _LikeScrollState();
}

class _LikeScrollState extends State<LikeScroll> {
  final feedViewModel = GetIt.instance<LikeProvider>();
  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as ScreenArguments;
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
              ScrollFeed(arguments.indexofgrid, true),
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
                    const Text('Liked Videos')
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
