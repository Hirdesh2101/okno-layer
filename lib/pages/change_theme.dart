import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({Key? key}) : super(key: key);

  @override
  _ThemeScreenState createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  var _darkTheme = false;
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeModel>(context);
    _darkTheme = themeNotifier.isDark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Theme'),
      ),
      body: ListView(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              setState(() {
                _darkTheme = false;
              });
              themeNotifier.isDark
                  ? themeNotifier.isDark = false
                  : themeNotifier.isDark = true;
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
              setState(() {
                _darkTheme = true;
              });

              themeNotifier.isDark
                  ? themeNotifier.isDark = false
                  : themeNotifier.isDark = true;
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
}
