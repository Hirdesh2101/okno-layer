import 'package:flutter/material.dart';
import '../constants/themes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                'assets/main_logo.png',
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              ),
              const SizedBox(
                height: 20,
              ),
              Text('OkNo',
                  style: kBillabongFamilyTextStyle.copyWith(fontSize: 20)),
            ],
          ),
        ],
      ),
    );
  }
}
