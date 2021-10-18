import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/audios.dart';

class AudiosAPI {
  List<AudioDetails> audioData = <AudioDetails>[];
  final _firebase = FirebaseFirestore.instance.collection('AudioData');

  AudiosAPI() {
    load();
  }

  void load() async {
    audioData = await _getAudioList();
  }

  Future<List<AudioDetails>> _getAudioList() async {
    var data = await _firebase.get();
    var audioList = <AudioDetails>[];
    QuerySnapshot<Map<String, dynamic>> audios;
    audios = data;

    for (var element in audios.docs) {
      AudioDetails audio = AudioDetails.fromJson(element.data());
      audioList.add(audio);
    }
    return audioList;
  }
}
