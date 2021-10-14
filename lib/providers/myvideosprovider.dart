import 'package:oknoapp/data/my_videos.dart';
import 'package:stacked/stacked.dart';

class MyVideosProvider extends BaseViewModel {
  MyVideosAPI? videoSource;
  late int prevVideo;

  late int currentscreen;
  MyVideosProvider() {
    videoSource = MyVideosAPI();
  }

  // dynamic length() {
  //   return videoSource?.listData.length;
  // }

  initial(int start, bool approved, bool nonapproved) async {
    currentscreen = start;
    if (start - 1 >= 0) {
      prevVideo = start - 1;
    }
    setBusy(true);
    await _initializeControllerAtIndex(start, approved, nonapproved);

    /// Play 1st video
    _playControllerAtIndex(start, approved, nonapproved);
    setBusy(false);

    /// Initialize 2nd vide
    await _initializeControllerAtIndex(start - 1, approved, nonapproved);
    await _initializeControllerAtIndex(start + 1, approved, nonapproved);
  }

  onpageChanged(int index, bool approved, bool nonapproved) {
    if ((index - 7) % 10 == 0) {
      //videoSource!.addVideos();
      //notifyListeners();
    }
    if (index > currentscreen) {
      playNext(index, approved, nonapproved);
    } else {
      playPrevious(index, approved, nonapproved);
    }
    currentscreen = index;
  }

  Future<void> pauseDrawer(bool approved, bool nonapproved) async {
    if (approved || nonapproved) {
      if (approved) {
        await videoSource!.approvedData[currentscreen].controller?.pause();
        notifyListeners();
      } else {
        await videoSource!.nonapprovedData[currentscreen].controller?.pause();
        notifyListeners();
      }
    } else {
      await videoSource!.listData[currentscreen].controller?.pause();
      notifyListeners();
    }
  }

  void refresh() {
    notifyListeners();
  }

  void playDrawer(bool approved, bool nonapproved) async {
    if (approved || nonapproved) {
      if (approved) {
        videoSource!.approvedData[currentscreen].controller?.play();
        notifyListeners();
      } else {
        videoSource!.nonapprovedData[currentscreen].controller?.play();
        notifyListeners();
      }
    } else {
      videoSource!.listData[currentscreen].controller?.play();
      notifyListeners();
    }
  }

  // void pauseVideo(int index, bool approved, bool nonapproved) async {
  //   if (videoSource!.listData.length > index) {
  //     videoSource!.listData[index].controller?.pause();
  //     notifyListeners();
  //   }
  // }

  // void playVideo(int index, bool approved, bool nonapproved) async {
  //   if (videoSource!.listData.length > index) {
  //     videoSource!.listData[index].controller?.play();
  //     notifyListeners();
  //   }
  // }

  void playNext(int index, bool approved, bool nonapproved) {
    /// Stop [index - 1] controller
    _stopControllerAtIndex(index - 1, approved, nonapproved);

    /// Dispose [index - 2] controller
    _disposeControllerAtIndex(index - 2, approved, nonapproved);

    /// Play current video (already initialized)
    _playControllerAtIndex(index, approved, nonapproved);

    /// Initialize [index + 1] controller
    _initializeControllerAtIndex(index + 1, approved, nonapproved);
  }

  void playPrevious(int index, bool approved, bool nonapproved) {
    /// Stop [index + 1] controller
    _stopControllerAtIndex(index + 1, approved, nonapproved);

    /// Dispose [index + 2] controller
    _disposeControllerAtIndex(index + 2, approved, nonapproved);

    /// Play current video (already initialized)
    _playControllerAtIndex(index, approved, nonapproved);

    /// Initialize [index - 1] controller
    _initializeControllerAtIndex(index - 1, approved, nonapproved);
  }

