import 'package:cloud_firestore/cloud_firestore.dart';
import 'demodata.dart';
import '../models/video.dart';

class VideosAPI {
  List<Video> listVideos = <Video>[];
  List<String> docId = <String>[];
  late DocumentSnapshot lastData;
  final _firebase = FirebaseFirestore.instance.collection("VideosData");
  VideosAPI() {
    load();
  }
  void load() async {
    listVideos = await getVideoList();
  }

  void addVideos() async {
    var list = await getMoreVideos();
    listVideos.addAll(list);
  }

  Future<List<Video>> getVideoList() async {
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
      docId.add(element.reference.id);
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
      docId.add(element.reference.id);
      Video video = Video.fromJson(element.data());
      videoList.add(video);
    }
    return videoList;
  }
}
