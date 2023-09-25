import 'package:stacked/stacked.dart';
import '../data/liked_firebase.dart';

class LikeProvider extends BaseViewModel {
  LikedVideosAPI? videoSource;
  late int prevVideo;

  late int currentscreen;
  LikeProvider() {
    videoSource = LikedVideosAPI();
  }

  dynamic length() {
    return videoSource?.listData.length;
  }

  initial(int start) async {
    currentscreen = start;
    if (start - 1 >= 0) {
      prevVideo = start - 1;
    }
    setBusy(true);
    await _initializeControllerAtIndex(start);
    //print('aya');

    /// Play 1st video
    _playControllerAtIndex(start);
    //notifyListeners();
    //print('aya1');
    setBusy(false);

    /// Initialize 2nd vide
    await _initializeControllerAtIndex(start - 1);
    await _initializeControllerAtIndex(start + 1);
  }

  onpageChanged(int index) {
    if ((index - 7) % 10 == 0) {
      //videoSource!.addVideos();
      //notifyListeners();
    }
    if (index > currentscreen) {
      playNext(index);
    } else {
      playPrevious(index);
    }
    currentscreen = index;
  }

  Future<void> pauseDrawer() async {
    await videoSource!.listData[currentscreen].controller?.pause();
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }

  void playDrawer() async {
    videoSource!.listData[currentscreen].controller?.play();
    notifyListeners();
  }

  void pauseVideo(int index) async {
    if (videoSource!.listData.length > index) {
      videoSource!.listData[index].controller?.pause();
      notifyListeners();
    }
  }

  void playVideo(int index) async {
    if (videoSource!.listData.length > index) {
      videoSource!.listData[index].controller?.play();
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
    if (videoSource!.listData.length > index && index >= 0) {
      /// Create new controller
      await videoSource!.listData[index].loadController();
      notifyListeners();
      //log('🚀🚀🚀 INITIALIZED $index');
    }
  }

  void _playControllerAtIndex(int index) {
    if (videoSource!.listData.length > index && index >= 0) {
      /// Get controller at [index]
      videoSource!.listData[index].controller?.play();
      notifyListeners();
      //log('🚀🚀🚀 PLAYING $index');
    }
  }

  void _stopControllerAtIndex(int index) {
    if (videoSource!.listData.length > index && index >= 0) {
      /// Get controller at [index]
      videoSource!.listData[index].controller?.pause();
      notifyListeners();

      //log('🚀🚀🚀 STOPPED $index');
    }
  }

  void _disposeControllerAtIndex(int index) {
    if (videoSource!.listData.length > index && index >= 0) {
      /// Get controller at [index]
      videoSource!.listData[index].controller?.dispose();
      notifyListeners();
      //log('🚀🚀🚀 DISPOSED $index');
    }
  }

  Future<void> disposingall() async {
    if (videoSource!.listData[currentscreen].controller != null) {
      await videoSource!.listData[currentscreen].controller?.dispose();
    }
    if (currentscreen + 1 < videoSource!.listData.length) {
      if (videoSource!.listData[currentscreen + 1].controller != null) {
        await videoSource!.listData[currentscreen + 1].controller?.dispose();
      }
    }
    if (currentscreen - 1 >= 0) {
      if (videoSource!.listData[currentscreen - 1].controller != null) {
        await videoSource!.listData[currentscreen - 1].controller?.dispose();
      }
    }
  }
}