  Future _initializeControllerAtIndex(
      int index, bool approved, bool nonapproved) async {
    if (approved || nonapproved) {
      if (approved) {
        if (videoSource!.approvedData.length > index && index >= 0) {
          /// Create new controller
          await videoSource!.approvedData[index].loadController();
          notifyListeners();
          //log('🚀🚀🚀 INITIALIZED $index');
        }
      } else {
        if (videoSource!.nonapprovedData.length > index && index >= 0) {
          /// Create new controller
          await videoSource!.nonapprovedData[index].loadController();
          notifyListeners();
          //log('🚀🚀🚀 INITIALIZED $index');
        }
      }
    } else {
      if (videoSource!.listData.length > index && index >= 0) {
        /// Create new controller
        await videoSource!.listData[index].loadController();
        notifyListeners();
        //log('🚀🚀🚀 INITIALIZED $index');
      }
    }
  }

  void _playControllerAtIndex(int index, bool approved, bool nonapproved) {
    if (approved || nonapproved) {
      if (approved) {
        if (videoSource!.approvedData.length > index && index >= 0) {
          /// Get controller at [index]
          videoSource!.approvedData[index].controller?.play();
          notifyListeners();
          //log('🚀🚀🚀 PLAYING $index');
        }
      } else {
        if (videoSource!.nonapprovedData.length > index && index >= 0) {
          /// Get controller at [index]
          videoSource!.nonapprovedData[index].controller?.play();
          notifyListeners();
          //log('🚀🚀🚀 PLAYING $index');
        }
      }
    } else {
      if (videoSource!.listData.length > index && index >= 0) {
        /// Get controller at [index]
        videoSource!.listData[index].controller?.play();
        notifyListeners();
        //log('🚀🚀🚀 PLAYING $index');
      }
    }
  }

  void _stopControllerAtIndex(int index, bool approved, bool nonapproved) {
    if (approved || nonapproved) {
      if (approved) {
        if (videoSource!.approvedData.length > index && index >= 0) {
          /// Get controller at [index]
          videoSource!.approvedData[index].controller?.pause();
          notifyListeners();

          //log('🚀🚀🚀 STOPPED $index');
        } else {
          if (videoSource!.nonapprovedData.length > index && index >= 0) {
            /// Get controller at [index]
            videoSource!.nonapprovedData[index].controller?.pause();
            notifyListeners();

            //log('🚀🚀🚀 STOPPED $index');
          }
        }
      }
    } else {
      if (videoSource!.listData.length > index && index >= 0) {
        /// Get controller at [index]
        videoSource!.listData[index].controller?.pause();
        notifyListeners();

        //log('🚀🚀🚀 STOPPED $index');
      }
    }
  }

  void _disposeControllerAtIndex(int index, bool approved, bool nonapproved) {
    if (approved || nonapproved) {
      if (approved) {
        if (videoSource!.approvedData.length > index && index >= 0) {
          /// Get controller at [index]
          videoSource!.approvedData[index].controller?.dispose();
          notifyListeners();
          //log('🚀🚀🚀 DISPOSED $index');
        }
      } else {
        if (videoSource!.nonapprovedData.length > index && index >= 0) {
          /// Get controller at [index]
          videoSource!.nonapprovedData[index].controller?.dispose();
          notifyListeners();
          //log('🚀🚀🚀 DISPOSED $index');
        }
      }
    } else {
      if (videoSource!.listData.length > index && index >= 0) {
        /// Get controller at [index]
        videoSource!.listData[index].controller?.dispose();
        notifyListeners();
        //log('🚀🚀🚀 DISPOSED $index');
      }
    }
  }

  Future<void> disposingall(bool approved, bool nonapproved) async {
    if (approved || nonapproved) {
      if (approved) {
        await videoSource!.approvedData[currentscreen].controller?.dispose();
        if (currentscreen + 1 < videoSource!.approvedData.length) {
          await videoSource!.approvedData[currentscreen + 1].controller
              ?.dispose();
        }
        if (currentscreen - 1 >= 0) {
          await videoSource!.approvedData[currentscreen - 1].controller
              ?.dispose();
        }
        notifyListeners();
      } else {
        await videoSource!.nonapprovedData[currentscreen].controller?.dispose();
        if (currentscreen + 1 < videoSource!.nonapprovedData.length) {
          await videoSource!.nonapprovedData[currentscreen + 1].controller
              ?.dispose();
        }
        if (currentscreen - 1 >= 0) {
          await videoSource!.nonapprovedData[currentscreen - 1].controller
              ?.dispose();
        }
        notifyListeners();
      }
    } else {
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
}
