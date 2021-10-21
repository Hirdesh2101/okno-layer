import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/like_videos.dart';

class LikedVideosAPI {
  List<String> listVideos = <String>[];
  List<LikeVideo> listData = <LikeVideo>[];

  Future<void> load() async {
    await getLiked().then((listofstring) async {
      listVideos = listofstring;
      listData = await getData();
    });
  }

  final user = FirebaseAuth.instance.currentUser!.uid;
  final _firestore = FirebaseFirestore.instance;
  Future<List<String>> getLiked() {
    return _firestore.collection("UsersData").doc(user).get().then((list) {
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
        if (snapshot.data()!['deleted'] == false) {
          video = LikeVideo.fromJson(snapshot.data()!);
          videoList.add(video);
        }
      });
    }
    return videoList;
  }
}
