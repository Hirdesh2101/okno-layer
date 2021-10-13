import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/brand_model.dart';
import 'package:jiffy/jiffy.dart';

class BrandDeatilsAPI {
  List<String> listBrand = <String>[];
  List<String> listVideos = <String>[];
  List<BrandDetails> listData = <BrandDetails>[];

  BrandDeatilsAPI() {
    load();
  }

  Future<void> applyFilter() async {
    var now = DateTime.now();
    var previous = Jiffy(now).subtract(months: 1);
    for (int i = listData.length - 1; i >= 0; i--) {
      for (int j = listData[i].viewedproduct.length - 1; j >= 0; j--) {
        if (listData[i]
            .viewedproduct[j]['timestamp']
            .toDate()
            .isAfter(previous.dateTime)) {
          continue;
        } else {
          listData[i].viewedproduct.removeRange(0, j + 1);
          break;
        }
      }
    }
    for (int i = listData.length - 1; i >= 0; i--) {
      for (int j = listData[i].viewedurl.length - 1; j >= 0; j--) {
        if (listData[i]
            .viewedurl[j]['timestamp']
            .toDate()
            .isAfter(previous.dateTime)) {
          continue;
        } else {
          listData[i].viewedurl.removeRange(0, j + 1);
          break;
        }
      }
    }
  }

  Future<void> load() async {
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

  Future<List<BrandDetails>> getData() async {
    var detilslist = <BrandDetails>[];
    BrandDetails details;
    for (var element in listVideos) {
      await _firestore
          .collection("VideosDataAdmin")
          .doc(element)
          .get()
          .then((snapshot) {
        if (snapshot.exists) {
          details = BrandDetails.fromJson(snapshot.data()!);
          detilslist.add(details);
        }
      });
    }
    return detilslist;
  }
}
