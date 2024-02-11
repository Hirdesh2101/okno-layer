import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart' show rootBundle;

class GoogleDetails extends StatefulWidget {
  final GoogleSignInAccount googleuser;
  const GoogleDetails(this.googleuser, {Key? key}) : super(key: key);

  @override
  _GoogleDetailsState createState() => _GoogleDetailsState();
}

class _GoogleDetailsState extends State<GoogleDetails> {
  final _formKey = GlobalKey<FormState>();
  var _checked = false;
  int _showing = 0;
  var _age = '';
  bool _isLoading = false;
  int _radioValue = 0;
  String _gender = '';
  void _handelRadioValueChange(int? value) {
    setState(() {
      _radioValue = value!;
    });
    switch (_radioValue) {
      case 1:
        _gender = 'Male';
        break;
      case 2:
        _gender = 'Female';
        break;
    }
  }

  void _trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (_showing == 0) {
      Fluttertoast.showToast(
          msg: "Please Select Age",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          // backgroundColor: Colors.red,
          // textColor: Colors.white,
          fontSize: 16.0);
    }
    if (_checked == false) {
      Fluttertoast.showToast(
          msg: "Please accept terms and conditions.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          // backgroundColor: Colors.red,
          // textColor: Colors.white,
          fontSize: 16.0);
    }
    if (_gender == '') {
      Fluttertoast.showToast(
          msg: "Please Select Gender",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          // backgroundColor: Colors.red,
          // textColor: Colors.white,
          fontSize: 16.0);
    }

