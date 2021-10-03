import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readmore/readmore.dart';
import '../services/cache_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Comments extends StatefulWidget {
  final String id;
  const Comments(this.id, {Key? key}) : super(key: key);
  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  final TextEditingController _textEditingController = TextEditingController();
  bool _isUploading = false;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _addcomment() async {
      if (_textEditingController.text.trim() != '') {
        setState(() {
          _isUploading = true;
        });
        final user = FirebaseAuth.instance.currentUser;
        var obj = [
          {'Comment': _textEditingController.text.trim(), 'uid': user!.uid}
        ];
        await FirebaseFirestore.instance
            .collection('VideosData')
            .doc(widget.id.trim())
            .update({'Comments': FieldValue.arrayUnion(obj)});
        _textEditingController.clear();
        setState(() {
          _isUploading = false;
        });
      } else {
        Fluttertoast.showToast(
            msg: "Enter a valid Comment",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Comments",
          style: TextStyle(color: Colors.grey),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('VideosData')
                  .where('id', isEqualTo: widget.id.trim())
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
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
                return Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (_, int index) {
                      return Column(
                        children: [
                          FutureBuilder(
                              future: FirebaseFirestore.instance
                                  .collection('UsersData')
                                  .doc(list[index]['uid'])
                                  .get(),
                              builder: (context, snapshot) {
                                dynamic data = snapshot.data;
                                if (!snapshot.hasData) {
                                  return const ListTile(
                                    leading: CircleAvatar(
                                      radius: 15,
                                      backgroundColor: Colors.black26,
                                    ),
                                    title: Text('Loading...'),
                                  );
                                }
                                return ListTile(
                                  leading: ClipOval(
                                    child: CircleAvatar(
                                      radius: 15,
                                      child: CachedNetworkImage(
                                        imageUrl: data['Image'],
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                        cacheManager:
                                            CustomCacheManager.instance2,
                                      ),
                                    ),
                                  ),
                                  title: Text('${data['Name']}'),
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
                                )),
                          ),
                          const Divider()
                        ],
                      );
                    },
                    itemCount: list.length,
                  ),
                );
              }),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.78,
                    child: TextField(
                      enabled: _isUploading ? false : true,
                      decoration: const InputDecoration(
                          hintText: "Enter Comment",
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                      controller: _textEditingController,
                      maxLines: null,
                      minLines: null,
                      autocorrect: false,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                ),
                _isUploading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.17,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(13),
                            ),
                            onPressed: _isUploading ? null : _addcomment,
                            child: const Icon(Icons.send),
                          ),
                        ),
                      )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
