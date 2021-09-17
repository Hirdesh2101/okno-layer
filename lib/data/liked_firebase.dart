import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/video.dart';

class LikedVideosAPI {
  List<String> listVideos = <String>[];
  List<Video> listData = <Video>[];

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

  Future<List<Video>> getData() async {
    var videoList = <Video>[];
    Video video;
    for (var element in listVideos) {
      await _firestore
          .collection("VideosData")
          .doc(element)
          .get()
          .then((snapshot) {
        video = Video.fromJson(snapshot.data()!);
        videoList.add(video);
      });
    }
    return videoList;
  }
}
