import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oknoapp/pages/encashed_page.dart';
import 'video_page.dart';
import 'package:oknoapp/pages/tab_viewprofile.dart';

class CreatorPage extends StatefulWidget {
  static const routeName = '/creator_page';
  const CreatorPage({Key? key}) : super(key: key);

  @override
  _CreatorPageState createState() => _CreatorPageState();
}

class _CreatorPageState extends State<CreatorPage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!.uid;
    final _firebase =
        FirebaseFirestore.instance.collection("UsersData").doc(user);
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
          future: _firebase.get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            dynamic data = snapshot.data;
            return ListView(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              children: [
                Column(
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: data['Image'],
                              height: 100.0,
                              width: 100.0,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 25,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 30,
                            ),
                            Text("Encashed ${data['Encashed'] ?? '0.0'}"),
                            const SizedBox(
                              height: 5,
                            ),
                            Text("Balance ${data['Balance'] ?? '0.0'}"),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                                "Total Income ${data['Total Income'] ?? '0.0'}"),
                            const SizedBox(
                              height: 5,
                            ),
                            if (data['Creator'] == true)
                              OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pushNamed(EncashedPage.routeName);
                                  },
                                  child: const Text('Encash'))
                          ],
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (data['Creator'] == true)
                          IconButton(
                            icon: Container(
                                width: MediaQuery.of(context).size.width * 0.1,
                                height: MediaQuery.of(context).size.width * 0.1,
                                decoration: BoxDecoration(
                                    //  border: Border.all(color: Colors.white12)
                                    ),
                                child: const Center(
                                    child: Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 20,
                                  //   color: Colors.white,
                                ))),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const VideoRecorder()),
                              );
                            },
                          )
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    if (data['Creator'] == false)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Terms and Conditions'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      //color: Colors.white24
                                                      )),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.25,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: ListView.builder(
                                                  itemBuilder: (ctx, index) {
                                                    return Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                            'Terms And Conditions $index'),
                                                        const SizedBox(
                                                          height: 5,
                                                        )
                                                      ],
                                                    );
                                                  },
                                                  itemCount: 10,
                                                ),
                                              )),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                  child: const Text('Accept'),
                                                  onPressed: () {
                                                    _firebase.update({
                                                      'Creator': true
                                                    }).whenComplete(() {
                                                      setState(() {});
                                                    });

                                                    Navigator.of(context).pop();
                                                  }),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                            },
                            child: const Center(
                              child: Text(
                                "Become a Creator",
                                style: TextStyle(
                                    // color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                if (data['Creator'] == true) const TabBarControllerWidget(),
              ],
            );
          }),
    );
  }
}
