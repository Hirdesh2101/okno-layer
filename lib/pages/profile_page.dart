import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oknoapp/pages/edit_profile.dart';
import 'video_page.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile_page';
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!.uid;
    final _firebase =
        FirebaseFirestore.instance.collection("UsersData").doc(user);
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text('My Profile'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: FutureBuilder(
                future: _firebase.get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  dynamic data = snapshot.data;
                  return Column(
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipOval(
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
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "${data['Name']}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "${data['Email']}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            style: ButtonStyle(),
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(EditProfile.routeName);
                            },
                            child: const Center(
                              child: Text(
                                "Edit profile",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          if (data['Creator'] == true)
                            IconButton(
                              icon: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
                                  height:
                                      MediaQuery.of(context).size.width * 0.1,
                                  decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Colors.white12)),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            style: ButtonStyle(),
                            onPressed: () {
                              data['Creator'] == false
                                  ? _firebase.update(
                                      {'Creator': true}).whenComplete(() {
                                      setState(() {});
                                    })
                                  : _firebase.update(
                                      {'Creator': false}).whenComplete(() {
                                      setState(() {});
                                    });
                            },
                            child: Center(
                              child: Text(
                                data['Creator'] == false
                                    ? "Become a Creator"
                                    : "Unregistor as a creator",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (data['Creator'] == true)
                        Container(
                          height: 45,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white12)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Icon(Icons.menu),
                                  const SizedBox(
                                    height: 7,
                                  ),
                                  const SizedBox(
                                    height: 7,
                                  ),
                                  Container(
                                    color: Colors.white,
                                    height: 2,
                                    width: 55,
                                  )
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Icon(
                                    Icons.favorite_border,
                                    color: Colors.white24,
                                  ),
                                  const SizedBox(
                                    height: 7,
                                  ),
                                  Container(
                                    color: Colors.transparent,
                                    height: 2,
                                    width: 55,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                }),
          ),
        ));
  }
}
