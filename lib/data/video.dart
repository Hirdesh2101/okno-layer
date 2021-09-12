import 'package:video_player/video_player.dart';

class Video {
  String id;
  String url;
  String product1;
  String product2;
  String seller;
  String price;

  VideoPlayerController? controller;

  Video(
      {required this.id,
      required this.url,
      required this.product1,
      required this.product2,
      required this.seller,
      required this.price});

  Video.fromJson(Map<dynamic, dynamic> json)
      : id = json['id'],
        url = json['url'],
        product1 = json['product1'],
        product2 = json['product2'],
        seller = json['seller'],
        price = json['price'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['url'] = url;
    data['product1'] = product1;
    data['product2'] = product2;
    data['selller'] = seller;
    data['price'] = price;
    return data;
  }

  Future<void> loadController() async {
    controller = VideoPlayerController.network(url);
    await controller?.initialize();
    controller?.setLooping(true);
  }

  Future<void> dispose() async {
    controller?.dispose();
  }
}
