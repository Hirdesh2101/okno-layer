import 'package:oknoapp/providers/brand_provider.dart';
import 'package:oknoapp/providers/savedvideoprovider.dart';

import '../providers/feedviewprovider.dart';
import '../providers/likedvideoprovider.dart';
import 'package:get_it/get_it.dart';
import '../providers/myvideosprovider.dart';

final locator = GetIt.instance;

void setup() {
  if (!locator.isRegistered<FeedViewModel>()) {
    locator.registerSingleton<FeedViewModel>(FeedViewModel());
  }
  if (!locator.isRegistered<LikeProvider>()) {
    locator.registerSingleton<LikeProvider>(LikeProvider());
  }
  if (!locator.isRegistered<MyVideosProvider>()) {
    locator.registerSingleton<MyVideosProvider>(MyVideosProvider());
  }
  if (!locator.isRegistered<MySavedVideosProvider>()) {
    locator.registerSingleton<MySavedVideosProvider>(MySavedVideosProvider());
  }
  if (!locator.isRegistered<BrandVideoProvider>()) {
    locator.registerSingleton<BrandVideoProvider>(BrandVideoProvider());
  }
}
