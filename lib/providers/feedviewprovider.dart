import '../data/video_firebase.dart';
import 'package:stacked/stacked.dart';

class FeedViewModel extends BaseViewModel {
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
    print(videoSource!.listVideos.length);
    if ((index - 7) % 10 == 0) {
      videoSource!.addVideos();
      notifyListeners();
    }
    if (index > currentscreen) {
      playNext(index);
    } else {
      playPrevious(index);
    }
    currentscreen = index;
  }

  void pauseDrawer() async {
    videoSource!.listVideos[currentscreen].controller?.pause();
    notifyListeners();
  }

  void playDrawer() async {
    videoSource!.listVideos[currentscreen].controller?.play();
    notifyListeners();
  }

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

  void disposingall() {
    videoSource!.listVideos[currentscreen].controller?.dispose();
    if (currentscreen + 1 < videoSource!.listVideos.length) {
      videoSource!.listVideos[currentscreen + 1].controller?.dispose();
    }
    if (currentscreen - 1 >= 0) {
      videoSource!.listVideos[currentscreen - 1].controller?.dispose();
    }
    notifyListeners();
  }
}
