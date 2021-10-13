import 'package:oknoapp/data/brands_specificdata.dart';
import 'package:stacked/stacked.dart';

class BrandDetailsProvider extends BaseViewModel {
  BrandDeatilsAPI? videoSource;

  BrandDetailsProvider() {
    setBusy(true);
    videoSource = BrandDeatilsAPI();
    setBusy(false);
  }
  Future<void> refresh() async {
    setBusy(true);
    await videoSource!.load();
    notifyListeners();
    setBusy(false);
  }

  Future<void> applyFilter() async {
    setBusy(true);
    await videoSource!.applyFilter();
    notifyListeners();
    setBusy(false);
  }

  Future<void> removeFilter() async {
    setBusy(true);
    await videoSource!.load();
    notifyListeners();
    setBusy(false);
  }
}
