import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfile extends StatefulWidget {
  static const routeName = '/edit_profile';

  const EditProfile({Key? key}) : super(key: key);
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool _isUploading = false;
  final firebaseAuth = FirebaseAuth.instance;
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _textEditingController2 = TextEditingController();
  final TextEditingController _textEditingController3 = TextEditingController();
  @override
  void dispose() {
    _textEditingController.dispose();
    _textEditingController2.dispose();
    super.dispose();
  }

  var user = FirebaseAuth.instance.currentUser!.uid;

  _updateDis() async {
    setState(() {
      _isUploading = true;
    });
    String _password = _textEditingController3.text;
    String _email = _textEditingController2.text;
    String _name = _textEditingController.text;
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
    Fluttertoast.showToast(
        msg: "Profile Updated Success. Please Close the tab",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        fontSize: 16.0);
    setState(() {
      _isUploading = false;
      _textEditingController3.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Stack(
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
                return Container(
                  margin: MediaQuery.of(context).padding,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                            : () {
                                _updateDis();
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
                  ),
                );
              }),
          if (_isUploading)
            const Align(
              alignment: Alignment.center,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
