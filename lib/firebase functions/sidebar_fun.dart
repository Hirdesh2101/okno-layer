import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SideBarFirebase {
  final user = FirebaseAuth.instance.currentUser!.uid;

  void add(dynamic docu, bool contains) {
    var obj = [user];
    var obj2 = [docu];
    if (contains) {
      FirebaseFirestore.instance
          .collection('VideosData')
          .doc(docu)
          .update({'Likes': FieldValue.arrayRemove(obj)});
      FirebaseFirestore.instance
          .collection('UsersData')
          .doc(user)
          .update({'Likes': FieldValue.arrayRemove(obj2)});
    } else {
      FirebaseFirestore.instance
          .collection('VideosData')
          .doc(docu)
          .update({'Likes': FieldValue.arrayUnion(obj)});

      FirebaseFirestore.instance
          .collection('UsersData')
          .doc(user)
          .update({'Likes': FieldValue.arrayUnion(obj2)});
    }
  }
}
