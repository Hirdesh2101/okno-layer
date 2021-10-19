import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:oknoapp/models/audios.dart';
import '../providers/audioprovider.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioSheet {
  void sheet(context, Function(int index) addAudio) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 10,
        builder: (context) {
          return PlayerWid(addAudio);
        });
  }
}

final feedViewModel = GetIt.instance<AudioProvider>();

class PlayerWid extends StatefulWidget {
  final Function(
    int index,
  ) addAudio;
  const PlayerWid(this.addAudio, {Key? key}) : super(key: key);

  @override
  _PlayerWidState createState() => _PlayerWidState();
}

class _PlayerWidState extends State<PlayerWid> {
  AudioPlayer audioPlayer = AudioPlayer();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Audio List'),
        ),
        body: MyItem(
          audioPlayer: audioPlayer,
          addAudio: widget.addAudio,
        ));
  }
}

class MyItem extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final Function(int index) addAudio;
  const MyItem({Key? key, required this.audioPlayer, required this.addAudio})
      : super(key: key);
  @override
  _MyItemState createState() => _MyItemState();
}

class _MyItemState extends State<MyItem> {
  late int result;
  List<AudioDetails> audiolist = feedViewModel.videoSource!.audioData;
  int status = 0;
  _trySubmit(int index) {
    widget.addAudio(index);
  }

  @override
  void dispose() {
    widget.audioPlayer.stop();
    for (int i = 0; i < audiolist.length; i++) {
      audiolist[i].playingstatus = 0;
    }
    widget.audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: audiolist.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () async {
            if (audiolist[index].playingstatus == 0) {
              result = await widget.audioPlayer.stop();
              //await widget.audioPlayer.dispose();
              result = await widget.audioPlayer
                  .play(audiolist[index].url, isLocal: true);
              setState(() {
                for (int i = 0; i < audiolist.length; i++) {
                  audiolist[i].playingstatus = 0;
                }
                audiolist[index].playingstatus = 1;
              });
            } else if (audiolist[index].playingstatus == 1) {
              result = await widget.audioPlayer.stop();
              //await widget.audioPlayer.dispose();
              setState(() {
                for (int i = 0; i < audiolist.length; i++) {
                  audiolist[i].playingstatus = 0;
                }
              });
            }
          },
          child: ListTile(
            leading: audiolist[index].thumbnail != ''
                ? CircleAvatar(
                    backgroundImage: NetworkImage(audiolist[index].thumbnail),
                  )
                : const Icon(Icons.music_note_outlined),
            title: Text(audiolist[index].songname),
            subtitle: Text(audiolist[index].artistname),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                audiolist[index].playingstatus == 0
                    ? const Icon(Icons.play_arrow)
                    : const Icon(Icons.pause),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _trySubmit(index);
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
