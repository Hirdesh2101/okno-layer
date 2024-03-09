import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readmore/readmore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Comments extends StatefulWidget {
  final String id;
  const Comments(this.id, {Key? key}) : super(key: key);
  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  final TextEditingController _textEditingController = TextEditingController();
  //bool _isUploading = false;
  final user = FirebaseAuth.instance.currentUser;
  FirebaseApp otherFirebase = Firebase.app('okno');

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _addcomment() async {
    if (_textEditingController.text.trim() != '') {
      // setState(() {
      //   _isUploading = true;
      // });
      var obj = [
        {'Comment': _textEditingController.text.trim(), 'uid': user!.uid}
      ];
      await FirebaseFirestore.instanceFor(app: otherFirebase)
          .collection('VideosData')
          .doc(widget.id.trim())
          .update({'Comments': FieldValue.arrayUnion(obj)});
      _textEditingController.clear();
      FocusScope.of(context).unfocus();
      // setState(() {
      //   _isUploading = false;
      // });
    } else {
      Fluttertoast.showToast(
          msg: "Enter a valid Comment",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Comments",
          //style: TextStyle(color: Colors.grey),
        ),
        elevation: 0,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: StreamBuilder(
                stream: FirebaseFirestore.instanceFor(app: otherFirebase)
                    .collection('VideosData')
                    .where('id', isEqualTo: widget.id.trim())
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('ERROR'),
                    );
                  }
                  List<dynamic> temp = snapshot.data!.docs.first['Comments'];
                  List<dynamic> list = temp.reversed.toList();
                  if (list.isEmpty) {
                    return const Center(child: Text("No Comments Yet...."));
                  }
                  return ListView.builder(
                    // physics: const BouncingScrollPhysics(),
                    itemBuilder: (_, int index) {
                      return Column(
                        children: [
                          FutureBuilder(
                              future: FirebaseFirestore.instanceFor(app: otherFirebase)
                                  .collection('UsersData')
                                  .doc(list[index]['uid'])
                                  .get(),
                              builder: (context, snapshot) {
                                dynamic data = snapshot.data;
                                if (!snapshot.hasData) {
                                  return const ListTile(
                                    leading: CircleAvatar(
                                      radius: 15,
                                      //backgroundColor: Colors.black26,
                                    ),
                                    title: Text('Loading...'),
                                  );
                                }
                                return ListTile(
                                  leading: (data['Image'] == 'Male' ||
                                          data['Image'] == 'Female')
                                      ? data['Image'] == 'Male'
                                          ? const CircleAvatar(
                                              radius: 15,
                                              backgroundImage:
                                                  AssetImage("assets/male.jpg"))
                                          : const CircleAvatar(
                                              radius: 15,
                                              backgroundImage: AssetImage(
                                                  "assets/female.jpg"))
                                      : ClipOval(
                                          child: CachedNetworkImage(
                                                  fit: BoxFit.cover,
                                                  imageUrl: data['Image'],
                                                  height: 30,
                                                  width: 30,
                                                  placeholder: (context, url) =>
                                                      const CircularProgressIndicator(),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.error),
                                                ),
                                        ),
                                  title: Text(
                                    '${data['Name']}',
                                    style: const TextStyle(
                                        fontStyle: FontStyle.italic),
                                  ),
                                );
                              }),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(18.0, 0.0, 8.0, 8.0),
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: ReadMoreText(
                                  list[index]['Comment'],
                                  trimLines: 3,
                                  trimMode: TrimMode.Line,
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Theme.of(context).iconTheme.color),
                                )),
                          ),
                          const Divider()
                        ],
                      );
                    },
                    itemCount: list.length,
                  );
                }),
          ),
          const Divider(),
          ListTile(
            title: TextFormField(
              controller: _textEditingController,
              decoration: const InputDecoration(
                labelText: 'Comment',
                // labelStyle: mystyle(20, Colors.black, FontWeight.w700),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
              ),
            ),
            trailing: IconButton(
              onPressed: () => _addcomment(),
              //borderSide: BorderSide.none,
              icon: const Icon(
                Icons.send,

                ///"Publish",
                //style: mystyle(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
