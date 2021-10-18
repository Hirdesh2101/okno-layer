import 'package:oknoapp/data/audio_data.dart';
import 'package:stacked/stacked.dart';

class AudioProvider extends BaseViewModel {
  AudiosAPI? videoSource;
  AudioProvider() {
    videoSource = AudiosAPI();
  }
  dynamic length() {
    return videoSource?.audioData.length;
  }
}
