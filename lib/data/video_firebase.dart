import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'demodata.dart';
import '../models/video.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/merge_sort.dart';
import '../services/binar_search.dart';

class VideosAPI {
  List<Video> listVideos = <Video>[];
  late DocumentSnapshot lastData;
  final user = FirebaseAuth.instance.currentUser!.uid;
  List? userlist;
  final _sorting = MergeSort();
  final _search = BinarySearch();
  final _firebase = FirebaseFirestore.instance.collection("VideosData");
  VideosAPI() {
    load(0);
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
    futureslist.add(load(1));
    return futureslist;
  }

  Future<void> load(int flag) async {
    if (flag == 0) {
      userlist = await _viewedProduct();
      _sorting.mergeSort(userlist!, 0, userlist!.length - 1);
      listVideos = await _getVideoList();

      for (int i = 0; i < listVideos.length; i++) {
        int temp =
            _search.count2(userlist!, userlist!.length, listVideos[i].id);
        if (temp != -1) {
          listVideos.remove(listVideos[i]);
          i--;
        }
      }
      if (listVideos.length <= 1) {
        addVideos();
      }
      listVideos = shuffle1(listVideos);
    } else {
      var temp = await _viewedProduct();
      var tem2 = await _getVideoList();
      tem2.clear();
      temp.clear();
    }
  }

  Future<void> delete() async {
    var obj2 = [];
    await FirebaseFirestore.instance
        .collection('UsersData')
        .doc(user)
        .update({'WatchedVideo': FieldValue.delete()});
    await FirebaseFirestore.instance
        .collection('UsersData')
        .doc(user)
        .update({'WatchedVideo': FieldValue.arrayUnion(obj2)});
  }

  void addVideos() async {
    var list = await getMoreVideos();
    for (int i = 0; i < list.length; i++) {
      int temp = _search.count2(userlist!, userlist!.length, list[i].id);
      if (temp != -1) {
        list.remove(list[i]);
        i--;
      }
    }
    list = shuffle1(list);
    listVideos.addAll(list);
  }

  Future<List> _viewedProduct() async {
    List? userlist2 = [];
    await FirebaseFirestore.instance
        .collection('UsersData')
        .doc(user)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        if (snapshot.data()!['WatchedVideo'] != null) {
          userlist2 = (snapshot.data()!['WatchedVideo']);
        }
      }
    });
    return userlist2!;
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
      Video video = Video.fromJson(element.data());
      videoList.add(video);
    }
    return videoList;
  }
}
