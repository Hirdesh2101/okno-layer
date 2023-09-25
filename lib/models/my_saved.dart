import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../services/cache_service.dart';

class MySavedVideos {
  String id;
  String url;
  String product1;
  String product2;
  String seller;
  String price;
  String p1name;
  String store;
  String thumbnail;
  bool approved;

  VideoPlayerController? controller;
  BaseCacheManager? _cacheManager;

  MySavedVideos(
      {required this.id,
      required this.url,
      required this.approved,
      required this.product1,
      required this.product2,
      required this.seller,
      required this.p1name,
      required this.store,
      required this.thumbnail,
      required this.price});

  MySavedVideos.fromJson(Map<dynamic, dynamic> json)
      : id = json['id'],
        url = json['url'],
        p1name = json['p1name'],
        product1 = json['product1'],
        approved = json['Approved'],
        product2 = json['product2'],
        seller = json['seller'],
        store = json['store'],
        thumbnail = json['Thumbnail'],
        price = json['price'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['url'] = url;
    data['product1'] = product1;
    data['product2'] = product2;
    data['p1name'] = p1name;
    data['Thumbnail'] = thumbnail;
    data['Approved'] = approved;
    data['selller'] = seller;
    data['store'] = store;
    data['price'] = price;
    return data;
  }

  Future<void> loadController() async {
    if (kIsWeb) {
      controller = VideoPlayerController.network(url);
      await controller?.initialize();
      controller?.setLooping(true);
    } else {
      _cacheManager ??= CustomCacheManager.instance;
      final fileInfo = await _cacheManager?.getFileFromCache(url);
      if (fileInfo == null) {
        unawaited(_cacheManager!.downloadFile(url));
        controller = VideoPlayerController.network(url);
        await controller?.initialize();
        controller?.setLooping(true);
      } else {
        controller = VideoPlayerController.file(fileInfo.file);
        await controller?.initialize();
        controller?.setLooping(true);
      }
    }
  }

  Future<void> dispose() async {
    controller?.dispose();
  }
}
