import 'package:flutter/material.dart';
import 'scrollfeed.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home_page';
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final firebaseAuth = FirebaseAuth.instance;
  var user = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  init() async {
    //subscribe to topic on each app start-up
    // FirebaseAnalytics.instance.logEvent(name: 'login', parameters: null);
    // FirebaseAnalytics.instance.logEvent(name: 'main_feed', parameters: null);
    await FirebaseFirestore.instance
        .collection('UsersData')
        .doc(user)
        .get()
        .then((value) async {
      await FirebaseAnalytics.instance.setUserProperty(
          name: 'category', value: '${value.data()!['topic']}');
      await _firebaseMessaging.subscribeToTopic('${value.data()!['topic']}');
    });
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
                    child: ScrollFeed(),
                  );
  }
}
