import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl:
                                  "https://q5n8c8q9.rocketcdn.me/wp-content/uploads/2018/08/The-20-Best-Royalty-Free-Music-Sites-in-2018.png",
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
                          width: 50,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("My VIEWS"),
                            SizedBox(
                              height: 5,
                            ),
                            Text("My income"),
                            SizedBox(
                              height: 5,
                            ),
                            Text("My followers"),
                            SizedBox(
                              height: 5,
                            )
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
                                    border: Border.all(color: Colors.white12)),
                                child: const Center(
                                    child: Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 20,
                                  color: Colors.white,
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
                              _firebase
                                  .update({'Creator': true}).whenComplete(() {
                                setState(() {});
                              });
                            },
                            child: const Center(
                              child: Text(
                                "Become a Creator",
                                style: TextStyle(
                                    color: Colors.white,
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
