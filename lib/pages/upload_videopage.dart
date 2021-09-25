import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import '../providers/camera_funtions.dart';
import 'package:video_player/video_player.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class UploadPage extends StatefulWidget {
  final File file;
  const UploadPage(this.file, {Key? key}) : super(key: key);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  bool uploading = false;
  File? finalFile;
  File? thumbnailFile;
  VideoPlayerController? _controller;
  TextEditingController urlController = TextEditingController();
  void postImage() {
    setState(() {
      uploading = true;
    });
    uploadVideo(finalFile).then((String data) {
      uploadImage(thumbnailFile).then((String data2) {
        postToFireStore(
          mediaUrl: data,
          url: urlController.text,
          thumbnail: data2,
        );
      });
    }).then((_) {
      setState(() {
        uploading = false;
      });
      Fluttertoast.showToast(
          msg: 'Upload Successful',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white);
      Navigator.of(context).pop();
    });
  }

  Future<void> init() async {
    finalFile = await CameraFuctions(widget.file).compressFunction();
    _controller = VideoPlayerController.file(finalFile!);
    await _controller!.initialize();
    await _controller!.setLooping(true).then((value) {
      setState(() {});
    });
    await _controller!.play();
    final uint8list = await VideoThumbnail.thumbnailFile(
      video: widget.file.path,
      imageFormat: ImageFormat.JPEG,
      quality: 50,
    );
    thumbnailFile = File(uint8list!);
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: const Text(
          'Post Video',
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          TextButton(
              onPressed: uploading ? null : postImage,
              child: Text(
                "Post",
                style: TextStyle(
                    color: uploading ? Colors.grey : Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0),
              ))
        ],
      ),
      body: (_controller != null && _controller!.value.isInitialized)
          ? ListView(
              children: <Widget>[
                PostForm(
                  controller: _controller,
                  urlController: urlController,
                  loading: uploading,
                ),
                const Divider(),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

class PostForm extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final VideoPlayerController? controller;
  final TextEditingController urlController;
  final bool loading;
  const PostForm({
    Key? key,
    required this.controller,
    required this.urlController,
    required this.loading,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        loading
            ? const LinearProgressIndicator()
            : const Padding(padding: EdgeInsets.only(top: 0.0)),
        SingleChildScrollView(
          child: Column(
            children: [
              if (controller!.value.isInitialized)
                AspectRatio(
                  aspectRatio: controller!.value.aspectRatio,
                  child: VideoPlayer(controller!),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: TextField(
                    enabled: loading ? false : true,
                    controller: urlController,
                    decoration: const InputDecoration(
                        hintText: "Enter Product Url",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<String> uploadVideo(var imageFile) async {
  var uuid = const Uuid().v1();
  Reference ref = FirebaseStorage.instance.ref().child("Videos/$uuid.mp4");
  UploadTask uploadTask = ref.putFile(imageFile);
  String downloadUrl = await (await uploadTask).ref.getDownloadURL();
  return downloadUrl;
}

Future<String> uploadImage(var thumnailfile) async {
  var uuid = const Uuid().v1();
  Reference ref2 = FirebaseStorage.instance.ref().child("Images/$uuid.jpeg");
  UploadTask uploadTask2 = ref2.putFile(thumnailfile);
  String downloadUrl = await (await uploadTask2).ref.getDownloadURL();
  return downloadUrl;
}

void postToFireStore({String? mediaUrl, String? url, String? thumbnail}) async {
  var user = FirebaseAuth.instance.currentUser!.uid;
  var reference = FirebaseFirestore.instance.collection('VideosData');
  var reference2 = FirebaseFirestore.instance.collection('UsersData').doc(user);
  await reference.add({
    "Approved": true,
    "Likes": [],
    "Thumbnail": thumbnail,
    "url": mediaUrl,
    "price": "56",
    "timestamp": DateTime.now(),
    "p1name": "Hirdesh",
    "product1":
        "https://firebasestorage.googleapis.com/v0/b/okno-1ae24.appspot.com/o/Images%2F11.jpg?alt=media&token=df378ac6-21ba-4622-818f-9636ec9f6b45",
    "product2": "",
    "seller": "Myself",
    "store": url,
  }).then((DocumentReference doc) {
    String docId = doc.id;
    var obj2 = [docId];
    reference.doc(docId).update({"id": docId});
    reference2.update({'MyVideos': FieldValue.arrayUnion(obj2)});
  });
}
