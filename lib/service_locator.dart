import 'providers/feedviewprovider.dart';
import 'providers/likedvideoprovider.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

void setup() {
  locator.registerSingleton<FeedViewModel>(FeedViewModel());
  locator.registerSingleton<LikeProvider>(LikeProvider());
}
