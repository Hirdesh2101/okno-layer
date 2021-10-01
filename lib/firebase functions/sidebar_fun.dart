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
          .doc(docu.toString().trim())
          .update({'Likes': FieldValue.arrayUnion(obj)});

      await FirebaseFirestore.instance
          .collection('UsersData')
          .doc(user)
          .update({'Likes': FieldValue.arrayUnion(obj2)});
    }
  }

  Future<void> watchedVideo(dynamic docu) async {
    // print('aya');
    var obj = [docu];
    var obj2 = [user];
    int length = 0;
    await FirebaseFirestore.instance
        .collection('UsersData')
        .doc(user)
        .update({'WatchedVideo': FieldValue.arrayUnion(obj)}).whenComplete(() {
      //  print('done');
    });
    FirebaseFirestore.instance
        .collection('VideosDataAdmin')
        .doc(docu)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        if (snapshot.data()!['WatchedVideo'] != null) {
          length = (snapshot.data()!['WatchedVideo'].length);
        }
      }
    });
    if (length > 0) {
      FirebaseFirestore.instance
          .collection('VideosDataAdmin')
          .doc(docu)
          .update({'WatchedVideo': FieldValue.arrayUnion(obj2)});
    } else {
      FirebaseFirestore.instance
          .collection('VideosDataAdmin')
          .doc(docu)
          .set({'WatchedVideo': FieldValue.arrayUnion(obj2)});
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
        if (snapshot.data()!['ViewedProduct'] != null) {
          length = (snapshot.data()!['ViewedProduct'].length);
        }
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
  }

  Future<void> viewedUrl(dynamic docu) async {
    var obj = [user];
    int length = 0;
    await FirebaseFirestore.instance
        .collection('VideosDataAdmin')
        .doc(docu)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        if (snapshot.data()!['ViewedUrl'] != null) {
          length = (snapshot.data()!['ViewedUrl'].length);
        }
      }
    });
    if (length > 0) {
      await FirebaseFirestore.instance
          .collection('VideosDataAdmin')
          .doc(docu)
          .update({'ViewedUrl': FieldValue.arrayUnion(obj)});
    } else {
      await FirebaseFirestore.instance
          .collection('VideosDataAdmin')
          .doc(docu)
          .update({'ViewedUrl': FieldValue.arrayUnion(obj)});
    }
  }
}
