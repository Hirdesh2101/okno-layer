import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:video_player/video_player.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:filter_list/filter_list.dart';

class UploadPage extends StatefulWidget {
  final File file;
  final String path;
  const UploadPage(this.file, this.path, {Key? key}) : super(key: key);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  bool uploading = false;
  File? finalFile;
  //String? finalPath;
  File? thumbnailFile;
  List<String> selectedCountList = [];
  VideoPlayerController? _controller;
  TextEditingController urlController = TextEditingController();
  void postImage() {
    if (urlController.text.trim() == '' || selectedCountList.isEmpty) {
      if (urlController.text.trim() == '') {
        Fluttertoast.showToast(
            msg: "Please Enter Url",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            // backgroundColor: Colors.red,
            // textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: "Please Select Tags",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            // backgroundColor: Colors.red,
            // textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
      setState(() {
        uploading = true;
      });
      uploadVideo(finalFile).then((String data) {
        uploadImage(thumbnailFile).then((String data2) {
          postToFireStore(
            mediaUrl: data,
            url: urlController.text,
            thumbnail: data2,
            tags: selectedCountList,
          ).then((value) {
            finalFile!.delete();
            thumbnailFile!.delete();
          });
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
  }

  Future<void> init() async {
    // await CameraFuctions(widget.file).reduceSizeAndType(widget.path);
    //finalFile = await CameraFuctions(widget.file).compressFunction();
    //finalFile = File(finalPath!);
    finalFile = widget.file;
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

  void _submitTags(List<String> tags) {
    setState(() {
      selectedCountList = tags;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Colors.white70,
        title: const Text(
          'Post Video',
          //style: TextStyle(color: Colors.black),
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
                  tagsList: selectedCountList,
                  submitTags: _submitTags,
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
  final VideoPlayerController? controller;
  final TextEditingController urlController;
  final List<String> tagsList;
  final bool loading;
  final Function(List<String>) submitTags;
  PostForm({
    Key? key,
    required this.controller,
    required this.urlController,
    required this.loading,
    required this.tagsList,
    required this.submitTags,
  }) : super(key: key);

  _submitFunction(List<String> finalTags) {
    submitTags(finalTags);
  }

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
                GestureDetector(
                  onTap: () {
                    if (controller!.value.isPlaying) {
                      controller?.pause();
                    } else {
                      controller?.play();
                    }
                  },
                  child: AspectRatio(
                    aspectRatio: controller!.value.aspectRatio,
                    child: VideoPlayer(controller!),
                  ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () {
                        showReportDialog1(context);
                      },
                      child: const Text('Select Tags')),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  final List<String> countList = [
    "Ethenics",
    "Western",
    "Festive",
    "Casuals",
  ];

  void showReportDialog1(BuildContext context) async {
    await FilterListDialog.display<String>(context,
        listData: countList,
        selectedListData: tagsList,
        searchFieldTextStyle: const TextStyle(color: Colors.black),
        controlButtonTextStyle: const TextStyle(color: Colors.blue),
        height: MediaQuery.of(context).size.height * 0.6,
        controlContainerDecoration: const BoxDecoration(color: Colors.white),
        headlineText: "Select Filters",
        applyButtonTextStyle: const TextStyle(color: Colors.white),
        selectedItemsText: 'Filters Selected',
        searchFieldHintText: "Search Here", choiceChipLabel: (item) {
      return item;
    }, validateSelectedItem: (list, val) {
      return list!.contains(val);
    }, onItemSearch: (list, text) {
      if (list!.any(
          (element) => element.toLowerCase().contains(text.toLowerCase()))) {
        return list
            .where(
                (element) => element.toLowerCase().contains(text.toLowerCase()))
            .toList();
      } else {
        return [];
      }
    }, onApplyButtonClick: (list) {
      if (list != null) {
        _submitFunction(list);
      }
      Navigator.pop(context);
    });
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

Future<void> postToFireStore(
    {String? mediaUrl, String? url, String? thumbnail, List? tags}) async {
  var user = FirebaseAuth.instance.currentUser!.uid;
  var timestamp = DateTime.now().toString();
  var reference =
      FirebaseFirestore.instance.collection('VideosData').doc(timestamp);
  var reference2 = FirebaseFirestore.instance.collection('UsersData').doc(user);
  await reference.set({
    "Approved": false,
    "Likes": [],
    "Thumbnail": thumbnail,
    "id": timestamp,
    "url": mediaUrl,
    "price": "56",
    "tags": tags,
    "timestamp": DateTime.now(),
    "p1name": "Hirdesh",
    "product1":
        "https://firebasestorage.googleapis.com/v0/b/okno-1ae24.appspot.com/o/Images%2F11.jpg?alt=media&token=df378ac6-21ba-4622-818f-9636ec9f6b45",
    "product2": "",
    "seller": "Myself",
    "store": url,
    "value": '',
    "userupload": true,
    "storeupload": false,
    "uploadedby": user,
    "Comments": [],
  }).then((val) {
    var obj2 = [timestamp];
    reference2.update({'MyVideos': FieldValue.arrayUnion(obj2)});
  });
}
