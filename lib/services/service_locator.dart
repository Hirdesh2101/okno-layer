import 'package:oknoapp/providers/audioprovider.dart';
import 'package:oknoapp/providers/brand_provider.dart';
import 'package:oknoapp/providers/branddetailsprovider.dart';
import 'package:oknoapp/providers/savedvideoprovider.dart';
import '../providers/feedviewprovider.dart';
import '../providers/likedvideoprovider.dart';
import 'package:get_it/get_it.dart';
import '../providers/filter_provider.dart';
import '../providers/myvideosprovider.dart';

final locator = GetIt.instance;

void setup() {
  if (!locator.isRegistered<FeedViewModel>()) {
    locator.registerSingleton<FeedViewModel>(FeedViewModel());
  }
  if (!locator.isRegistered<FilterViewModel>()) {
    locator.registerSingleton<FilterViewModel>(FilterViewModel());
  }
  setupLike();
  setupMyVideos();
}

void setupLike() {
  if (!locator.isRegistered<LikeProvider>()) {
    locator.registerSingleton<LikeProvider>(LikeProvider());
  }
}

void setupMyVideos() {
  if (!locator.isRegistered<MyVideosProvider>()) {
    locator.registerSingleton<MyVideosProvider>(MyVideosProvider());
  }
  if (!locator.isRegistered<MySavedVideosProvider>()) {
    locator.registerSingleton<MySavedVideosProvider>(MySavedVideosProvider());
  }
}

void setupBrand() {
  if (!locator.isRegistered<BrandVideoProvider>()) {
    locator.registerSingleton<BrandVideoProvider>(BrandVideoProvider());
  }
  if (!locator.isRegistered<BrandDetailsProvider>()) {
    locator.registerSingleton<BrandDetailsProvider>(BrandDetailsProvider());
  }
}

void setupAudio() {
  if (!locator.isRegistered<AudioProvider>()) {
    locator.registerSingleton<AudioProvider>(AudioProvider());
  }
}
