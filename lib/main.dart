import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oknoapp/Auth/login.dart';
import 'package:oknoapp/Auth/register.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isTimerDone = false;

  @override
  void initState() {
    Timer(
        const Duration(seconds: 2), () => setState(() => _isTimerDone = true));
    super.initState();
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
                    if (!kIsWeb) {
                      if (userSnapshot.connectionState ==
                              ConnectionState.waiting ||
                          !_isTimerDone) {
                        return const SplashScreen();
                      }
                    }
                    if (userSnapshot.hasData) {
                      return const HomePage();
                    }
                    return const Loginscreen();
                  }),
              routes: {
                HomePage.routeName: (ctx) => const HomePage(),
                Loginscreen.routeName: (ctx) => const Loginscreen(),
                Register.routeName: (ctx) => const Register(),
              },
              navigatorObservers: [
                FirebaseAnalyticsObserver(analytics: analytics),
              ],
              onUnknownRoute: (settings) {
                return MaterialPageRoute(
                  builder: (ctx) => const Loginscreen(),
                );
              });
        }));
  }
}
