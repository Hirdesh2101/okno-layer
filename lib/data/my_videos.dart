import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oknoapp/models/my_videos.dart';

class MyVideosAPI {
  List<String> listVideos = <String>[];
  List<MyVideos> listData = <MyVideos>[];
  List<MyVideos> approvedData = <MyVideos>[];
  List<MyVideos> nonapprovedData = <MyVideos>[];
  int lastitemIndex = 0;
  int flag = 0;
  bool hasMore = true;
  bool isRunning = false;
  int lastitemIndexapproved = 0;
  int flagapproved = 0;
  bool hasMoreapproved = true;
  bool isRunningapproved = false;
  int lastitemIndexnonapproved = 0;
  int flagnonapproved = 0;
  bool hasMorenonapproved = true;
  bool isRunningnonapproved = false;

  // MyVideosAPI() {
  //   loading();
  // }

  // Future<void> loading() async {
  //   await getLiked().then((value) async {
  //     listVideos = value;
  //   });
  // }

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

  Future<void> loadapproved() async {
    if (flagapproved == 0) {
      if (!isRunningapproved) {
        isRunningapproved = true;
        if (approvedData.isEmpty) {
          await getLiked().then((listofstring) async {
            listVideos = listofstring;
            approvedData.addAll(await getApprovedData());
          });
          flagapproved = 1;
          isRunningapproved = false;
        }
      }
    } else {
      if (!isRunningapproved) {
        isRunningapproved = true;
        approvedData.addAll(await getApprovedData());
        isRunningapproved = false;
      }
    }
  }

  Future<void> loadnonApproved() async {
    if (flagnonapproved == 0) {
      if (!isRunningnonapproved) {
        isRunningnonapproved = true;
        if (nonapprovedData.isEmpty) {
          await getLiked().then((listofstring) async {
            listVideos = listofstring;
            nonapprovedData.addAll(await getNonApprovedData());
          });
          flagnonapproved = 1;
          isRunningnonapproved = false;
        }
      }
    } else {
      if (!isRunningnonapproved) {
        isRunningnonapproved = true;
        nonapprovedData.addAll(await getNonApprovedData());
        isRunningnonapproved = false;
      }
    }
  }

  final user = FirebaseAuth.instance.currentUser!.uid;
  final _firestore = FirebaseFirestore.instance;
  Future<List<String>> getLiked() {
    return _firestore.collection("UsersData").doc(user).get().then((list) {
      return List.from(list.data()!['MyVideos']);
    });
  }

  Future<List<MyVideos>> getData() async {
    var videoList = <MyVideos>[];
    MyVideos video;
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
          video = MyVideos.fromJson(snapshot.data()!);
          videoList.add(video);
        }
      });
    }
    lastitemIndex += 10;
    if (videoList.length < 9 && hasMore) {
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
            video = MyVideos.fromJson(snapshot.data()!);
            videoList.add(video);
          }
        });
      }
      lastitemIndex += 10;
    }
    return videoList;
  }

  Future<List<MyVideos>> getApprovedData() async {
    var videoList = <MyVideos>[];
    MyVideos video;
    for (int i = lastitemIndexapproved; i < lastitemIndexapproved + 10; i++) {
      if (i > listVideos.length - 1) {
        hasMoreapproved = false;
        break;
      }
      await _firestore
          .collection("VideosData")
          .doc(listVideos[i])
          .get()
          .then((snapshot) {
        if (snapshot.data()!['deleted'] == false) {
          video = MyVideos.fromJson(snapshot.data()!);
          if (video.approved) {
            videoList.add(video);
          }
        }
      });
    }
    lastitemIndexapproved += 10;
    if (videoList.length < 9 && hasMoreapproved) {
      for (int i = lastitemIndexapproved; i < lastitemIndexapproved + 10; i++) {
        if (i > listVideos.length - 1) {
          hasMoreapproved = false;
          break;
        }
        await _firestore
            .collection("VideosData")
            .doc(listVideos[i])
            .get()
            .then((snapshot) {
          if (snapshot.data()!['deleted'] == false) {
            video = MyVideos.fromJson(snapshot.data()!);
            if (video.approved) {
              videoList.add(video);
            }
          }
        });
      }

      lastitemIndexapproved += 10;
    }
    return videoList;
  }

  Future<List<MyVideos>> getNonApprovedData() async {
    var videoList = <MyVideos>[];
    MyVideos video;
    for (int i = lastitemIndexnonapproved;
        i < lastitemIndexnonapproved + 10;
        i++) {
      if (i > listVideos.length - 1) {
        hasMorenonapproved = false;
        break;
      }
      await _firestore
          .collection("VideosData")
          .doc(listVideos[i])
          .get()
          .then((snapshot) {
        if (snapshot.data()!['deleted'] == false) {
          video = MyVideos.fromJson(snapshot.data()!);
          if (!video.approved) {
            videoList.add(video);
          }
        }
      });
    }
    lastitemIndexnonapproved += 10;
    if (videoList.length < 9 && hasMorenonapproved) {
      for (int i = lastitemIndexnonapproved;
          i < lastitemIndexnonapproved + 10;
          i++) {
        if (i > listVideos.length - 1) {
          hasMorenonapproved = false;
          break;
        }
        await _firestore
            .collection("VideosData")
            .doc(listVideos[i])
            .get()
            .then((snapshot) {
          if (snapshot.data()!['deleted'] == false) {
            video = MyVideos.fromJson(snapshot.data()!);
            if (!video.approved) {
              videoList.add(video);
            }
          }
        });
      }

      lastitemIndexnonapproved += 10;
    }
    return videoList;
  }
}
