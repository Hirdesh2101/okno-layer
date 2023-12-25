import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:oknoapp/pages/crop_page.dart';
import 'package:oknoapp/pages/export_service.dart';
import 'dart:io';
import 'package:video_editor/video_editor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:helpers/helpers.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import './upload_videopage.dart';
import 'package:dio/dio.dart';
//import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import './audio_sheet.dart';
import '../services/service_locator.dart';
import 'package:video_player/video_player.dart';

class EditVideo extends StatefulWidget {
  static const routeName = '/editing_video';
  final File video;
  const EditVideo(this.video, {Key? key}) : super(key: key);

  @override
  _EditVideoState createState() => _EditVideoState();
}

class _EditVideoState extends State<EditVideo> {
  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    setupAudio();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return VideoEditor(file: widget.video);
  }
}

class VideoEditor extends StatefulWidget {
  const VideoEditor({Key? key, required this.file}) : super(key: key);

  final File file;

  @override
  _VideoEditorState createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final _exportingProgress2 = ValueNotifier<double>(0.0);
  final _isExporting2 = ValueNotifier<bool>(false);
  final double height = 60;
  var _visible = 0;
  var showFilterName = false;
  final videoInfo = FlutterVideoInfo();
  bool _exported = false;
  var _page = 0;
  var showDismiss = false;
  int flag = 0;
  var coloring = false;
  var addingAudio = false;
  var angle = 0;
  String _exportText = "";
  late VideoEditorController _controller = VideoEditorController.file(
    widget.file,
    minDuration: const Duration(seconds: 1),
    maxDuration: const Duration(seconds: 100),
  );

  @override
  void initState() {
    _controller.initialize().then((_) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() async {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _isExporting2.dispose();
    _exportingProgress2.dispose();
    _controller.dispose();
    final executions = await FFmpegKit.listSessions();
    if (executions.isNotEmpty) await FFmpegKit.cancel();
    super.dispose();
  }

  void _openCropScreen() => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (ctx) => CropPage(controller: _controller)))
      .then((value) => angle = value);

  String _getColorBackground(int index) {
    String newBackground = "";

    switch (index) {
      case 1:
        newBackground = "green";
        break;
      case 2:
        newBackground = "blue";
        break;
      case 3:
        newBackground = "red";
        break;
      case 4:
        newBackground = "pink";
        break;
      case 5:
        newBackground = "yellow";
        break;
    }

    return newBackground;
  }

  String _getColorBackgroundName(int index) {
    String newBackground = "";

    switch (index) {
      case 1:
        newBackground = "Green";
        break;
      case 2:
        newBackground = "Blue";
        break;
      case 3:
        newBackground = "Red";
        break;
      case 4:
        newBackground = "Pink";
        break;
      case 5:
        newBackground = "Yellow";
        break;
    }

    return newBackground;
  }

  final List<Color> _pages = [
    Colors.transparent,
    Colors.green.withOpacity(0.2),
    Colors.blue.withOpacity(0.2),
    Colors.red.withOpacity(0.2),
    Colors.pink.withOpacity(0.2),
    Colors.yellow.withOpacity(0.2),
  ];

  Future<String> downloadURL(String extend, File file) async {
    String finalPlace = 'audio/$extend.mp3';
    await firebase_storage.FirebaseStorage.instance
        .ref(finalPlace)
        .writeToFile(file);
    return file.path;
  }

  void addAudio(int index) async {
    downloadFile(index);
    //ffmpeg -i v.mp4 -i a.wav -c:v copy -map 0:v:0 -map 1:a:0 new.mp4
  }

