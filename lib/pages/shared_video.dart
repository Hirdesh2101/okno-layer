// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/feedviewprovider.dart';
// import 'package:video_player/video_player.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/video.dart';
// import 'package:ionicons/ionicons.dart';

// class SharedVideo extends StatefulWidget {
//   final String id;
//   static const routeName = '/SharedVideo';
//   const SharedVideo(this.id, {Key? key}) : super(key: key);

//   @override
//   _SharedVideoState createState() => _SharedVideoState();
// }

// class _SharedVideoState extends State<SharedVideo> {
//   Video? finalVideo;
//   bool isLoading = true;
//   final _firebase = FirebaseFirestore.instanceFor(app: otherFirebase).collection("VideosData");
//   Future<Video> addtoTop(dynamic doc) async {
//     Video? sharedVideo;
//     await _firebase.doc(doc).get().then((value) {
//       Video video = Video.fromJson(value.data()!);
//       sharedVideo = video;
//     });
//     return sharedVideo!;
//   }

//   void init() async {
//     final feedViewModel = Provider.of<FeedViewModel>(context,listen: false);
//     feedViewModel.pauseDrawer();
//     finalVideo = await addtoTop(widget.id);
//     await finalVideo!.loadController().whenComplete(() {
//       setState(() {
//         isLoading = false;
//       });
//       finalVideo!.controller!.play();
//     });
//   }

//   @override
//   void initState() {
//     init();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     finalVideo!.controller!.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final feedViewModel = Provider.of<FeedViewModel>(context,listen: false);
//     return Scaffold(
//       body: Container(
//         padding: MediaQuery.of(context).padding,
//         width: MediaQuery.of(context).size.width,
//         height: MediaQuery.of(context).size.height,
//         child: isLoading
//             ? const Center(
//                 child: CircularProgressIndicator(),
//               )
//             : Stack(
//                 children: [
//                   Stack(
//                     children: [
//                       if (finalVideo!.controller != null &&
//                           finalVideo!.controller!.value.isInitialized)
//                         videoCard(finalVideo!),
//                       if (finalVideo == null ||
//                           finalVideo!.controller == null ||
//                           !finalVideo!.controller!.value.isInitialized)
//                         const Center(
//                           child: CircularProgressIndicator(),
//                         )
//                     ],
//                   ),
//                   Positioned(
//                     left: 10,
//                     top: 10,
//                     child: Row(
//                       children: [
//                         IconButton(
//                             icon: const Icon(
//                               Ionicons.close_outline,
//                             ),
//                             onPressed: () {
//                               if (finalVideo!.controller != null &&
//                                   finalVideo!.controller!.value.isInitialized) {
//                                 finalVideo!.controller!.pause();
//                                 Navigator.of(context).pop();
//                                 feedViewModel.seekZero();
//                                 feedViewModel.playDrawer();
//                               }
//                             }),
//                         const SizedBox(
//                           width: 10,
//                         ),
//                         const Text('Shared Video'),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }

// Widget videoCard(Video video) {
//   return video.controller != null && video.controller!.value.isInitialized
//       ? Stack(children: [
//           GestureDetector(
//             onTap: () {
//               if (video.controller!.value.isPlaying) {
//                 video.controller?.pause();
//               } else {
//                 video.controller?.play();
//               }
//             },
//             child: SizedBox.expand(
//                 child: FittedBox(
//               fit: BoxFit.cover,
//               child: SizedBox(
//                 width: video.controller?.value.size.width ?? 0,
//                 height: video.controller?.value.size.height ?? 0,
//                 child: VideoPlayer(video.controller!),
//               ),
//             )),
//           ),
//         ])
//       : const Center(
//           child: Text('Loading'),
//         );
// }
