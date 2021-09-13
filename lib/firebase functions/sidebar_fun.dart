import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/likes.dart';

class SideBarFirebase {
  final user = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _fireStoreDataBase = FirebaseFirestore.instance;

  Stream<List<Likes>> getUserList() {
    return _fireStoreDataBase.collection('VideosData').snapshots().map(
        (snapShot) => snapShot.docs
            .map((document) => Likes.fromJson(document.data()))
            .toList());
  }

  void add(dynamic docu, bool contains) {
    var obj = [user];
    if (contains) {
      FirebaseFirestore.instance
          .collection('VideosData')
          .doc(docu)
          .update({'Likes': FieldValue.arrayRemove(obj)});
    } else {
      FirebaseFirestore.instance
          .collection('VideosData')
          .doc(docu)
          .update({'Likes': FieldValue.arrayUnion(obj)});
    }
  }
}
