import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../services/launch_url.dart';

class LegalPage extends StatelessWidget {
  const LegalPage({Key? key}) : super(key: key);

  Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/legal.txt');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Terms and conditions'),
            leading: const Icon(Ionicons.information_outline),
            onTap: () {
              loadAsset().then((value) {
                showLicensePage(
                    context: context,
                    applicationName: 'Okno',
                    applicationIcon: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/OknoIcon.png',
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: MediaQuery.of(context).size.width * 0.2,
                      ),
                    ),
                    applicationVersion: '1.2.0',
                    applicationLegalese: value);
              });
            },
          ),
          ListTile(
            title: const Text('Policy'),
            leading: const Icon(Ionicons.help_circle_outline),
            onTap: () {
              launchURL(context, 'https://www.oknoapp.com/');
            },
          ),
          ListTile(
            title: const Text('Content Allowed'),
            leading: const Icon(Ionicons.help_circle_outline),
            onTap: () {
              launchURL(context, 'https://www.oknoapp.com/');
            },
          ),
        ],
      ),
    );
  }
}
