import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'demodata.dart';
import '../models/video.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VideosAPI {
  List<Video> listVideos = <Video>[];
  late DocumentSnapshot lastData;
  final user = FirebaseAuth.instance.currentUser!.uid;
  List? userlist;
  final _firebase = FirebaseFirestore.instance.collection("VideosData");
  VideosAPI() {
    load();
  }
  List<Video> shuffle1(List<Video> items) {
    var random = Random();

    for (var i = items.length - 1; i > 0; i--) {
      var n = random.nextInt(i + 1);

      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }

    return items;
  }

  List<Future> loading() {
    var futureslist = <Future>[];
    futureslist.add(load());
    return futureslist;
  }

  Future<void> load() async {
    await _viewedProduct();
    listVideos = await _getVideoList();
    listVideos.removeWhere((element) => userlist!.contains(element.id));
    listVideos = shuffle1(listVideos);
  }

  void addVideos() async {
    var list = await getMoreVideos();
    list.removeWhere((element) => userlist!.contains(element));
    list = shuffle1(list);
    listVideos.addAll(list);
  }

  Future<void> _viewedProduct() async {
    await FirebaseFirestore.instance
        .collection('UsersData')
        .doc(user)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        if (snapshot.data()!['WatchedVideo'] != null) {
          userlist = (snapshot.data()!['WatchedVideo']);
        }
      }
    });
  }

  Future<List<Video>> _getVideoList() async {
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
      //docId.add(element.id);
      Video video = Video.fromJson(element.data());
      videoList.add(video);
    }
    return videoList;
  }

  Future<void> addDemoData() async {
    for (var video in data) {
      await _firebase.add(video).then((DocumentReference doc) {
        String docId = doc.id;
        _firebase.doc(docId).update({"id": docId});
      });
    }
  }

  Future<List<Video>> getMoreVideos() async {
    var data = await _firebase
        .startAfterDocument(lastData)
        .where('Approved', isEqualTo: true)
        //.where('id', whereNotIn: list)
        .limit(10)
        .get();
    var videoList = <Video>[];
    QuerySnapshot<Map<String, dynamic>> videos;
    videos = data;
    lastData = data.docs.last;
    for (var element in videos.docs) {
      // docId.add(element.id);
      Video video = Video.fromJson(element.data());
      videoList.add(video);
    }
    return videoList;
  }
}
