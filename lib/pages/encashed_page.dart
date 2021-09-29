import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EncashedPage extends StatefulWidget {
  static const routeName = "/encashed_page";
  const EncashedPage({Key? key}) : super(key: key);

  @override
  _EncashedPageState createState() => _EncashedPageState();
}

class _EncashedPageState extends State<EncashedPage> {
  final TextEditingController _textEditingController = TextEditingController();
  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
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
                          child: Text(
                              'Encashed Amount available: ${data['Balance']}')),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                          'Mininimum Amount That Can Be Encashed: Rs.100'),
                      const SizedBox(
                        height: 15,
                      ),
                      if (data['Balance'] > 100)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)))),
                                  controller: _textEditingController,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                        onPressed: () {},
                                        child: const Text(
                                            'Add Money To Your Account')),
                                  )
                                ],
                              )
                            ],
                          ),
                        )
                    ],
                  ),
                );
              }),
        ],
      ),
    );
  }
}
