import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/my_saved.dart';

class MySavedVideosAPI {
  List<String> listVideos = <String>[];
  List<MySavedVideos> listData = <MySavedVideos>[];

  MySavedVideosAPI() {
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
      return List.from(list.data()!['Saved']);
    });
  }

  Future<List<MySavedVideos>> getData() async {
    var videoList = <MySavedVideos>[];
    MySavedVideos video;
    for (var element in listVideos) {
      await _firestore
          .collection("VideosData")
          .doc(element)
          .get()
          .then((snapshot) {
        video = MySavedVideos.fromJson(snapshot.data()!);
        videoList.add(video);
      });
    }
    return videoList;
  }
}
