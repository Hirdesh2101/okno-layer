import 'dart:io';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:video_player/video_player.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:filter_list/filter_list.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:aws_common/vm.dart';
// import 'package:chewie/chewie.dart';
// import 'package:cdnbye/cdnbye.dart';

class UploadPage extends StatefulWidget {
  final File file;
  final String path;
  const UploadPage(this.file, this.path, {Key? key}) : super(key: key);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  bool uploading = false;
  late File finalFile;
  //String? finalPath;
  File? thumbnailFile;
  List<String> selectedCountList = [];
  VideoPlayerController? _controller;
  TextEditingController urlController = TextEditingController();
  final storage = AmplifyStorageS3();
  void postImage() async {

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
      await uploadVideo(finalFile).then((String data) async {
        await uploadImage(thumbnailFile).then((String data2) async {
          await postToFireStore(
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
    urlController.dispose();
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
                Column(
                  children: <Widget>[
                    uploading
                        ? const LinearProgressIndicator()
                        : const Padding(padding: EdgeInsets.only(top: 0.0)),
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          if (_controller!.value.isInitialized)
                            GestureDetector(
                              onTap: () {
                                if (_controller!.value.isPlaying) {
                                  _controller?.pause();
                                } else {
                                  _controller?.play();
                                }
                              },
                              child: AspectRatio(
                                aspectRatio: _controller!.value.aspectRatio,
                                child: VideoPlayer(_controller!),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: TextField(
                                enabled: uploading ? false : true,
                                controller: urlController,
                                decoration: const InputDecoration(
                                    hintText: "Enter Product Url",
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)))),
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
                ),
                const Divider(),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  void showReportDialog1(BuildContext context) async {
    await FilterListDialog.display<String>(context,
        listData: countList,
        selectedListData: selectedCountList,
        choiceChipLabel: (user) => user,
        //searchFieldTextStyle: const TextStyle(color: Colors.black),
        // controlButtonTextStyle: const TextStyle(color: Colors.blue),
        height: MediaQuery.of(context).size.height * 0.6,
        // controlContainerDecoration: const BoxDecoration(color: Colors.white),
        headlineText: "Select Filters",
        //applyButtonTextStyle: const TextStyle(color: Colors.white),
        selectedItemsText: 'Filters Selected',
        //  searchFieldHintText: "Search Here",

        validateSelectedItem: (list, val) {
          return list!.contains(val);
        },
        onItemSearch: (user, query) {
          return user.toLowerCase().contains(query.toLowerCase());
        },
        onApplyButtonClick: (list) {
          if (list != null) {
            _submitTags(list);
          }
          Navigator.pop(context);
        });
  }
}

final List<String> countList = [
  "Ethenics",
  "Western",
  "Festive",
  "Casuals",
];

Future<String> uploadVideo(File imageFile) async {
  final awsFile = AWSFilePlatform.fromFile(imageFile);
  var uuid = const Uuid().v1();
  const url = "https://d140p29c73x6ns.cloudfront.net/";
  late String uploadUrl;
  try {
    final uploadResult = await Amplify.Storage.uploadFile(
      localFile: awsFile,
      key: 'Videos/$uuid.mp4',
    ).result;
    uploadUrl = "$url$uuid/master.m3u8";
    safePrint('Uploaded file: ${uploadResult.uploadedItem.key}');
  } on StorageException catch (e) {
    safePrint('Error uploading file: ${e.message}');
    rethrow;
  }
  return uploadUrl;
}

Future<String> uploadImage(var thumnailfile) async {
  final awsFile = AWSFilePlatform.fromFile(thumnailfile);
  var uuid = const Uuid().v1();
  const url = "https://d36sxz5nwbaxr3.cloudfront.net/public/";
  final uploadUrl;
  try {
    final uploadResult = await Amplify.Storage.uploadFile(
      localFile: awsFile,
      key: 'Images/$uuid.jpeg',
    ).result;
    uploadUrl = "${url}Images/$uuid.jpeg";
    safePrint('Uploaded file: ${uploadResult.uploadedItem.key}');
  } on StorageException catch (e) {
    safePrint('Error uploading file: ${e.message}');
    rethrow;
  }
  return uploadUrl;
}

Future<void> postToFireStore(
    {String? mediaUrl, String? url, String? thumbnail, List? tags}) async {
  var user = FirebaseAuth.instance.currentUser!.uid;
  var timestamp = DateTime.now().toString();
  var reference =
      FirebaseFirestore.instance.collection('VideosData').doc(timestamp);
  var reference2 = FirebaseFirestore.instance.collection('UsersData').doc(user);
  await reference.set({
    "Approved": true,
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
    "deleted": false,
    "userupload": true,
    "storeupload": false,
    "uploadedby": user,
    "Comments": [],
  }).then((val) {
    var obj2 = [timestamp];
    reference2.update({'MyVideos': FieldValue.arrayUnion(obj2)});
  });
}
