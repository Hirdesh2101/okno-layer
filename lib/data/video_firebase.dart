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
    items.shuffle();
    return items;
  }

  List<Future> loading() {
    var futureslist = <Future>[];
    futureslist.add(load(1));
    return futureslist;
  }

  Future<void> load(int flag) async {
    if (listVideos.isEmpty) {
      if (flag == 0) {
        userlist = await _viewedProduct();
        _sorting.mergeSort(userlist!, 0, userlist!.length - 1);
        listVideos = await _getVideoList();
        bool initialSize = listVideos.length == 1;

        for (int i = 0; i < listVideos.length; i++) {
          int temp =
              _search.count2(userlist!, userlist!.length, listVideos[i].id);
          if (temp != -1) {
            listVideos.remove(listVideos[i]);
            i--;
          }
        }
        if (!initialSize && listVideos.length <= 1) {
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
    if (list.isNotEmpty) {
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
    var data = await _firebase
        .where('Approved', isEqualTo: true)
        .where('deleted', isEqualTo: false)
        .limit(10)
        .get();
    var videoList = <Video>[];
    QuerySnapshot<Map<String, dynamic>> videos;
    videos = data;
    if (data.docs.isEmpty) {
      //await addDemoData();
      // videos =
      //     (await _firebase.where('Approved', isEqualTo: true).limit(10).get());
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
      var timestamp = DateTime.now().toString();
      await _firebase.doc(timestamp).set(video);
    }
  }

  Future<List<Video>> getMoreVideos() async {
    var data = await _firebase
        .startAfterDocument(lastData)
        .where('Approved', isEqualTo: true)
        .where('deleted', isEqualTo: false)
        //.where('id', whereNotIn: list)
        .limit(10)
        .get();
    var videoList = <Video>[];
    QuerySnapshot<Map<String, dynamic>> videos;
    if (data.docs.isNotEmpty) {
      videos = data;
      lastData = data.docs.last;
      for (var element in videos.docs) {
        Video video = Video.fromJson(element.data());
        videoList.add(video);
      }
    }

    return videoList;
  }
}
