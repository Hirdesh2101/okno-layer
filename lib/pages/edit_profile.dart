import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class EditProfile extends StatefulWidget {
  static const routeName = '/edit_profile';

  const EditProfile({Key? key}) : super(key: key);
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool _isUploading = false;
  File? _image;
  String? url;
  final _picker = ImagePicker();
  final firebaseAuth = FirebaseAuth.instance;
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _textEditingController2 = TextEditingController();
  final TextEditingController _textEditingController3 = TextEditingController();
  @override
  void dispose() {
    _textEditingController.dispose();
    _textEditingController2.dispose();
    _textEditingController3.dispose();
    super.dispose();
  }

  var user = FirebaseAuth.instance.currentUser!.uid;
  Future<void> _uploadFile(File img) async {
    try {
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

  Future<void> _updateDis() async {
    String _password = _textEditingController3.text;
    String _email = _textEditingController2.text;
    String _name = _textEditingController.text;
    String? previousMail;
    await FirebaseFirestore.instance
        .collection('UsersData')
        .doc(user)
        .get()
        .then((value) {
      previousMail = value.data()!['Email'];
    });
    if (previousMail != _email && _password == '') {
      Fluttertoast.showToast(
          msg: "Please enter the current password to change email!!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
    }
    if (_email != '' && _textEditingController3.text != "") {
      User? user = FirebaseAuth.instance.currentUser;
      UserCredential authResult = await user!.reauthenticateWithCredential(
        EmailAuthProvider.credential(
          email: user.email!,
          password: _password,
        ),
      );
      await authResult.user!.updateEmail(_email);
      await FirebaseFirestore.instance
          .collection('UsersData')
          .doc(user.uid)
          .update({'Email': _email});
    }
    if (_name != '') {
      await FirebaseFirestore.instance
          .collection('UsersData')
          .doc(user)
          .update({'Name': _name});
    }
  }

  _imgFromCamera() async {
    var image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    File imagesource = File(image!.path);
    setState(() {
      _image = imagesource;
    });
  }

  _imgFromGallery() async {
    var image = (await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 50));
    File imagesource = File(image!.path);
    setState(() {
      _image = imagesource;
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Gallery'),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    _imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('UsersData')
                    .doc(user)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  dynamic data = snapshot.data;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                            onTap: () => _showPicker(context),
                            child: _image != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(90),
                                    child: Image.file(
                                      _image!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.fitHeight,
                                    ),
                                  )
                                : (data['Image'] == 'Male' ||
                                        data['Image'] == 'Female')
                                    ? data['Image'] == 'Male'
                                        ? const CircleAvatar(
                                            radius: 90,
                                            backgroundImage:
                                                AssetImage("assets/male.jpg"))
                                        : const CircleAvatar(
                                            radius: 90,
                                            backgroundImage:
                                                AssetImage("assets/female.jpg"))
                                    : CircleAvatar(
                                        radius: 90,
                                        backgroundImage: NetworkImage(
                                          data['Image'],
                                        ),
                                      )),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          enabled: _isUploading ? false : true,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)))),
                          controller: _textEditingController
                            ..text = data['Name'],
                          maxLines: null,
                          minLines: null,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                      if (firebaseAuth
                              .currentUser!.providerData[0].providerId !=
                          'google.com')
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            enabled: _isUploading ? false : true,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)))),
                            controller: _textEditingController2
                              ..text = data['Email'],
                            maxLines: null,
                            minLines: null,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                      if (firebaseAuth
                              .currentUser!.providerData[0].providerId !=
                          'google.com')
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            enabled: _isUploading ? false : true,
                            decoration: const InputDecoration(
                                hintText: 'Enter Password',
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)))),
                            controller: _textEditingController3,
                            autocorrect: false,
                            obscureText: true,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                      ElevatedButton(
                        child: const Text('Update Profile'),
                        onPressed: _isUploading
                            ? null
                            : () async {
                                setState(() {
                                  _isUploading = true;
                                });
                                await _updateDis();
                                if (_image != null) {
                                  await _uploadFile(_image!);
                                }
                                Fluttertoast.showToast(
                                    msg: "Profile Updated Success.",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    fontSize: 16.0);
                                setState(() {
                                  _isUploading = false;
                                  _textEditingController3.clear();
                                });
                              },
                      ),
                      ElevatedButton(
                        onPressed: _isUploading
                            ? null
                            : () {
                                Navigator.of(context).pop();
                              },
                        child: const Text('Cancel'),
                      ),
                    ],
                  );
                }),
            if (_isUploading)
              const Align(
                alignment: Alignment.center,
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
