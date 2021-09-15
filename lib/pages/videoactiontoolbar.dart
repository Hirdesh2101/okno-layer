import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import '../providers/feedviewprovider.dart';
import 'package:like_button/like_button.dart';
import './bottomsheet.dart';
import '../firebase functions/sidebar_fun.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActionToolBar extends StatefulWidget {
  final int index;
  // ignore: use_key_in_widget_constructors
  const ActionToolBar(this.index);

  @override
  _ActionToolBarState createState() => _ActionToolBarState();
}

class _ActionToolBarState extends State<ActionToolBar> {
  final locator = GetIt.instance;
  final feedViewModel = GetIt.instance<FeedViewModel>();
  final SideBarFirebase firebaseServices = SideBarFirebase();

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Align(
        alignment: Alignment.bottomCenter,
        child: OutlinedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (states) => Colors.black.withOpacity(0.5))),
          child: const Text(
            'View Product',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            feedViewModel.pauseVideo(widget.index);
            ProductDetails().sheet(context, widget.index);
          },
        ),
      ),
      Positioned(
        right: 0,
        bottom: 0,
        child: sideButtons(),
      )
    ]);
  }

  Widget sideButtons() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('VideosData').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
          } else {
            final documents = snapshot.data!.docs;
            List<dynamic> list = documents[widget.index]['Likes'];
            Future<bool> likeFunc(bool init) async {
              firebaseServices.add(
                  feedViewModel.videoSource!.docId[widget.index],
                  list.contains(firebaseServices.user) ? true : false);
              return !init;
            }

            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  LikeButton(
                    likeBuilder: (bool isLiked) {
                      return Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.white,
                        size: MediaQuery.of(context).size.width * 0.08,
                      );
                    },
                    isLiked:
                        list.contains(firebaseServices.user) ? true : false,
                    onTap: likeFunc,
                  ),
                  const SizedBox(
                    height: 150,
                  ),
                ]),
              ),
            );
          }
          return Container();
        });
  }
}
