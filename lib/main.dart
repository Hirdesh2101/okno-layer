import 'package:flutter/material.dart';
import 'package:oknoapp/Auth/login.dart';
import 'package:oknoapp/Auth/register.dart';
import 'package:oknoapp/pages/liked_scroll.dart';
import 'package:oknoapp/pages/mylikedvideos.dart';
import 'package:oknoapp/pages/profile_page.dart';
import 'pages/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/service_locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //setup();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          LikeScroll.routeName: (ctx) => const LikeScroll(),
          ProfileScreen.routeName: (ctx) => const ProfileScreen(),
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (ctx) => const Loginscreen(),
          );
        });
  }
}
