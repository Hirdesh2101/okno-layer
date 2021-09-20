import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/like_videos.dart';

class LikedVideosAPI {
  List<String> listVideos = <String>[];
  List<LikeVideo> listData = <LikeVideo>[];

  LikedVideosAPI() {
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
      return List.from(list.data()!['Likes']);
    });
  }

  Future<List<LikeVideo>> getData() async {
    var videoList = <LikeVideo>[];
    LikeVideo video;
    for (var element in listVideos) {
      await _firestore
          .collection("VideosData")
          .doc(element)
          .get()
          .then((snapshot) {
        video = LikeVideo.fromJson(snapshot.data()!);
        videoList.add(video);
      });
    }
    return videoList;
  }
}