  Future<void> downloadFile(int index) async {
    //Permission permission1 = Permission.manageExternalStorage;
    Dio dio = Dio();
    // bool checkPermission1 = await permission1.isGranted;
    // if (checkPermission1 == false) {
    //   openAppSettings();
    //   checkPermission1 = await permission1.isGranted;
    // }
    final Directory? appDirectory = await getExternalStorageDirectory();
    final String videoDirectory = '${appDirectory!.path}/audios';
    await Directory(videoDirectory).create(recursive: true);
    const String currentTime = 'myAudio';
    final String filePath = '$videoDirectory/$currentTime.mp3';
    // if (await File(filePath).exists()) {
    //   await File(filePath).delete();
    // }
    try {
      _isExporting2.value = true;

      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Please Wait...'),
              content: ValueListenableBuilder(
                  valueListenable: _exportingProgress2,
                  builder: (_, double value, __) {
                    return !addingAudio
                        ? Text(
                            value * 100 < 100
                                ? "Adding audio ${(value * 100).ceil()}%"
                                : "Finalizing Audio1....",
                            // color: Colors.black,
                            // bold: true,
                          )
                        : showDismiss
                            ? const Text('Added SuccessFully!!!')
                            : const Text('Finalizing Audio...'
                                // color: Colors.black,
                                // bold: true,
                                );
                  }),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Dismiss'))
              ],
            );
          });
      await dio
          .download(feedViewModel.videoSource!.audioData[index].url, filePath,
              onReceiveProgress: (receivedBytes, totalBytes) async {
        // setState(() {
        //   downloading = true;
        //   progress =
        //       ((receivedBytes / totalBytes) * 100).toStringAsFixed(0) + "%";
        _exportingProgress2.value = (receivedBytes / totalBytes);
        if (receivedBytes == totalBytes) {
          setState(() {
            addingAudio = true;
          });
          await _exportAudio(filePath).then((value) async {
            if (await File(filePath).exists()) {
              await File(filePath).delete();
            }
          });
        }
      }).then((value) {
        setState(() {
          showDismiss = true;
        });
      });
      _exportingProgress2.value = 0.0;
      _isExporting2.value = false;
    } catch (e) {
      // print(e);
    }
  }

  Future<void> _exportAudio(String audio) async {
    final Directory? appDirectory = await getExternalStorageDirectory();
    final String videoDirectory = '${appDirectory!.path}/Videos';
    await Directory(videoDirectory).create(recursive: true);
    const String currentTime = 'temp_video';
    final String filePath = '$videoDirectory/$currentTime.mp4';
    if (await File(filePath).exists()) {
      await File(filePath).delete();
    }
    await FFmpegKit.execute(
            '-i ${widget.file.path} -i $audio -c:v copy -map 0:v:0 -map 1:a:0 -shortest $filePath')
        .whenComplete(() async {
      _controller.dispose();
      _controller = VideoEditorController.file(
        File(filePath),
      );
      await _controller.initialize().then((_) {
        setState(() {
          flag = 1;
        });
      });
    });
  }

  void _filterNameFun() {
    setState(() {
      showFilterName = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        showFilterName = false;
      });
    });
  }

  int findIndexOfStringStartingWith(List<String> array, String prefix) {
    for (int i = 0; i < array.length; i++) {
      if (array[i].startsWith(prefix)) {
        return i;
      }
    }
    return -1; // Return -1 if the prefix is not found in the array
  }

  Future<File> _exportVideo() async {
    Misc.delayed(1000, () => _isExporting.value = true);
    late File file;
    final config = VideoFFmpegVideoEditorConfig(
      _controller,
      commandBuilder: (config, videoPath, outputPath) {
        final List<String> filters = config.getExportFilters();
        int index = findIndexOfStringStartingWith(filters, 'crop');
        List<String> crops = ["0", "0", "0", "0"];
        if (index != -1) {
          crops = filters[index].split(':');
        }
        return _page != 0
            ? '-ss ${config.controller.startTrim} -i $videoPath -t ${config.controller.endTrim} -f lavfi -i color=${_getColorBackground(_page)}:s=${config.controller.croppedArea.width.toInt()}*${config.controller.croppedArea.height.toInt()} -filter_complex [0]crop=${config.controller.croppedArea.width.toInt()}:${config.controller.croppedArea.height.toInt()}:${crops[2]}:${crops[3]},rotate=angle=${config.controller.cacheRotation}*PI/180[a];[a][1]blend=shortest=1:all_mode=overlay:all_opacity=0.2 -preset faster -y $outputPath'
            : '-ss ${config.controller.startTrim} -i $videoPath -t ${config.controller.endTrim} -filter_complex [0]crop=${config.controller.croppedArea.width.toInt()}:${config.controller.croppedArea.height.toInt()}:${crops[2]}:${crops[3]},rotate=angle=${config.controller.cacheRotation}*PI/180 -preset faster -y $outputPath';
      },
    );
    // Returns the generated command and the output path
    final filtersApplied = config.getExportFilters().isNotEmpty;
    if (filtersApplied || _page != 0) {
      final executeConfig = await config.getExecuteConfig();
      try {
        await FFmpegKit.execute(executeConfig.command)
            .then((value) => {file = File(executeConfig.outputPath)});
        _isExporting.value = false;
        setState(() => _exported = true);
        Misc.delayed(18000, () => setState(() => _exported = false));
        return file;
        // await ExportService.runFFmpegCommand(
        //   executeConfig,
        //   onProgress: (stats) {
        //     _exportingProgress.value =
        //         stats.getTime() / _controller.video.value.duration.inMilliseconds;
        //   },
        //   onError: (e, s) =>
        //       Fluttertoast.showToast(msg: '"Error on export video :("'),
        //   onCompleted: (fileout) {
        //     _isExporting.value = false;
        //     if (!mounted) return;
        //     file = fileout;
        //   },
        // );
      } catch (error, stackTrace) {
        // Handle error if needed
        print("Error exporting video: $error");
        print(stackTrace);
      }
    }

    // final Directory? appDirectory = await getExternalStorageDirectory();
    // final String videoDirectory = '${appDirectory!.path}/Videos';
    // await Directory(videoDirectory).create(recursive: true);
    // final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    // final String filePath = '$videoDirectory/$currentTime.mp4';

    // setState(() {
    //   coloring = true;
    // });
    // final arguments = '-i ${file!.path} ' +
    //     '-preset ultrafast -g 48 -sc_threshold 0 ' +
    //     '-map 0:0 -map 0:1 -map 0:0 -map 0:1 ' +
    //     '-c:v:0 libx264 -b:v:0 1000k ' +
    //     '-c:v:1 libx264 -b:v:1 600k ' +
    //     '-c:a copy ' +
    //     '-var_stream_map "v:0,a:0 v:1,a:1" ' +
    //     '-master_pl_name master.m3u8 ' +
    //     '-f hls -hls_time 6 -hls_list_size 0 ' +
    //     '-hls_segment_filename "$videoDirectory/%v_fileSequence_%d.ts" ' +
    //     '$videoDirectory/%v_playlistVariant.m3u8';

    // await FFmpegKit.execute(arguments);
    // if (_page != 0) {
    //   await FFmpegKit.execute(
    //       '-i ${file!.path} -f lavfi -i "color=${_getColorBackground(_page)}:s=$size1" -filter_complex "blend=shortest=1:all_mode=overlay:all_opacity=0.2" -preset ultrafast -y $filePath');
    //   if (await file!.exists()) {
    //     await file!.delete();
    //   }
    // }

    return widget.file;
  }

  void _exportCover() async {
    setState(() => _exported = false);
    File? cover;

    final config = CoverFFmpegVideoEditorConfig(_controller);
    await config
        .getExecuteConfig()
        .then((value) => cover = File(value!.outputPath));
    // await _controller.extractCover(onCompleted: ((file) {
    //   cover = file;
    // }));

    if (cover != null) {
      _exportText = "Cover exported! ${cover!.path}";
    } else {
      _exportText = "Error on cover exportation :(";
    }

    setState(() => _exported = true);
    Misc.delayed(2000, () => setState(() => _exported = false));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (flag == 1) {
          await _controller.file.delete();
        }
        return true;
      },
      child: Scaffold(
        //backgroundColor: Colors.black,
        body: _controller.initialized
            ? SafeArea(
                child: Stack(children: [
                  Stack(children: [
                    DefaultTabController(
                        length: 2,
                        child:
                            Column(mainAxisSize: MainAxisSize.max, children: [
                          Expanded(
                              child: TabBarView(
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              Stack(alignment: Alignment.topCenter, children: [
                                // CropGridViewer(
                                //   controller: _controller,
                                //   showGrid: false,
                                // ),
                                AnimatedContainer(
                                    duration: const Duration(seconds: 1),
                                    curve: Curves.fastOutSlowIn,
                                    child: SizedBox.expand(
                                        child: FittedBox(
                                            fit: BoxFit.cover,
                                            child: SizedBox(
                                              width: _controller
                                                  .video.value.size.width,
                                              height: _controller
                                                  .video.value.size.height,
                                              child: VideoPlayer(
                                                  _controller.video),
                                            )))),
                                // AnimatedBuilder(
                                //   animation: _controller.video,
                                //   builder: (_, __) => OpacityTransition(
                                //     visible: !_controller.isPlaying,
                                //     child: GestureDetector(
                                //       onTap: _controller.video.play,
                                //     ),
                                //   ),
                                // ),
                                // if (!_controller.video.value.isPlaying)
                                OpacityTransition(
                                  visible: !_controller.video.value.isPlaying,
                                  child: Center(
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.07,
                                      width:
                                          MediaQuery.of(context).size.height *
                                              0.07,
                                      child: const Icon(Icons.play_arrow),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: Colors.grey.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                ),
                                PageView.builder(
                                  itemCount: _pages.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        if (_controller.video.value.isPlaying) {
                                          _controller.video.pause();
                                          setState(() {});
                                        } else {
                                          _controller.video.play();
                                          setState(() {});
                                        }
                                      },
                                      child: SizedBox.expand(
                                        child: FittedBox(
                                          fit: BoxFit.cover,
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: _controller
                                                .video.value.size.height,
                                            child: Container(
                                              child: Center(
                                                child: OpacityTransition(
                                                  visible: showFilterName,
                                                  child: Text(
                                                    _getColorBackgroundName(
                                                        index),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 25,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              decoration: BoxDecoration(
                                                  color: _pages[index]),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  scrollDirection: Axis.horizontal,
                                  onPageChanged: (value) {
                                    _page = value;
                                    _filterNameFun();
                                  },
                                ),
                              ]),
                              CoverViewer(controller: _controller)
                            ],
                          )),
                          AnimatedContainer(
                              height: _visible.toDouble(),
                              duration: const Duration(seconds: 1),
                              curve: Curves.fastOutSlowIn,
                              child: Column(children: [
                                TabBar(
                                  indicatorColor: Colors.white,
                                  tabs: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Padding(
                                              padding: Margin.all(5),
                                              child: Icon(Icons.content_cut)),
                                          Text('Trim')
                                        ]),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Padding(
                                              padding: Margin.all(5),
                                              child: Icon(Icons.video_label)),
                                          Text('Cover')
                                        ]),
                                  ],
                                ),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: _trimSlider()),
                                      Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [_coverSelection()]),
                                    ],
                                  ),
                                )
                              ])),
                          _customSnackBar(),
                          ValueListenableBuilder(
                            valueListenable: _isExporting,
                            builder: (_, bool export, __) => OpacityTransition(
                              visible: export,
                              child: AlertDialog(
                                // backgroundColor: Colors.white,
                                title: ValueListenableBuilder(
                                    valueListenable: _exportingProgress,
                                    builder: (_, double value, __) {
                                      return !coloring
                                          ? Text(
                                              value * 100 < 100
                                                  ? "Exporting video ${(value * 100).ceil()}%"
                                                  : "Finalizing Colors....",
                                              // color: Colors.black,
                                              // bold: true,
                                            )
                                          : const Text('Finalizing Colors...'
                                              // color: Colors.black,
                                              // bold: true,
                                              );
                                    }),
                              ),
                            ),
                          )
                        ])),
                    Align(
                      alignment: Alignment.topCenter,
                      child: _topNavBar(),
                    ),
                  ])
                ]),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _topNavBar() {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),
          Expanded(
            child: IconButton(
              onPressed: () {
                setState(() {
                  if (_visible == 0) {
                    _visible = 200;
                  } else {
                    _visible = 0;
                  }
                });
              },
              icon: const Icon(Icons.cut, color: Colors.white),
            ),
          ),
          Expanded(
            child: IconButton(
              onPressed: _openCropScreen,
              icon: const Icon(Icons.crop, color: Colors.white),
            ),
          ),
          Expanded(
            child: IconButton(
              onPressed: () {
                if (_controller.video.value.isPlaying) {
                  _controller.video.pause();
                  setState(() {});
                }
                AudioSheet().sheet(context, addAudio);
              },
              icon: const Icon(Icons.audiotrack, color: Colors.white),
            ),
          ),
          Expanded(
            child: IconButton(
              onPressed: _exportCover,
              icon: const Icon(Icons.save_alt, color: Colors.white),
            ),
          ),
          Expanded(
            child: IconButton(
              onPressed: () async {
                File file = await _exportVideo();
                if (file != null) {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (context) => UploadPage(file, file.path)))
                      .then((value) {
                    Navigator.of(context).pop();
                  });
                }
              },
              icon: const Icon(Icons.done, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: Listenable.merge([
          _controller,
          _controller.video,
        ]),
        builder: (_, __) {
          final int duration = _controller.videoDuration.inSeconds;
          final double pos = _controller.trimPosition * duration;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: height / 4),
            child: Row(children: [
              Text(formatter(Duration(seconds: pos.toInt()))),
              const Expanded(child: SizedBox()),
              AnimatedOpacity(
                opacity: _controller.isTrimming ? 1 : 0,
                duration: kThemeAnimationDuration,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(formatter(_controller.startTrim)),
                  const SizedBox(width: 10),
                  Text(formatter(_controller.endTrim)),
                ]),
              ),
            ]),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(vertical: height / 4),
        child: TrimSlider(
          controller: _controller,
          height: height,
          horizontalMargin: height / 4,
          child: TrimTimeline(
            controller: _controller,
            padding: const EdgeInsets.only(top: 10),
          ),
        ),
      )
    ];
  }

  Widget _coverSelection() {
    return Container(
        margin: Margin.horizontal(height / 4),
        child: CoverSelection(
          controller: _controller,
          // size: height + 10,
          // quantity: 8,
        ));
  }

  Widget _customSnackBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SwipeTransition(
        visible: _exported,
        //direction: SwipeDirection.fromBottom,
        child: Container(
          height: height,
          width: double.infinity,
          color: Colors.black.withOpacity(0.8),
          child: Center(
            child: Text(
              _exportText,
              // bold: true,
            ),
          ),
        ),
      ),
    );
  }
}
