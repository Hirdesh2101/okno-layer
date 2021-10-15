import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../firebase functions/sidebar_fun.dart';

class EncashedPage extends StatefulWidget {
  static const routeName = "/encashed_page";
  const EncashedPage({Key? key}) : super(key: key);

  @override
  _EncashedPageState createState() => _EncashedPageState();
}

class _EncashedPageState extends State<EncashedPage> {
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _textEditingController2 = TextEditingController();
  final SideBarFirebase sideBarFirebase = SideBarFirebase();

  @override
  void dispose() {
    FocusScope.of(context).unfocus();
    _textEditingController.dispose();
    _textEditingController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser!.uid;
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Encash'),
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
                return SingleChildScrollView(
                  child: Container(
                    margin: MediaQuery.of(context).padding,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                'Encashed Amount available: ${data['Balance']}')),
                        const SizedBox(
                          height: 15,
                        ),
                        if (data['Balance'] < 100)
                          const Text(
                              'Mininimum Amount That Can Be Encashed: Rs.100'),
                        const SizedBox(
                          height: 15,
                        ),
                        if (data['Balance'] >= 100)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      TextField(
                                        decoration: const InputDecoration(
                                            hintText: 'Paytm Phone Number',
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)))),
                                        controller: _textEditingController,
                                        keyboardType: TextInputType.number,
                                      ),
                                      TextField(
                                        decoration: const InputDecoration(
                                            hintText: 'Confirm Phone Number',
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)))),
                                        controller: _textEditingController2,
                                        keyboardType: TextInputType.number,
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton(
                                          onPressed: () async {
                                            if (_textEditingController.text
                                                        .trim() ==
                                                    _textEditingController2.text
                                                        .trim() &&
                                                _textEditingController
                                                        .text.length ==
                                                    10 &&
                                                _textEditingController2
                                                        .text.length ==
                                                    10) {
                                              FocusScope.of(context).unfocus();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                content: Text(
                                                  'Please Wait',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                backgroundColor: Colors.grey,
                                              ));
                                              await sideBarFirebase
                                                  .encashedSub(
                                                      _textEditingController
                                                          .text
                                                          .trim())
                                                  .then((value) {
                                                _textEditingController.clear();

                                                _textEditingController2.clear();
                                                return AwesomeDialog(
                                                        context: _scaffoldKey
                                                            .currentContext!,
                                                        dialogType:
                                                            DialogType.SUCCES,
                                                        animType: AnimType
                                                            .BOTTOMSLIDE,
                                                        title: 'Thank You',
                                                        desc:
                                                            'Your amount will be credited in 3 working days',
                                                        btnOkOnPress: () {})
                                                    .show()
                                                    .whenComplete(() {
                                                  Navigator.of(context).pop();
                                                });
                                              });
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                content: const Text(
                                                  'Please Check Your Phone Number!!!',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .errorColor,
                                              ));
                                            }
                                          },
                                          child: const Text('Submit')),
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                      ],
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }
}
