import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/video.dart';

class VideoFilterAPI {
  List<Video> listVideos = <Video>[];
  late DocumentSnapshot lastData;
  final _firebase = FirebaseFirestore.instance.collection("VideosData");

  List<Video> shuffle1(List<Video> items) {
    var random = Random();

    for (var i = items.length - 1; i > 0; i--) {
      var n = random.nextInt(i + 1);

      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }
    return items;
  }

  Future<void> load(List tags) async {
    listVideos = await _getVideoList(tags);
    listVideos = shuffle1(listVideos);
  }

  void addVideos(List tags) async {
    var list = await getMoreVideos(tags);
    list = shuffle1(list);
    listVideos.addAll(list);
  }

  Future<List<Video>> _getVideoList(List tags) async {
    var data = await _firebase
        .where('Approved', isEqualTo: true)
        .where('tags', arrayContainsAny: tags)
        .limit(10)
        .get();
    var videoList = <Video>[];
    QuerySnapshot<Map<String, dynamic>> videos;
    videos = data;
    lastData = data.docs.last;
    for (var element in videos.docs) {
      Video video = Video.fromJson(element.data());
      videoList.add(video);
    }
    return videoList;
  }

  Future<List<Video>> getMoreVideos(List tags) async {
    var data = await _firebase
        .startAfterDocument(lastData)
        .where('Approved', isEqualTo: true)
        .where('tags', arrayContainsAny: tags)
        .limit(10)
        .get();
    var videoList = <Video>[];
    QuerySnapshot<Map<String, dynamic>> videos;
    videos = data;
    lastData = data.docs.last;
    for (var element in videos.docs) {
      Video video = Video.fromJson(element.data());
      videoList.add(video);
    }
    return videoList;
  }
}
