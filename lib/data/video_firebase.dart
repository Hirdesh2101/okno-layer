//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'demodata.dart';
import 'video.dart';

class VideosAPI {
  List<Video> listVideos = <Video>[];
  List<Map<int, VideoPlayerController>> controllers =
      <Map<int, VideoPlayerController>>[];

  VideosAPI() {
    load();
  }

  void load() async {
    listVideos = await getVideoList();
    controllers = await getControllersList();
  }

  Future<List<Map<int, VideoPlayerController>>> getControllersList() async {
    var controllerlist = <Map<int, VideoPlayerController>>[];
    return controllerlist;
  }

  Future<List<Video>> getVideoList() async {
    //var data = await FirebaseFirestore.instance.collection("Videos").get();

    var videoList = <Video>[];
    // var videos;
    // ignore: unused_local_variable
    for (var videos in data) {
      Video video = Video.fromJson(videos);
      videoList.add(video);
      // videoList.add(video);
      // await FirebaseFirestore.instance.collection("Videos").add(video);
    }
    // if (data.docs.length == 0) {
    //  await addDemoData();
    //  videos = (await FirebaseFirestore.instance.collection("Videos").get());
    //} else {
    //  videos = data;
    //}

    //videos.docs.forEach((element) {
    //  Video video = Video.fromJson(element.data());
    //  videoList.add(video);
    //});

    return videoList;
  }

  //Future<Null> addDemoData() async {
  /// for (var video in data) {
  // await FirebaseFirestore.instance.collection("Videos").add(video);
  //   }
  //}
}
