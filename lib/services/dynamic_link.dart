import 'package:flutter/material.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:oknoapp/pages/shared_video.dart';

class DynamicLinkService {
  Future<void> retrieveDynamicLink(BuildContext context) async {
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    _handleDeepLink(data!, context);
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLink) {
      final Uri? deepLink = dynamicLink.link;
      String? id;
      if (deepLink!.queryParameters.containsKey('id')) {
        id = deepLink.queryParameters['id']!;
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SharedVideo(id!)));
      } else {
        String? id;
        if (deepLink.queryParameters.containsKey('filter')) {
          id = deepLink.queryParameters['filter']!;
          //controller.add(id);
        }
      }
    });
  }

  _handleDeepLink(PendingDynamicLinkData data, BuildContext context) {
    final Uri? deepLink = data.link;
    if (deepLink != null) {
      String? id;
      if (deepLink.queryParameters.containsKey('id')) {
        id = deepLink.queryParameters['id']!;
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SharedVideo(id!)));
      } else {
        if (deepLink.queryParameters.containsKey('filter')) {
          String? id;
          if (deepLink.queryParameters.containsKey('filter')) {
            id = deepLink.queryParameters['filter']!;
            // controller.add(id);
          }
        }
      }
    }
  }

  Future<Uri> createDynamicLink(String id) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://oknoapp.page.link',
      link: Uri.parse('https://www.oknoapp.com/?id=$id'),
      androidParameters: const AndroidParameters(
        packageName: 'com.example.oknoapp',
        minimumVersion: 1,
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'OkNoApp',
        description: 'Download the app now',
        imageUrl: Uri.parse(
            'https://firebasestorage.googleapis.com/v0/b/okno-1ae24.appspot.com/o/pp%20(1).jpg?alt=media&token=2c3a7faa-0e59-4bce-bd3a-9a6fea16cf28'),
      ),
    );
    ShortDynamicLink shortDynamicLink =
        await FirebaseDynamicLinks.instance.buildShortLink(parameters);
    final Uri shortUrl = shortDynamicLink.shortUrl;
    return shortUrl;
  }
}
