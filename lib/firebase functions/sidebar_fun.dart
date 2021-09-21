import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SideBarFirebase {
  final user = FirebaseAuth.instance.currentUser!.uid;

  Future<void> add(dynamic docu, bool contains) async {
    var obj = [user];
    var obj2 = [docu];
    if (contains) {
      await FirebaseFirestore.instance
          .collection('VideosData')
          .doc(docu)
          .update({'Likes': FieldValue.arrayRemove(obj)});
      await FirebaseFirestore.instance
          .collection('UsersData')
          .doc(user)
          .update({'Likes': FieldValue.arrayRemove(obj2)});
    } else {
      await FirebaseFirestore.instance
          .collection('VideosData')
          .doc(docu)
          .update({'Likes': FieldValue.arrayUnion(obj)});

      await FirebaseFirestore.instance
          .collection('UsersData')
          .doc(user)
          .update({'Likes': FieldValue.arrayUnion(obj2)});
    }
  }

  Future<void> viewedProduct(dynamic docu) async {
    var obj = [user];
    int length = 0;
    await FirebaseFirestore.instance
        .collection('VideosDataAdmin')
        .doc(docu)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        length = (snapshot.data()!['ViewedProduct'].length);
      }
    });
    if (length > 0) {
      await FirebaseFirestore.instance
          .collection('VideosDataAdmin')
          .doc(docu)
          .update({'ViewedProduct': FieldValue.arrayUnion(obj)});
    } else {
      await FirebaseFirestore.instance
          .collection('VideosDataAdmin')
          .doc(docu)
          .set({'ViewedProduct': FieldValue.arrayUnion(obj)});
    }
    //.set({'ViewedProduct': FieldValue.arrayUnion(obj)});
  }
}
