import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oknoapp/firebase_options.dart';
import 'package:oknoapp/pages/splash_screen.dart';
import 'package:oknoapp/providers/feedviewprovider.dart';
import 'pages/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import './providers/theme_provider.dart';
import './constants/themes.dart';

// Future<void> main() async {

//   runApp(const MyReelsApp());
// }

class MyReelsApp extends StatefulWidget {
  const MyReelsApp({
    Key? key,
  }) : super(key: key);

  @override
  State<MyReelsApp> createState() => _MyReelsAppState();
}

class _MyReelsAppState extends State<MyReelsApp> {
  @override
  void initState() {
    init();
    super.initState();
  }
  init()async{
      WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'okno',
    options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final user = FirebaseAuth.instance.currentUser;
  FirebaseApp otherFirebase = Firebase.app('okno');
  await FirebaseFirestore.instanceFor(app: otherFirebase)
      .collection('UsersData')
      .doc(user!.uid)
      .get()
      .then((value) async{
    if (!value.exists) {
      await FirebaseFirestore.instanceFor(app: otherFirebase).collection('UsersData').doc(user.uid).set({
        // 'Name': username,
        // 'Gender': gender,
        // 'Email': email,
        // 'Age': age,
        'Creator': false,
        'Likes': [],
        'MyVideos': [],
        'Total Income': 0.0,
        'Balance': 0.0,
        'Encashed': 0.0,
        'WatchedVideo': [],
        'Saved': [],
        'topic': 'viewer',
        // 'Image': gender,
        'BrandEnabled': false,
        'BrandAssociated': [],
      });
    }
  });
  }
  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => FeedViewModel(),
          ),
          ChangeNotifierProvider(
            create: (context) => ThemeModel(),
          )
        ],
        child: Consumer<ThemeModel>(
            builder: (context, ThemeModel themeNotifier, child) {
          return MaterialApp(
              title: 'OkNo',
              theme: themeNotifier.isDark ? darkTheme : lightTheme,
              debugShowCheckedModeBanner: false,
              home: StreamBuilder(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (ctx, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const SplashScreen();
                    } else if (userSnapshot.hasData) {
                      return const HomePage();
                    }else{
                      return const Placeholder();
                    }
                  }),
              routes: {
                HomePage.routeName: (ctx) => const HomePage(),
              },
              navigatorObservers: [
                FirebaseAnalyticsObserver(analytics: analytics),
              ],
              onUnknownRoute: (settings) {
                return MaterialPageRoute(
                  builder: (ctx) => const SplashScreen(),
                );
              });
        }));
  }
}
