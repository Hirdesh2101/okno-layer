import 'providers/feedviewprovider.dart';
import 'providers/likedvideoprovider.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

void setup() {
  if (!locator.isRegistered<FeedViewModel>()) {
    locator.registerSingleton<FeedViewModel>(FeedViewModel());
  }
  if (!locator.isRegistered<LikeProvider>()) {
    locator.registerSingleton<LikeProvider>(LikeProvider());
  }
}
