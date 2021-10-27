import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../firebase functions/sidebar_fun.dart';
import '../services/launch_url.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _textEditingController2 = TextEditingController();
  final TextEditingController _textEditingController3 = TextEditingController();
  final SideBarFirebase sideBarFirebase = SideBarFirebase();

  @override
  void dispose() {
    FocusScope.of(context).unfocus();
    _textEditingController.dispose();
    _textEditingController2.dispose();
    _textEditingController3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Know More About us on the offical website!!'),
                  TextButton(
                    onPressed: () {
                      launchURL(context, 'https://www.oknoapp.com/');
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'oknoapp.com',
                            style: TextStyle(fontSize: 16),
                          ),
                          Icon(
                            Ionicons.open_outline,
                            //color: Colors.blue,
                            size: 16,
                          )
                        ]),
                  ),
                ],
              ),
            ),
          ),
          Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          TextField(
                              decoration: const InputDecoration(
                                  hintText: 'Email Address',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10)))),
                              controller: _textEditingController,
                              keyboardType: TextInputType.emailAddress),
                          TextField(
                            decoration: const InputDecoration(
                                hintText: 'Phone Number',
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)))),
                            controller: _textEditingController2,
                            keyboardType: TextInputType.number,
                          ),
                          TextField(
                            decoration: const InputDecoration(
                                hintText: 'Company Name',
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)))),
                            controller: _textEditingController3,
                            keyboardType: TextInputType.name,
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
                                if (_textEditingController.text.isNotEmpty &&
                                    _textEditingController2.text.isNotEmpty &&
                                    _textEditingController3.text.isNotEmpty) {
                                  FocusScope.of(context).unfocus();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text(
                                      'Please Wait',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.grey,
                                  ));
                                  await sideBarFirebase
                                      .contactInfo(
                                          _textEditingController.text.trim(),
                                          _textEditingController2.text.trim(),
                                          _textEditingController3.text.trim())
                                      .then((value) {
                                    _textEditingController.clear();
                                    _textEditingController2.clear();
                                    _textEditingController3.clear();
                                    return ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text(
                                        'Thank You!! We Will Contact you soon..',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      backgroundColor: Colors.greenAccent,
                                    ));
                                  });
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: const Text(
                                      'Please fill all the fields !!!',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor:
                                        Theme.of(context).errorColor,
                                  ));
                                }
                              },
                              child: const Text('Submit')),
                        )
                      ],
                    )
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
