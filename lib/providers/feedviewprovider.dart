import '../data/video_firebase.dart';
import 'package:stacked/stacked.dart';

class FeedViewModel extends BaseViewModel {
  VideosAPI? videoSource;

  int prevVideo = 0;
  bool? creatingLink = false;
  int currentscreen = 0;
  // bool loading = true;

  FeedViewModel() {
    setBusy(true);
    videoSource = VideosAPI();
    setBusy(false);
  }
  dynamic length() {
    return videoSource?.listVideos.length;
  }

  initial() async {
    setBusy(true);
    await _initializeControllerAtIndex(0);

    /// Play 1st video
    //_playControllerAtIndex(0);
    setBusy(false);

    /// Initialize 2nd vide
    await _initializeControllerAtIndex(1);
  }

  onpageChanged(int index) {
    if ((index + 3) >= length()) {
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

  void startCircularProgess() {
    creatingLink = true;
    notifyListeners();
  }

  void endCircularProgess() {
    creatingLink = false;
    notifyListeners();
  }

  void seekZero() async {
    if (videoSource!.listVideos.isNotEmpty) {
      await videoSource!.listVideos[currentscreen].controller
          ?.seekTo(Duration.zero);
      // notifyListeners();
    }
  }

  Future<void> pauseDrawer() async {
    if (videoSource!.listVideos.isNotEmpty) {
      await videoSource!.listVideos[currentscreen].controller?.pause();
      // notifyListeners();
    }
  }

  Future<void> playDrawer() async {
    if (videoSource!.listVideos.isNotEmpty) {
      videoSource!.listVideos[currentscreen].controller?.play();
      // notifyListeners();
    }
  }

  void pauseVideo(int index) async {
    if (videoSource!.listVideos.length > index) {
      await videoSource!.listVideos[index].controller?.pause();
      // notifyListeners();
    }
  }

  void playVideo(int index) async {
    if (videoSource!.listVideos.length > index) {
      videoSource!.listVideos[index].controller?.play();
      //notifyListeners();
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

    /// Play current video (already initialized
    if (!videoSource!.listVideos[index].controller!.value.isInitialized) {
      _initializeControllerAtIndex(index);
    }
    _playControllerAtIndex(index);

    /// Initialize [index - 1] controller
    _initializeControllerAtIndex(index - 1);
  }

  Future _initializeControllerAtIndex(int index) async {
    if (videoSource!.listVideos.length > index && index >= 0) {
      /// Create new controller
      await videoSource!.listVideos[index].loadController();
      // notifyListeners();
      //log('🚀🚀🚀 INITIALIZED $index');
    }
  }

  void _playControllerAtIndex(int index) {
    if (videoSource!.listVideos.length > index && index >= 0) {
      /// Get controller at [index]
      videoSource!.listVideos[index].controller?.play();
      //notifyListeners();
      //log('🚀🚀🚀 PLAYING $index');
    }
  }

  void _stopControllerAtIndex(int index) {
    if (videoSource!.listVideos.length > index && index >= 0) {
      /// Get controller at [index]
      videoSource!.listVideos[index].controller?.pause();
      //notifyListeners();

      //log('🚀🚀🚀 STOPPED $index');
    }
  }

  void _disposeControllerAtIndex(int index) {
    if (videoSource!.listVideos.length > index && index >= 0) {
      /// Get controller at [index]
      videoSource!.listVideos[index].controller?.dispose();
      //notifyListeners();
      //log('🚀🚀🚀 DISPOSED $index');
    }
  }

  Future<void> disposingall() async {
    await videoSource!.listVideos[currentscreen].controller?.dispose();
    if (currentscreen + 1 < videoSource!.listVideos.length) {
      await videoSource!.listVideos[currentscreen + 1].controller?.dispose();
    }
    if (currentscreen - 1 >= 0) {
      await videoSource!.listVideos[currentscreen - 1].controller?.dispose();
    }
    //notifyListeners();
  }
}
