import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'demodata.dart';
import '../models/video.dart';

class VideosAPI {
  List<Video> listVideos = <Video>[];
  late DocumentSnapshot lastData;
  final _firebase = FirebaseFirestore.instance.collection("VideosData");
  VideosAPI() {
    load();
  }
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

  void load() async {
    listVideos = await _getVideoList();
    listVideos = shuffle1(listVideos);
  }

  void addVideos() async {
    var list = await getMoreVideos();
    list = shuffle1(list);
    listVideos.addAll(list);
  }

  Future<List<Video>> _getVideoList() async {
    var data =
        await _firebase.where('Approved', isEqualTo: true).limit(10).get();
    var videoList = <Video>[];
    QuerySnapshot<Map<String, dynamic>> videos;

    if (data.docs.isEmpty) {
      await addDemoData();
      videos =
          (await _firebase.where('Approved', isEqualTo: true).limit(10).get());
    } else {
      videos = data;
    }
    lastData = data.docs.last;
    for (var element in videos.docs) {
      //docId.add(element.id);
      Video video = Video.fromJson(element.data());
      videoList.add(video);
    }

    return videoList;
  }

  Future<void> addDemoData() async {
    for (var video in data) {
      await _firebase.add(video);
    }
  }

  Future<List<Video>> getMoreVideos() async {
    var data = await _firebase
        .startAfterDocument(lastData)
        .where('Approved', isEqualTo: true)
        .limit(10)
        .get();
    var videoList = <Video>[];
    QuerySnapshot<Map<String, dynamic>> videos;
    videos = data;
    lastData = data.docs.last;
    for (var element in videos.docs) {
      // docId.add(element.id);
      Video video = Video.fromJson(element.data());
      videoList.add(video);
    }
    return videoList;
  }
}
