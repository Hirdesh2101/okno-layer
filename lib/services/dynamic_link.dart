import 'package:flutter/material.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get_it/get_it.dart';
import 'package:oknoapp/pages/shared_video.dart';
import '../providers/feedviewprovider.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class DynamicLinkService {
  final feedViewModel = GetIt.instance<FeedViewModel>();
  Future<void> retrieveDynamicLink(BuildContext context) async {
    try {
      final PendingDynamicLinkData? data =
          await FirebaseDynamicLinks.instance.getInitialLink();
      final Uri? deepLink = data?.link;

      if (deepLink != null) {
        String? id;
        if (deepLink.queryParameters.containsKey('id')) {
          id = deepLink.queryParameters['id']!;
        }
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SharedVideo(id!)));
      }
      FirebaseDynamicLinks.instance.onLink(
          onSuccess: (PendingDynamicLinkData? dynamicLink) async {
        final Uri? deepLink = dynamicLink?.link;
        String? id;
        if (deepLink!.queryParameters.containsKey('id')) {
          id = deepLink.queryParameters['id']!;
        }
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SharedVideo(id!)));
      });
    } catch (e) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.ERROR,
        animType: AnimType.BOTTOMSLIDE,
        title: e.toString(),
        desc: e.toString(),
        btnOkOnPress: () {},
      ).show();
    }
  }

  Future<Uri> createDynamicLink(String id) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://oknoapp.page.link',
      link: Uri.parse('https://www.oknoapp.com/?id=$id'),
      androidParameters: AndroidParameters(
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
    ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
    final Uri shortUrl = shortDynamicLink.shortUrl;
    return shortUrl;
  }
}
