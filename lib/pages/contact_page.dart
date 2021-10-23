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
                  TextButton(
                      onPressed: () => showLicensePage(
                          context: context,
                          applicationName: 'Okno',
                          applicationIcon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              'assets/OknoIcon.png',
                              width: MediaQuery.of(context).size.width * 0.2,
                              height: MediaQuery.of(context).size.width * 0.2,
                            ),
                          ),
                          applicationVersion: '1.2.0',
                          applicationLegalese:
                              'Your Relationship With Us \n Welcome to TikTok (the “Platform”), which is provided by TikTok Inc. in the United States (collectively such entities will be referred to as “TikTok”, “we” or “us”).\nYou are reading the terms of service (the “Terms”), which govern the relationship and serve as an agreement between you and us and set forth the terms and conditions by which you may access and use the Platform and our related websites, services, applications, products and content (collectively, the “Services”). Access to certain Services or features of the Services (such as, by way of example and not limitation, the ability to submit or share User Content (defined below)) may be subject to age restrictions and not available to all users of the Services. Our Services are provided for private, non-commercial use. For purposes of these Terms, “you” and “your” means you as the user of the Services.\nThe Terms form a legally binding agreement between you and us. Please take the time to read them carefully. If you are under age 18, you may only use the Services with the consent of your parent or legal guardian. Please be sure your parent or legal guardian has reviewed and discussed these Terms with you.\nARBITRATION NOTICE FOR USERS IN THE UNITED STATES: THESE TERMS CONTAIN AN ARBITRATION CLAUSE AND A WAIVER OF RIGHTS TO BRING A CLASS ACTION AGAINST US. EXCEPT FOR CERTAIN TYPES OF DISPUTES MENTIONED IN THAT ARBITRATION CLAUSE, YOU AND TIKTOK AGREE THAT DISPUTES BETWEEN US WILL BE RESOLVED BY MANDATORY BINDING ARBITRATION, AND YOU AND TIKTOK WAIVE ANY RIGHT TO PARTICIPATE IN A CLASS-ACTION LAWSUIT OR CLASS-WIDE ARBITRATION.'),
                      child: const Text('LICENSES'))
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
