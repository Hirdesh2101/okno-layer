import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;

class SetProfileImage extends StatefulWidget {
  static const routeName = '/addpicture';
  const SetProfileImage({Key? key}) : super(key: key);

  @override
  _SetProfileImageState createState() => _SetProfileImageState();
}

class _SetProfileImageState extends State<SetProfileImage> {
  File? _image;
  final picker = ImagePicker();
  bool _isUploading = false;
  String? url;

  Future getImage() async {
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxHeight: 400,
        maxWidth: 400);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        Fluttertoast.showToast(
            msg: "No Image Selected",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
      }
    });
  }

  var user = FirebaseAuth.instance.currentUser!.uid;
  Future<void> _uploadFile(File img) async {
    try {
      setState(() {
        _isUploading = true;
      });
      await firebase_storage.FirebaseStorage.instance
          .ref('profiles/$user')
          .putFile(img);
      String downloadURL = await firebase_storage.FirebaseStorage.instance
          .ref('profiles/$user')
          .getDownloadURL();
      url = downloadURL;
      await FirebaseFirestore.instance
          .collection('UsersData')
          .doc(user)
          .update({"Image": downloadURL});
      setState(() {
        _image = null;
      });
      Navigator.of(context).pop();
    } on firebase_core.FirebaseException {
      Fluttertoast.showToast(
          msg: "Error.. Please Try again later",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: MediaQuery.of(context).padding,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null
                ? const Text(
                    'Select A Profile Image',
                    style: TextStyle(fontSize: 20),
                  )
                : CircleAvatar(
                    radius: 85,
                    backgroundImage: FileImage(_image!),
                  ),
            const SizedBox(
              height: 10,
            ),
            IconButton(
              onPressed: _isUploading ? null : getImage,
              icon: const Icon(
                Icons.add_a_photo,
                size: 40,
              ),
            ),
            _image != null
                ? TextButton(
                    child: const Text('Add'),
                    onPressed: _isUploading
                        ? null
                        : () {
                            _uploadFile(_image!);
                          },
                  )
                : Container(),
            _isUploading
                ? const Center(child: CircularProgressIndicator())
                : Container(),
            TextButton(
              child: const Text('Skip'),
              onPressed:
                  _isUploading ? null : () => Navigator.of(context).pop(),
            )
          ],
        ),
      ),
    );
  }
}
