import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oknoapp/models/my_videos.dart';

class MyVideosAPI {
  List<String> listVideos = <String>[];
  List<MyVideos> listData = <MyVideos>[];

  MyVideosAPI() {
    load();
  }

  void load() {
    getLiked().listen((listofstring) async {
      listVideos = listofstring;
      listData = await getData();
    });
  }

  final user = FirebaseAuth.instance.currentUser!.uid;
  final _firestore = FirebaseFirestore.instance;
  Stream<List<String>> getLiked() {
    return _firestore.collection("UsersData").doc(user).snapshots().map((list) {
      return List.from(list.data()!['MyVideos']);
    });
  }

  Future<List<MyVideos>> getData() async {
    var videoList = <MyVideos>[];
    MyVideos video;
    for (var element in listVideos) {
      await _firestore
          .collection("VideosData")
          .doc(element)
          .get()
          .then((snapshot) {
        video = MyVideos.fromJson(snapshot.data()!);
        videoList.add(video);
      });
    }
    return videoList;
  }
}
