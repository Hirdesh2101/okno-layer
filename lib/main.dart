import 'package:flutter/material.dart';
import 'package:oknoapp/Auth/login.dart';
import 'package:oknoapp/Auth/register.dart';
import 'package:oknoapp/pages/edit_video.dart';
import 'package:oknoapp/pages/creator_section.dart';
import 'package:oknoapp/pages/edit_profile.dart';
import 'package:oknoapp/pages/encashed_page.dart';
import 'package:oknoapp/pages/mylikedvideos.dart';
import 'package:oknoapp/pages/profile_page.dart';
import 'package:oknoapp/pages/userimage_set.dart';
import 'pages/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/service_locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/services.dart';
import 'package:firebase_analytics/observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //setup();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics analytics = FirebaseAnalytics();
    return MaterialApp(
        title: 'OkNoApp',
        themeMode: ThemeMode.dark,
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (ctx, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (userSnapshot.hasData) {
                WidgetsFlutterBinding.ensureInitialized();
                setup();
                return const HomePage();
              }
              return const Loginscreen();
            }),
        routes: {
          HomePage.routeName: (ctx) => const HomePage(),
          Loginscreen.routeName: (ctx) => const Loginscreen(),
          Register.routeName: (ctx) => const Register(),
          MyLikedVideos.routeName: (ctx) => const MyLikedVideos(),
          ProfileScreen.routeName: (ctx) => const ProfileScreen(),
          EditProfile.routeName: (ctx) => const EditProfile(),
          CreatorPage.routeName: (ctx) => const CreatorPage(),
          EncashedPage.routeName: (ctx) => const EncashedPage(),
          SetProfileImage.routeName: (ctx) => const SetProfileImage(),
        },
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (ctx) => const Loginscreen(),
          );
        });
  }
}
