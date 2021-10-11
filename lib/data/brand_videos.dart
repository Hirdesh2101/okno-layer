import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oknoapp/models/brand_videos.dart';

class BrandVideosAPI {
  List<String> listBrand = <String>[];
  List<String> listVideos = <String>[];
  List<BrandVideos> listData = <BrandVideos>[];

  BrandVideosAPI() {
    load();
  }

  void load() {
    getBrand().then((listofstring) async {
      listBrand = listofstring;
      await getVideos().then((value) async {
        listVideos = value;
        listData = await getData();
      });
    });
  }

  final user = FirebaseAuth.instance.currentUser!.uid;
  final _firestore = FirebaseFirestore.instance;
  Future<List<String>> getBrand() {
    return _firestore.collection("UsersData").doc(user).get().then((value) {
      return List.from(value.data()!['BrandAssociated']);
    });
  }

  Future<List<String>> getVideos() async {
    List<String> videoList = List.empty();
    for (var element in listBrand) {
      await _firestore
          .collection("BrandData")
          .doc(element)
          .get()
          .then((snapshot) {
        var list = List<String>.from(snapshot.data()!['Videos']);
        videoList = [list].expand((element) => element).toList();
      });
    }
    return videoList;
  }

  Future<List<BrandVideos>> getData() async {
    var videoList = <BrandVideos>[];
    BrandVideos video;
    for (var element in listVideos) {
      await _firestore
          .collection("VideosData")
          .doc(element)
          .get()
          .then((snapshot) {
        video = BrandVideos.fromJson(snapshot.data()!);
        videoList.add(video);
      });
    }
    return videoList;
  }
}
