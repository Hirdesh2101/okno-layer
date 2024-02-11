import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:oknoapp/data/demodata.dart';
import 'package:oknoapp/models/video.dart';
import 'package:oknoapp/services/binar_search.dart';
import 'package:oknoapp/services/merge_sort.dart';

class FeedViewModel extends ChangeNotifier {
  int prevVideo = 0;
  bool? creatingLink = false;
  int currentscreen = 0;
  bool isBusy = false;

  List<Video> listVideos = <Video>[];
  late DocumentSnapshot lastData;
  final user = FirebaseAuth.instance.currentUser!.uid;
  List? userlist;
  final _sorting = MergeSort();
  final _search = BinarySearch();
  final _firebase = FirebaseFirestore.instance.collection("VideosData");

  List<Video> shuffle1(List<Video> items) {
    items.shuffle();
    return items;
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
        isBusy = false;
       initial();
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
      notifyListeners();
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

  FeedViewModel() {
    isBusy = true;
    load(0);
  }
  dynamic length() {
    return listVideos.length;
  }

  initial() async {
    await _initializeControllerAtIndex(0);

    /// Play 1st video
    _playControllerAtIndex(0);

    /// Initialize 2nd vide
    await _initializeControllerAtIndex(1);
  }

  onpageChanged(int index) {
    if ((index + 3) >= length()) {
      addVideos();
      notifyListeners();
    }
    if (index > currentscreen) {
      playNext(index);
    } else {
      playPrevious(index);
    }
    currentscreen = index;
  }

  void startCircularProgess() {
    creatingLink = true;
    notifyListeners();
  }

  void endCircularProgess() {
    creatingLink = false;
    notifyListeners();
  }

  void seekZero() async {
    if (listVideos.isNotEmpty) {
      await listVideos[currentscreen].controller?.seekTo(Duration.zero);
      notifyListeners();
    }
  }

  Future<void> pauseDrawer() async {
    if (listVideos.isNotEmpty) {
      await listVideos[currentscreen].controller?.pause();
      // notifyListeners();
    }
  }

  Future<void> playDrawer() async {
    if (listVideos.isNotEmpty) {
      listVideos[currentscreen].controller?.play();
      // notifyListeners();
    }
  }

  void pauseVideo(int index) async {
    if (listVideos.length > index) {
      await listVideos[index].controller?.pause();
      // notifyListeners();
    }
  }

  void playVideo(int index) async {
    if (listVideos.length > index) {
      listVideos[index].controller?.play();
      //notifyListeners();
    }
  }

  void playNext(int index) {
    /// Stop [index - 1] controller
    _stopControllerAtIndex(index - 1);

    /// Dispose [index - 2] controller
    _disposeControllerAtIndex(index - 2);

    /// Play current video (already initialized)
    _playControllerAtIndex(index);

    /// Initialize [index + 1] controller
    _initializeControllerAtIndex(index + 1);
  }

  void playPrevious(int index) {
    /// Stop [index + 1] controller
    _stopControllerAtIndex(index + 1);

    /// Dispose [index + 2] controller
    _disposeControllerAtIndex(index + 2);

    /// Play current video (already initialized
    // if (!listVideos[index].controller!.value.isInitialized) {
    //   _initializeControllerAtIndex(index);
    //   notifyListeners();
    // }
    _playControllerAtIndex(index);

    /// Initialize [index - 1] controller
    _initializeControllerAtIndex(index - 1);
  }

  Future _initializeControllerAtIndex(int index) async {
    if (listVideos.length > index && index >= 0) {
      /// Create new controller
      await listVideos[index].loadController();
      notifyListeners();
      //log('🚀🚀🚀 INITIALIZED $index');
    }
  }

  void _playControllerAtIndex(int index) {
    if (listVideos.length > index && index >= 0) {
      /// Get controller at [index]
      listVideos[index].controller?.play();
      // notifyListeners();
      //log('🚀🚀🚀 PLAYING $index');
    }
  }

  void _stopControllerAtIndex(int index) {
    if (listVideos.length > index && index >= 0) {
      /// Get controller at [index]
      listVideos[index].controller?.pause();
      //notifyListeners();

      //log('🚀🚀🚀 STOPPED $index');
    }
  }

  void _disposeControllerAtIndex(int index) {
    if (listVideos.length > index && index >= 0) {
      /// Get controller at [index]
      listVideos[index].controller?.dispose();
      //notifyListeners();
      //log('🚀🚀🚀 DISPOSED $index');
    }
  }

  Future<void> disposingall() async {
    if (listVideos[currentscreen].controller != null) {
      await listVideos[currentscreen].controller?.dispose();
    }
    if (currentscreen + 1 < listVideos.length) {
      if (listVideos[currentscreen + 1].controller != null) {
        await listVideos[currentscreen + 1].controller?.dispose();
      }
    }
    if (currentscreen - 1 >= 0) {
      if (listVideos[currentscreen - 1].controller != null) {
        await listVideos[currentscreen - 1].controller?.dispose();
      }
    }
    //notifyListeners();
  }
}
