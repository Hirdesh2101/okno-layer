import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oknoapp/pages/change_theme.dart';
import 'package:oknoapp/pages/edit_profile.dart';
import 'package:oknoapp/pages/tab_viewprofile.dart';
import 'package:oknoapp/pages/webview.dart';
import '../services/service_locator.dart';
import 'video_page.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile_page';
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  int selectedIndex = 0;
  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    setupMyVideos();
    tabController = TabController(
      initialIndex: selectedIndex,
      length: 2,
      vsync: this,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!.uid;
    final _firebase =
        FirebaseFirestore.instance.collection("UsersData").doc(user);
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(itemBuilder: (BuildContext context) {
            return <PopupMenuEntry>[
              const PopupMenuItem(
                child: Text('Settings'),
                value: 1,
              ),
            ];
          }, onSelected: (value) async {
            if (value == 1) {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const ThemeScreen()));
            }
          })
        ],
      ),
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
                        (data['Image'] == 'Male' || data['Image'] == 'Female')
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
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "${data['Name']}",
                      style: const TextStyle(
                          // color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "${data['Email']}",
                      style: const TextStyle(
                          // color: Colors.white,
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
                          style: OutlinedButton.styleFrom(),
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(EditProfile.routeName);
                          },
                          child: const Center(
                            child: Text(
                              "Edit profile",
                              style: TextStyle(
                                  //   color: Colors.white,
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
                                width: MediaQuery.of(context).size.width * 0.1,
                                height: MediaQuery.of(context).size.width * 0.1,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        //color: Colors.white12

                                        )),
                                child: const Center(
                                    child: Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 20,
                                  //color: Colors.white,
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
                                    //color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                if (data['Creator'] == true)
                  const TabBarControllerWidget(false),
              ],
            );
          }),
    );
  }
}
