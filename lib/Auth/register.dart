import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oknoapp/pages/userimage_set.dart';
import './auth_form_register.dart';

class Register extends StatefulWidget {
  static const routeName = '/register_screen';

  const Register({Key? key}) : super(key: key);
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  void _submitAuthForm(
    String email,
    String password,
    String username,
    String gender,
    String age,
    BuildContext ctx,
  ) async {
    //UserCredential authResult;

    try {
      setState(() {
        _isLoading = true;
      });
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = FirebaseAuth.instance.currentUser;

      FirebaseFirestore.instance.collection('UsersData').doc(user!.uid).set({
        'Name': username,
        'Gender': gender,
        'Email': email,
        'Age': age,
        'Creator': false,
        'Likes': [],
        'MyVideos': [],
        'Total Income': 0.0,
        'Balance': 0.0,
        'Encashed': 0.0,
        'WatchedVideo': [],
        'Saved': [],
        'topic': 'viewer',
        'Image': gender,
        'BrandEnabled': false,
        'BrandAssociated': [],
      });
      Navigator.of(context).pushReplacementNamed(SetProfileImage.routeName);
    } on FirebaseAuthException catch (err) {
      var message = '${err.message}';
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.blue,
      body: AuthForm(
        _submitAuthForm,
        _isLoading,
      ),
    );
  }
}
