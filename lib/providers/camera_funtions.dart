import 'dart:io';
import 'package:video_compress/video_compress.dart';

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
}
