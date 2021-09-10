import 'package:flutter/material.dart';
import 'pages/homepage.dart';
import 'service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setup();
  runApp(MaterialApp(
    title: 'OkNoApp',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    debugShowCheckedModeBanner: false,
    home: const HomePage(),
  ));
}
