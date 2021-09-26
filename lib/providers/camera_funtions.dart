import 'dart:io';
import 'package:video_compress/video_compress.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class CameraFuctions {
  File file;
  CameraFuctions(this.file);

  Future<File> compressFunction() async {
    while (file.lengthSync() > 4e+6) {
      await VideoCompress.setLogLevel(0);
      final MediaInfo? info = await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: true,
        includeAudio: true,
      );
      file = File(info!.path!);
    }
    return file;
  }

  Future<String> reduceSizeAndType(outDirPath) async {
    final FlutterFFmpeg _encoder = FlutterFFmpeg();
    assert(File(file.path).existsSync());
    await _encoder
        .execute("-i ${file.path} -c:v mpeg4 $outDirPath")
        .then((value) => print('the value of rc is $value'));

    return outDirPath;
  }
}
