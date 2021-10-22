import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/like_videos.dart';

class LikedVideosAPI {
  List<String> listVideos = <String>[];
  List<LikeVideo> listData = <LikeVideo>[];
  int lastitemIndex = 0;
  int flag = 0;
  bool hasMore = true;
  bool isRunning = false;

  Future<void> load() async {
    if (flag == 0) {
      if (!isRunning) {
        isRunning = true;
        await getLiked().then((listofstring) async {
          listVideos = listofstring;
          listData.addAll(await getData());
        });
        flag = 1;
        isRunning = false;
      }
    } else {
      if (!isRunning) {
        isRunning = true;
        listData.addAll(await getData());
        isRunning = false;
      }
    }
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
    for (int i = lastitemIndex; i < lastitemIndex + 10; i++) {
      if (i > listVideos.length - 1) {
        hasMore = false;
        break;
      }
      await _firestore
          .collection("VideosData")
          .doc(listVideos[i])
          .get()
          .then((snapshot) {
        if (snapshot.data()!['deleted'] == false) {
          video = LikeVideo.fromJson(snapshot.data()!);
          videoList.add(video);
        }
      });
    }
    lastitemIndex += 10;
    return videoList;
  }
}
