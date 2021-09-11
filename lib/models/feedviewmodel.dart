import '../data/video_firebase.dart';
import 'package:stacked/stacked.dart';

class FeedViewModel extends BaseViewModel {
  //VideoPlayerController? controller;
  VideosAPI? videoSource;

  int prevVideo = 0;

  int currentscreen = 0;

  FeedViewModel() {
    videoSource = VideosAPI();
  }
  dynamic length() {
    return videoSource?.listVideos.length;
  }

  initial() async {
    await _initializeControllerAtIndex(0);

    /// Play 1st video
    _playControllerAtIndex(0);

    /// Initialize 2nd vide
    await _initializeControllerAtIndex(1);
  }

  onpageChanged(int index) {
    if (index > currentscreen) {
      playNext(index);
    } else {
      playPrevious(index);
    }
    currentscreen = index;
  }

  /*changeVideo(index) async {
    if (videoSource!.listVideos[index].controller == null) {
      await videoSource!.listVideos[index].loadController();
    }
    videoSource!.listVideos[index].controller!.play();
    //videoSource.listVideos[prevVideo].controller.removeListener(() {});

    if (videoSource!.listVideos[prevVideo].controller != null) {
      videoSource!.listVideos[prevVideo].controller!.pause();
    }

    prevVideo = index;
    notifyListeners();
  }*/

  /*void loadVideo(int index) async {
    if (videoSource!.listVideos.length > index) {
      await videoSource!.listVideos[index].loadController();
      videoSource!.listVideos[index].controller?.play();
      notifyListeners();
      if (videoSource!.listVideos.length > index + 1) {
        await videoSource!.listVideos[index + 1].loadController();
        notifyListeners();
      }
    }
  }*/

  void pauseVideo(int index) async {
    if (videoSource!.listVideos.length > index) {
      videoSource!.listVideos[index].controller?.pause();
      notifyListeners();
    }
  }

  void playVideo(int index) async {
    if (videoSource!.listVideos.length > index) {
      videoSource!.listVideos[index].controller?.play();
      notifyListeners();
    }
  }

  /*void setActualScreen(index) {
    actualScreen = index;
    if (index == 0) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    }
    notifyListeners();
  }*/

  void playNext(int index) {
    /// Stop [index - 1] controller
    _stopControllerAtIndex(index - 1);

    /// Dispose [index - 2] controller
    _disposeControllerAtIndex(index - 2);

    /// Play current video (already initialized)
    _playControllerAtIndex(index);

    /// Initialize [index + 1] controller
    _initializeControllerAtIndex(index + 1);
  }

  void playPrevious(int index) {
    /// Stop [index + 1] controller
    _stopControllerAtIndex(index + 1);

    /// Dispose [index + 2] controller
    _disposeControllerAtIndex(index + 2);

    /// Play current video (already initialized)
    _playControllerAtIndex(index);

    /// Initialize [index - 1] controller
    _initializeControllerAtIndex(index - 1);
  }

  Future _initializeControllerAtIndex(int index) async {
    if (videoSource!.listVideos.length > index && index >= 0) {
      /// Create new controller
      await videoSource!.listVideos[index].loadController();
      notifyListeners();
      //log('🚀🚀🚀 INITIALIZED $index');
    }
  }

  void _playControllerAtIndex(int index) {
    if (videoSource!.listVideos.length > index && index >= 0) {
      /// Get controller at [index]
      videoSource!.listVideos[index].controller?.play();
      notifyListeners();
      //log('🚀🚀🚀 PLAYING $index');
    }
  }

  void _stopControllerAtIndex(int index) {
    if (videoSource!.listVideos.length > index && index >= 0) {
      /// Get controller at [index]
      videoSource!.listVideos[index].controller?.pause();
      notifyListeners();

      //log('🚀🚀🚀 STOPPED $index');
    }
  }

  void _disposeControllerAtIndex(int index) {
    if (videoSource!.listVideos.length > index && index >= 0) {
      /// Get controller at [index]
      videoSource!.listVideos[index].controller?.dispose();
      notifyListeners();
      //log('🚀🚀🚀 DISPOSED $index');
    }
  }
}
