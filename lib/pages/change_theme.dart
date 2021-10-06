import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../providers/theme_provider.dart';
import '../constants/themes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({Key? key}) : super(key: key);

  @override
  _ThemeScreenState createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  var _darkTheme = true;

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    print(themeNotifier.getTheme());
    // _darkTheme = (themeNotifier.getTheme() == darkTheme);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Theme'),
      ),
      body: ListView(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              if (_darkTheme) {
                setState(() {
                  _darkTheme = false;
                });
                onThemeChanged(_darkTheme, themeNotifier);
              }
            },
            child: ListTile(
              title: const Text('Light'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              trailing: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        width: 2,
                        color: _darkTheme ? Colors.grey : Colors.grey),
                    color: !_darkTheme ? Colors.blue : Colors.transparent),
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: !_darkTheme
                      ? const Icon(
                          Icons.check,
                          size: 20.0,
                          color: Colors.white,
                        )
                      : const Icon(
                          null,
                          size: 20.0,
                          color: Colors.blue,
                        ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (!_darkTheme) {
                setState(() {
                  _darkTheme = true;
                });
                onThemeChanged(_darkTheme, themeNotifier);
              }
            },
            child: ListTile(
              title: const Text('Dark'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              trailing: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        width: 2,
                        color: !_darkTheme ? Colors.grey : Colors.white),
                    color: _darkTheme ? Colors.blue : Colors.transparent),
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: _darkTheme
                      ? const Icon(
                          Icons.check,
                          size: 20.0,
                          color: Colors.white,
                        )
                      : const Icon(
                          null,
                          size: 20.0,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onThemeChanged(bool value, ThemeNotifier themeNotifier) async {
    (value)
        ? themeNotifier.setTheme(darkTheme)
        : themeNotifier.setTheme(lightTheme);
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', value);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: value ? Colors.black : Colors.white,
      // systemNavigationBarIconBrightness:
      //     value ? Brightness.light : Brightness.light
    ));
  }
}
