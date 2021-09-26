import 'package:oknoapp/data/my_videos.dart';
import 'package:stacked/stacked.dart';

class MyVideosProvider extends BaseViewModel {
  MyVideosAPI? videoSource;
  late int prevVideo;

  late int currentscreen;
  MyVideosProvider() {
    videoSource = MyVideosAPI();
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

    /// Play 1st video
    _playControllerAtIndex(start);
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
    await videoSource!.listData[currentscreen].controller?.dispose();
    if (currentscreen + 1 < videoSource!.listData.length) {
      await videoSource!.listData[currentscreen + 1].controller?.dispose();
    }
    if (currentscreen - 1 >= 0) {
      await videoSource!.listData[currentscreen - 1].controller?.dispose();
    }
    notifyListeners();
  }
}
