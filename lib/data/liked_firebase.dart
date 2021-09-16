import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LikedVideosAPI {
  List<String> listVideos = <String>[];

  LikedVideosAPI() {
    load();
  }

  void load() {
    getLiked().listen((listofstring) {
      listVideos = listofstring;
    });
  }

  final user = FirebaseAuth.instance.currentUser!.uid;
  Stream<List<String>> getLiked() {
    return FirebaseFirestore.instance
        .collection("UsersData")
        .doc(user)
        .snapshots()
        .map((list) {
      return List.from(list.data()!['Likes']);
    });
  }
}
