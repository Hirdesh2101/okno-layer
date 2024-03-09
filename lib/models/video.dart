import 'dart:async';

import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../services/cache_service.dart';
import '../firebase functions/sidebar_fun.dart';

class Video {
  String id;
  String url;
  String product1;
  String product2;
  String seller;
  String price;
  String p1name;
  String store;

  VideoPlayerController? controller;
  BaseCacheManager? _cacheManager;

  Video(
      {required this.id,
      required this.url,
      required this.product1,
      required this.product2,
      required this.seller,
      required this.p1name,
      required this.store,
      required this.price});

  Video.fromJson(Map<dynamic, dynamic> json)
      : id = json['id'],
        url = json['url'],
        p1name = json['p1name'],
        product1 = json['product1'],
        product2 = json['product2'],
        seller = json['seller'],
        store = json['store'],
        price = json['price'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['url'] = url;
    data['product1'] = product1;
    data['product2'] = product2;
    data['p1name'] = p1name;
    data['seller'] = seller;
    data['store'] = store;
    data['price'] = price;
    return data;
  }

  final SideBarFirebase firebaseServices = SideBarFirebase();
  void checkVideo() {
    if (controller!.value.position ==
        const Duration(seconds: 0, minutes: 0, hours: 0)) {}
    if (controller!.value.position.inSeconds ==
        controller!.value.duration.inSeconds - 1) {
      firebaseServices.watchedVideo(id);
    }
  }

  Future<void> loadController() async {
      // _cacheManager ??= CustomCacheManager.instance;
      // final fileInfo = await _cacheManager?.getFileFromCache(url);
      // if (fileInfo == null) {
      // print('[VideoControllerService]: No video in cache');

      // print('[VideoControllerService]: Saving video to cache');
      //unawaited(_cacheManager!.downloadFile(url));
      controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      controller?.addListener(checkVideo);
      await controller?.initialize();
      controller?.setLooping(true);
      //}
      // else {
      //   // print('[VideoControllerService]: Loading video from cache');
      //   controller = VideoPlayerController.file(fileInfo.file);
      //   controller?.addListener(checkVideo);
      //   await controller?.initialize();
      //   controller?.setLooping(true);
      // }
    
  }

  Future<void> dispose() async {
    controller?.dispose();
  }
}
