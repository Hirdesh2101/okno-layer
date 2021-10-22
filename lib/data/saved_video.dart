import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/my_saved.dart';

class MySavedVideosAPI {
  List<String> listVideos = <String>[];
  List<MySavedVideos> listData = <MySavedVideos>[];
  int lastitemIndex = 0;
  int flag = 0;
  bool hasMore = true;
  bool isRunning = false;

  Future<void> load() async {
    if (flag == 0) {
      if (!isRunning) {
        isRunning = true;
        if (listData.isEmpty) {
          await getLiked().then((listofstring) async {
            listVideos = listofstring;
            listData.addAll(await getData());
          });
          flag = 1;
          isRunning = false;
        }
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
      return List.from(list.data()!['Saved']);
    });
  }

  Future<List<MySavedVideos>> getData() async {
    var videoList = <MySavedVideos>[];
    MySavedVideos video;
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
          video = MySavedVideos.fromJson(snapshot.data()!);
          videoList.add(video);
        }
      });
    }
    lastitemIndex += 10;
    return videoList;
  }
}
