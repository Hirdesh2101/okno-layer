import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import '../providers/camera_funtions.dart';
import 'package:video_player/video_player.dart';
import 'package:video_compress/video_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
    uploadImage(finalFile).then((String data) {
      postToFireStore(
        mediaUrl: data,
        url: urlController.text,
      );
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
              onPressed: postImage,
              child: const Text(
                "Post",
                style: TextStyle(
                    color: Colors.blueAccent,
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
        const Divider(),
        SingleChildScrollView(
          child: Column(
            children: [
              if (controller!.value.isInitialized)
                AspectRatio(
                  aspectRatio: controller!.value.aspectRatio,
                  child: VideoPlayer(controller!),
                ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                      hintText: "Enter Product Url", border: InputBorder.none),
                ),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}

Future<String> uploadImage(var imageFile) async {
  var uuid = const Uuid().v1();
  Reference ref = FirebaseStorage.instance.ref().child("video_$uuid.mp4");
  UploadTask uploadTask = ref.putFile(imageFile);

  String downloadUrl = await (await uploadTask).ref.getDownloadURL();
  return downloadUrl;
}

void postToFireStore({String? mediaUrl, String? url}) async {
  var reference = FirebaseFirestore.instance.collection('insta_posts');

  reference.add({
    "likes": {},
    "mediaUrl": mediaUrl,
    "url": url,
    "timestamp": DateTime.now(),
  }).then((DocumentReference doc) {
    String docId = doc.id;
    reference.doc(docId).update({"postId": docId});
  });
}
