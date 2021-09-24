import 'dart:io';
import 'package:video_compress/video_compress.dart';

class CameraFuctions {
  File file;
  CameraFuctions(this.file);

  Future<File> compressFunction() async {
    print('aya2aaaaaaaaaaaaaaaaaaaaaaaa');
    print(await file.length());
    while (file.lengthSync() > 4e+6) {
      await VideoCompress.setLogLevel(0);
      final MediaInfo? info = await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: true,
        includeAudio: true,
      );
      file = File(info!.path!);
      print(file.lengthSync());
      print('aya');
    }
    return file;
  }
  // if (file == null) {
  //   return file;
  // }
  // await VideoCompress.setLogLevel(0);
  // final MediaInfo? info = await VideoCompress.compressVideo(
  //   file.path,
  //   quality: VideoQuality.MediumQuality,
  //   deleteOrigin: true,
  //   includeAudio: true,
  // );
  // print(info!.path);
  // return File(info.path!);
}
