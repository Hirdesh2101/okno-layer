import 'package:cloud_firestore/cloud_firestore.dart';
import 'demodata.dart';
import '../models/video.dart';

class VideosAPI {
  List<Video> listVideos = <Video>[];
  List<String> docId = <String>[];

  VideosAPI() {
    load();
  }

  void load() async {
    listVideos = await getVideoList();
  }

  Future<List<Video>> getVideoList() async {
    var data = await FirebaseFirestore.instance.collection("VideosData").get();
    var videoList = <Video>[];
    QuerySnapshot<Map<String, dynamic>> videos;

    if (data.docs.isEmpty) {
      await addDemoData();
      videos =
          (await FirebaseFirestore.instance.collection("VideosData").get());
    } else {
      videos = data;
    }

    for (var element in videos.docs) {
      docId.add(element.reference.id);
      Video video = Video.fromJson(element.data());
      videoList.add(video);
    }

    return videoList;
  }

  Future<void> addDemoData() async {
    for (var video in data) {
      await FirebaseFirestore.instance.collection("VideosData").add(video);
    }
  }
}