    if (isValid && _gender != '' && _showing != 0 && _checked) {
      _formKey.currentState!.save();
      switch (_showing) {
        case 1:
          _age = '0-10';
          break;
        case 2:
          _age = '10-20';
          break;
        case 3:
          _age = '20-25';
          break;
        case 4:
          _age = '25-30';
          break;
        case 5:
          _age = '30-35';
          break;
        case 6:
          _age = '35-45';
          break;
        case 7:
          _age = '45+';
          break;
      }
      setState(() {
        _isLoading = true;
      });
      // widget.submitFn(_userEmail.trim(), _userPassword.trim(), _userName.trim(),
      //     _gender.trim(), _age.trim(), context);
      try {
        final user = FirebaseAuth.instance.currentUser;
        var check = false;
        await FirebaseFirestore.instance
            .collection('UsersData')
            .doc(user!.uid)
            .get()
            .then((value) {
          if (value.exists) {
            check = true;
          }
        });
        if (!check) {
          await FirebaseFirestore.instance
              .collection('UsersData')
              .doc(user.uid)
              .set({
            'Name': widget.googleuser.displayName,
            'Gender': _gender,
            'Email': widget.googleuser.email,
            'Age': _age,
            'Creator': false,
            'Likes': [],
            'MyVideos': [],
            'Total Income': 0.0,
            'Balance': 0.0,
            'Encashed': 0.0,
            'WatchedVideo': [],
            'Saved': [],
            'topic': 'viewer',
            'Image': widget.googleuser.photoUrl,
            'BrandEnabled': false,
            'BrandAssociated': [],
          }).whenComplete(() => Navigator.of(context).pop());
        }
      } catch (err) {
        var message = 'Try Again Later';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/legal.txt');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provide Details'),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          elevation: 10,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: [
                        const Text('Select Age: '),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.14,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.40,
                          height: MediaQuery.of(context).size.height * 0.07,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  // color: Colors.white,
                                  ),
                              borderRadius: BorderRadius.circular(0)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                isExpanded: true,
                                hint: const Text('Select Age'),
                                value: _showing,
                                items: const [
                                  DropdownMenuItem(
                                    child: Text('Select Age'),
                                    value: 0,
                                  ),
                                  DropdownMenuItem(
                                    child: Text('0-10'),
                                    value: 1,
                                  ),
                                  DropdownMenuItem(
                                    child: Text('10-20'),
                                    value: 2,
                                  ),
                                  DropdownMenuItem(
                                    child: Text('20-25'),
                                    value: 3,
                                  ),
                                  DropdownMenuItem(
                                    child: Text('25-30'),
                                    value: 4,
                                  ),
                                  DropdownMenuItem(
                                    child: Text('30-35'),
                                    value: 5,
                                  ),
                                  DropdownMenuItem(
                                    child: Text('35-45'),
                                    value: 6,
                                  ),
                                  DropdownMenuItem(
                                    child: Text('45+'),
                                    value: 7,
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _showing = value as int;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Gender: '),
                        // ignore: unnecessary_new
                        new Radio(
                          value: 1,
                          groupValue: _radioValue,
                          onChanged: _handelRadioValueChange,
                        ),
                        const Text('Male'),
                        // ignore: unnecessary_new
                        new Radio(
                          value: 2,
                          groupValue: _radioValue,
                          onChanged: _handelRadioValueChange,
                        ),
                        const Text('Female'),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Checkbox(
                            value: _checked,
                            onChanged: (newValue) {
                              setState(() {
                                _checked = newValue!;
                              });
                            }),
                        TextButton(
                            onPressed: () {
                              loadAsset().then((value) {
                                showLicensePage(
                                    context: context,
                                    applicationName: 'Okno',
                                    applicationIcon: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.asset(
                                        'assets/OknoIcon.png',
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                      ),
                                    ),
                                    applicationVersion: '1.2.0',
                                    applicationLegalese: value);
                              });

                              //'Your Relationship With Us \n Welcome to TikTok (the “Platform”), which is provided by TikTok Inc. in the United States (collectively such entities will be referred to as “TikTok”, “we” or “us”).\nYou are reading the terms of service (the “Terms”), which govern the relationship and serve as an agreement between you and us and set forth the terms and conditions by which you may access and use the Platform and our related websites, services, applications, products and content (collectively, the “Services”). Access to certain Services or features of the Services (such as, by way of example and not limitation, the ability to submit or share User Content (defined below)) may be subject to age restrictions and not available to all users of the Services. Our Services are provided for private, non-commercial use. For purposes of these Terms, “you” and “your” means you as the user of the Services.\nThe Terms form a legally binding agreement between you and us. Please take the time to read them carefully. If you are under age 18, you may only use the Services with the consent of your parent or legal guardian. Please be sure your parent or legal guardian has reviewed and discussed these Terms with you.\nARBITRATION NOTICE FOR USERS IN THE UNITED STATES: THESE TERMS CONTAIN AN ARBITRATION CLAUSE AND A WAIVER OF RIGHTS TO BRING A CLASS ACTION AGAINST US. EXCEPT FOR CERTAIN TYPES OF DISPUTES MENTIONED IN THAT ARBITRATION CLAUSE, YOU AND TIKTOK AGREE THAT DISPUTES BETWEEN US WILL BE RESOLVED BY MANDATORY BINDING ARBITRATION, AND YOU AND TIKTOK WAIVE ANY RIGHT TO PARTICIPATE IN A CLASS-ACTION LAWSUIT OR CLASS-WIDE ARBITRATION.');
                            },
                            child: Text(
                              'Please accept the terms and conditions.',
                              style: TextStyle(
                                  color: Theme.of(context).iconTheme.color),
                            ))
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_isLoading) const CircularProgressIndicator(),
                    if (!_isLoading)
                      Container(
                        width: MediaQuery.of(context).size.width * 0.58,
                        height: MediaQuery.of(context).size.height * 0.07,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          // gradient: const LinearGradient(colors: [
                          //   Color.fromARGB(255, 52, 63, 95),
                          //   Color.fromARGB(200, 32, 29, 48)
                          // ])
                        ),
                        child: ElevatedButton(
                          //shape: RoundedRectangleBorder(
                          // borderRadius: BorderRadius.circular(20)),
                          style: ElevatedButton.styleFrom(),
                          child: const Text(
                            'SUBMIT',
                            style: TextStyle(
                                // color: Colors.white,
                                ),
                          ),
                          onPressed: _trySubmit,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
