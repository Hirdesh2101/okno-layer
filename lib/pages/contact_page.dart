import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:oknoapp/pages/webview.dart';
import '../services/launch_url.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Know More About us on the offical website!!'),
                  TextButton(
                    onPressed: () {
                      launchURL(context, 'https://www.oknoapp.com/');
                      // Navigator.of(context).push(MaterialPageRoute(
                      //     builder: (ctx) => const WebViewPage(
                      //         title: 'OkNoApp',
                      //         url: 'https://www.oknoapp.com/')));
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'oknoapp.com',
                            style: TextStyle(fontSize: 16),
                          ),
                          Icon(
                            Ionicons.open_outline,
                            //color: Colors.blue,
                            size: 16,
                          )
                        ]),
                  )
                ],
              ),
            ),
          ),
          const Align(
            alignment: Alignment.center,
            child: Text('Data'),
          ),
        ],
      ),
    );
  }
}
