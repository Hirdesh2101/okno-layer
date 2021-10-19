import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oknoapp/pages/brand/brands_page.dart';
import 'package:oknoapp/pages/encashed_page.dart';
import './webview.dart';
import 'video_page.dart';
import 'package:oknoapp/pages/tab_viewprofile.dart';
import 'package:ionicons/ionicons.dart';

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
                          child: (data['Image'] == 'Male' ||
                                  data['Image'] == 'Female')
                              ? data['Image'] == 'Male'
                                  ? const CircleAvatar(
                                      radius: 50,
                                      backgroundImage:
                                          AssetImage("assets/male.jpg"))
                                  : const CircleAvatar(
                                      radius: 50,
                                      backgroundImage:
                                          AssetImage("assets/female.jpg"))
                              : ClipOval(
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
                                        .pushNamed(EncashedPage.routeName)
                                        .whenComplete(() {
                                      setState(() {});
                                    });
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
                          Row(
                            children: [
                              IconButton(
                                icon: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.1,
                                    height:
                                        MediaQuery.of(context).size.width * 0.1,
                                    decoration: const BoxDecoration(
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
                              ),
                              IconButton(
                                icon: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.1,
                                    height:
                                        MediaQuery.of(context).size.width * 0.1,
                                    decoration: const BoxDecoration(
                                        //  border: Border.all(color: Colors.white12)
                                        ),
                                    child: const Center(
                                        child: Icon(
                                      Ionicons.storefront,
                                      size: 20,
                                      //   color: Colors.white,
                                    ))),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const BrandPage()),
                                  );
                                },
                              )
                            ],
                          ),
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
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (cotext) {
                                return const WebViewPage(
                                    title: 'Terms and Conditions',
                                    url: 'https://www.oknoapp.com/');
                              })).whenComplete(() {
                                setState(() {});
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
                if (data['Creator'] == true) const TabBarControllerWidget(true),
              ],
            );
          }),
    );
  }
}
