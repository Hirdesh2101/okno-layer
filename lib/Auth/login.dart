import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'auth_form_login.dart';

class Loginscreen extends StatefulWidget {
  static const routeName = '/login_screen';

  const Loginscreen({Key? key}) : super(key: key);
  @override
  _LoginscreenState createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _formKey = GlobalKey<FormState>();

  void _signInWithGoogle(
    BuildContext ctx,
  ) async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential result = await _auth.signInWithCredential(credential);
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (FirebaseFirestore.instance
                  .collection('UsersData')
                  .doc(user!.uid)
                  .id ==
              "") {
            FirebaseFirestore.instance
                .collection('UsersData')
                .doc(user.uid)
                .set({
              'Name': googleUser.displayName,
              'Gender': "",
              'Email': googleUser.email,
              'Age': "",
              'Creator': false,
              'Likes': [],
              'MyVideos': [],
            });
          }
        } on PlatformException catch (err) {
          var message = 'An error occurred, pelase check your credentials!';

          if (err.message != null) {
            message = err.message!;
          }

          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Theme.of(ctx).errorColor,
            ),
          );
          setState(() {
            _isLoading = false;
          });
        } catch (err) {
          setState(() {
            _isLoading = false;
          });
        }
      } on PlatformException catch (err) {
        var message = 'An error occurred, pelase check your credentials!';

        if (err.message != null) {
          message = '${err.message}';
        }

        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(ctx).errorColor,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      } catch (err) {
        // ignore: avoid_print
        print(err);
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _signInWithFacebook(BuildContext ctx) {}
  // void _signInWithFacebook(
  //   BuildContext ctx,
  // ) async {
  //   // Trigger the authentication flow
  //   final result1 = await FacebookAuth.instance.login();
  //   if (result1 != null) {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     try {
  //       AuthCredential authCredential =
  //           FacebookAuthProvider.getCredential(accessToken: result1.token);
  //       await _auth.signInWithCredential(authCredential);
  //       Navigator.of(context).pop();
  //     } on PlatformException catch (err) {
  //       var message = 'An error occurred, pelase check your credentials!';

  //       if (err.message != null) {
  //         message = err.message;
  //       }

  //       Scaffold.of(ctx).showSnackBar(
  //         SnackBar(
  //           content: Text(message),
  //           backgroundColor: Theme.of(ctx).errorColor,
  //         ),
  //       );
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     } catch (err) {
  //       print(err);
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }

  void _submitAuthForm(
    String email,
    String password,
    String username,
    BuildContext ctx,
  ) async {
    UserCredential authResult;

    try {
      setState(() {
        _isLoading = true;
      });

      authResult = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on PlatformException catch (err) {
      var message = 'An error occurred, pelase check your credentials!';

      if (err.message != null) {
        message = '${err.message}';
      }
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          // textColor: Colors.white,
          fontSize: 16.0);
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      // ignore: avoid_print
      print(err);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _forgotPassword(BuildContext ctx) {
    String? _emailFor = '';
    bool inProgress = false;
    Future<void> resetPassword(String email) async {
      await _auth.sendPasswordResetEmail(email: email);
    }

    showDialog(
        context: ctx,
        builder: (context) {
          return AlertDialog(
            title: const Text('Enter Email ID'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: _formKey,
                  child: TextFormField(
                    enabled: !inProgress,
                    key: const ValueKey('Forgotemail'),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                    validator: (value) {
                      if (value!.isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email address.';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      _emailFor = value;
                      _emailFor!.trim();
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                        onPressed: () {
                          final isValid = _formKey.currentState!.validate();
                          FocusScope.of(context).unfocus();
                          if (isValid) {
                            resetPassword(_emailFor!);
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('Submit'))
                  ],
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthFormLogin(
        _submitAuthForm,
        _isLoading,
        _signInWithGoogle,
        _signInWithFacebook,
        _forgotPassword,
      ),
    );
  }
}
