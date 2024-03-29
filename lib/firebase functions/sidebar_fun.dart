import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class SideBarFirebase {
  final user = FirebaseAuth.instance.currentUser!.uid;
  FirebaseApp otherFirebase = Firebase.app('okno');

  Future<void> add(dynamic docu, bool contains) async {
    var obj = [user];
    var obj2 = [docu];
    if (contains) {
      await FirebaseFirestore.instanceFor(app: otherFirebase)
          .collection('VideosData')
          .doc(docu)
          .update({'Likes': FieldValue.arrayRemove(obj)});
      await FirebaseFirestore.instanceFor(app: otherFirebase)
          .collection('UsersData')
          .doc(user)
          .update({'Likes': FieldValue.arrayRemove(obj2)});
    } else {
      await FirebaseFirestore.instanceFor(app: otherFirebase)
          .collection('VideosData')
          .doc(docu.toString().trim())
          .update({'Likes': FieldValue.arrayUnion(obj)});

      await FirebaseFirestore.instanceFor(app: otherFirebase)
          .collection('UsersData')
          .doc(user)
          .update({'Likes': FieldValue.arrayUnion(obj2)});
    }
  }

  Future<void> watchedVideo(dynamic docu) async {
    var obj = [docu];
    var obj2 = [user];
    await FirebaseFirestore.instanceFor(app: otherFirebase).collection('UsersData').doc(user).update(
        {'WatchedVideo': FieldValue.arrayUnion(obj)}).whenComplete(() {});
    FirebaseFirestore.instanceFor(app: otherFirebase)
        .collection('VideosDataAdmin')
        .doc(docu)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        FirebaseFirestore.instanceFor(app: otherFirebase)
            .collection('VideosDataAdmin')
            .doc(docu)
            .update({'WatchedVideo': FieldValue.arrayUnion(obj2)});
      } else {
        FirebaseFirestore.instanceFor(app: otherFirebase)
            .collection('VideosDataAdmin')
            .doc(docu)
            .set({'WatchedVideo': FieldValue.arrayUnion(obj2)});
      }
    });
  }

  Future<void> reportVideo(dynamic docu) async {
    var obj2 = [user];
    FirebaseFirestore.instanceFor(app: otherFirebase)
        .collection('VideosDataAdmin')
        .doc(docu)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        FirebaseFirestore.instanceFor(app: otherFirebase)
            .collection('VideosDataAdmin')
            .doc(docu)
            .update({'ReportedBy': FieldValue.arrayUnion(obj2)});
      } else {
        FirebaseFirestore.instanceFor(app: otherFirebase)
            .collection('VideosDataAdmin')
            .doc(docu)
            .set({'ReportedBy': FieldValue.arrayUnion(obj2)});
      }
    });
  }

  Future<void> saveVideo(dynamic docu) async {
    var obj2 = [docu];
    FirebaseFirestore.instanceFor(app: otherFirebase)
        .collection('UsersData')
        .doc(user)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        FirebaseFirestore.instanceFor(app: otherFirebase)
            .collection('UsersData')
            .doc(user)
            .update({'Saved': FieldValue.arrayUnion(obj2)});
      }
    });
  }

  Future<void> viewedProduct(dynamic docu) async {
    var obj = [
      {
        'user': user,
        'timestamp': DateTime.now(),
      }
    ];
    var storeid = '';
    await FirebaseFirestore.instanceFor(app: otherFirebase)
        .collection('VideosData')
        .doc(docu)
        .get()
        .then((value) {
      storeid = value.data()!['seller'];
    });
    await FirebaseFirestore.instanceFor(app: otherFirebase)
        .collection('VideosData')
        .doc(docu)
        .get()
        .then((value) async {
      if (value.data()!['userupload'] && value.data()!['uploadedby'] != user ||
          !value.data()!['userupload']) {
        await FirebaseFirestore.instanceFor(app: otherFirebase)
            .collection('UsersData')
            .doc(user)
            .get()
            .then((value2) async {
          if (!value2.data()!['BrandAssociated'].contains(storeid)) {
            await FirebaseFirestore.instanceFor(app: otherFirebase)
                .collection('VideosDataAdmin')
                .doc(docu)
                .get()
                .then((snapshot) async {
              if (snapshot.exists) {
                await FirebaseFirestore.instanceFor(app: otherFirebase)
                    .collection('VideosDataAdmin')
                    .doc(docu)
                    .update({'ViewedProduct': FieldValue.arrayUnion(obj)});
              } else {
                await FirebaseFirestore.instanceFor(app: otherFirebase)
                    .collection('VideosDataAdmin')
                    .doc(docu)
                    .set({'ViewedProduct': FieldValue.arrayUnion(obj)});
              }
            });
          }
        });
      }
    });
  }

  Future<void> viewedUrl(dynamic docu) async {
    var obj = [
      {
        'user': user,
        'timestamp': DateTime.now(),
      }
    ];
    var storeid = '';
    double? finalprice;
    await FirebaseFirestore.instanceFor(app: otherFirebase)
        .collection('VideosData')
        .doc(docu)
        .get()
        .then((value) {
      storeid = value.data()!['seller'];
      var price = value.data()!['value'];
      finalprice = double.parse('$price');
    });
    await FirebaseFirestore.instanceFor(app: otherFirebase)
        .collection('VideosData')
        .doc(docu)
        .get()
        .then((value) async {
      if (value.data()!['userupload'] && value.data()!['uploadedby'] != user ||
          !value.data()!['userupload']) {
        await FirebaseFirestore.instanceFor(app: otherFirebase)
            .collection('UsersData')
            .doc(user)
            .get()
            .then((value2) async {
          if (!value2.data()!['BrandAssociated'].contains(storeid)) {
            await FirebaseFirestore.instanceFor(app: otherFirebase)
                .collection('VideosDataAdmin')
                .doc(docu)
                .get()
                .then((snapshot) async {
              if (snapshot.exists) {
                await FirebaseFirestore.instanceFor(app: otherFirebase)
                    .collection('VideosDataAdmin')
                    .doc(docu)
                    .update({'ViewedUrl': FieldValue.arrayUnion(obj)});
              }
            });
          }
        });
      }
    });
    await FirebaseFirestore.instanceFor(app: otherFirebase)
        .collection('VideosData')
        .doc(docu)
        .get()
        .then((value) async {
      if (value.data()!['userupload']) {
        if (value.data()!['uploadedby'] != user) {
          var user = value.data()!['uploadedby'];
          var price = value.data()!['value'];
          await FirebaseFirestore.instanceFor(app: otherFirebase)
              .collection('UsersData')
              .doc(user)
              .get()
              .then((value2) async {
            if (!value2.data()!['BrandAssociated'].contains(storeid)) {
              double finalprice = double.parse('$price');
              double balance = 0;
              await FirebaseFirestore.instanceFor(app: otherFirebase)
                  .collection('UsersData')
                  .doc(user)
                  .get()
                  .then((value) {
                balance = (value.data()!['Balance']);
                balance += finalprice;
              });
              await FirebaseFirestore.instanceFor(app: otherFirebase)
                  .collection('UsersData')
                  .doc(user)
                  .update({'Balance': balance});
            }
          });
        }
      }
    });

    await FirebaseFirestore.instanceFor(app: otherFirebase)
        .collection('UsersData')
        .doc(user)
        .get()
        .then((value) async {
      if (!value.data()!['BrandAssociated'].contains(storeid)) {
        await FirebaseFirestore.instanceFor(app: otherFirebase)
            .collection('VideosData')
            .doc(docu)
            .get()
            .then((value) async {
          if (value.data()!['userupload'] &&
                  value.data()!['uploadedby'] != user ||
              !value.data()!['userupload']) {
            double balance = 0;
            await FirebaseFirestore.instanceFor(app: otherFirebase)
                .collection('BrandData')
                .doc(storeid)
                .get()
                .then((value) {
              var value1 = value.data()!['balance'].toDouble();
              balance = value1;
              balance -= finalprice!;
            });
            await FirebaseFirestore.instanceFor(app: otherFirebase)
                .collection('BrandData')
                .doc(storeid)
                .update({'balance': balance});
          }
        });
      }
    });
  }
}
