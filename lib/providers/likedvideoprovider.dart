import 'package:stacked/stacked.dart';
import '../data/liked_firebase.dart';

class LikeProvider extends BaseViewModel {
  LikedVideosAPI? likedVideosAPI;
  LikeProvider() {
    likedVideosAPI = LikedVideosAPI();
  }
  dynamic length() {
    return likedVideosAPI?.listVideos.length;
  }
}
