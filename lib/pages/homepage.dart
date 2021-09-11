import 'package:flutter/material.dart';
import 'scrollfeed.dart';
import '../models/feedviewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final locator = GetIt.instance;
  final feedViewModel = GetIt.instance<FeedViewModel>();
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FeedViewModel>.reactive(
        disposeViewModel: false,
        builder: (context, model, child) => videoScreen(),
        viewModelBuilder: () => feedViewModel);
  }

  Widget videoScreen() {
    return Scaffold(
      //backgroundColor: GetIt.instance<FeedViewModel>().actualScreen == 0
      //   ? Colors.black
      //  : Colors.white,
      body: SafeArea(
        child: Stack(
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            const ScrollFeed(),
          ],
        ),
      ),
    );
  }
}
