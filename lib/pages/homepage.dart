import 'package:flutter/material.dart';
import 'scrollfeed.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return videoScreen();
  }

  Widget videoScreen() {
    return Scaffold(
      body: FutureBuilder(
          future: FirebaseFirestore.instance.collection("VideosData").get(),
          builder: (ctx, snapshot) {
            return snapshot.hasData
                ? SafeArea(
                    child: Stack(
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        const ScrollFeed(),
                      ],
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  );
          }),
    );
  }
}
