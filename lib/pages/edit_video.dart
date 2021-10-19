import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:video_editor/video_editor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:helpers/helpers.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import './upload_videopage.dart';
import 'package:dio/dio.dart';
//import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import './audio_sheet.dart';
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
  var coloring = false;
  var addingAudio = false;
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
  String _exportText = "";
  late VideoEditorController _controller;

  @override
  void initState() {
    _controller = VideoEditorController.file(
      widget.file,
    );
    _controller.initialize().then((_) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _openCropScreen() => context.navigator.push(
      MaterialPageRoute(builder: (ctx) => CropScreen(controller: _controller)));

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
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = '$videoDirectory/$currentTime.mp3';

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
          await _exportAudio(filePath).then((value) => null);
        }
      }).then((value) {
        setState(() {
          showDismiss = true;
        });
      });
      _isExporting2.value = false;
    } catch (e) {
      // print(e);
    }
  }

  Future<void> _exportAudio(String audio) async {
    final Directory? appDirectory = await getExternalStorageDirectory();
    final String videoDirectory = '${appDirectory!.path}/Videos';
    await Directory(videoDirectory).create(recursive: true);
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = '$videoDirectory/$currentTime.mp4';
    await _flutterFFmpeg
        .execute(
            '-i ${widget.file.path} -i $audio -c:v copy -map 0:v:0 -map 1:a:0 -shortest $filePath')
        .whenComplete(() async {
      _controller = VideoEditorController.file(
        File(filePath),
      );
      await _controller.initialize().then((_) {
        setState(() {});
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

  Future<File> _exportVideo() async {
    Misc.delayed(1000, () => _isExporting.value = true);
    final File? file = await _controller.exportVideo(
      preset: VideoExportPreset.ultrafast,
      customInstruction: "-crf 17",
      onProgress: (statics) {
        _exportingProgress.value =
            statics.time / _controller.video.value.duration.inMilliseconds;
      },
    );
    final Directory? appDirectory = await getExternalStorageDirectory();
    final String videoDirectory = '${appDirectory!.path}/Videos';
    await Directory(videoDirectory).create(recursive: true);
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = '$videoDirectory/$currentTime.mp4';
    var info = await videoInfo.getVideoInfo(file!.path.toString());
    final String size1 = "${info!.width!.toInt()}x${info.height!.toInt()}";
    setState(() {
      coloring = true;
    });
    if (_page != 0) {
      await _flutterFFmpeg.execute(
          '-i ${file.path} -f lavfi -i "color=${_getColorBackground(_page)}:s=$size1" -filter_complex "blend=shortest=1:all_mode=overlay:all_opacity=0.2" -preset ultrafast -y $filePath');
    }
    _isExporting.value = false;

    // ignore: unnecessary_null_comparison
    if (file != null) {
      _exportText = "Video success export!";
    } else {
      _exportText = "Error on export video :(";
    }
    File? finalFile;
    if (_page != 0) {
      finalFile = File(filePath);
    } else {
      finalFile = file;
    }
    setState(() => _exported = true);
    Misc.delayed(18000, () => setState(() => _exported = false));
    return finalFile;
  }

  void _exportCover() async {
    setState(() => _exported = false);
    final File? cover = await _controller.extractCover();

    if (cover != null) {
      _exportText = "Cover exported! ${cover.path}";
    } else {
      _exportText = "Error on cover exportation :(";
    }

    setState(() => _exported = true);
    Misc.delayed(2000, () => setState(() => _exported = false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.black,
      body: _controller.initialized
          ? SafeArea(
              child: Stack(children: [
                Stack(children: [
                  DefaultTabController(
                      length: 2,
                      child: Column(mainAxisSize: MainAxisSize.max, children: [
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
                                            child:
                                                VideoPlayer(_controller.video),
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
                                    height: MediaQuery.of(context).size.height *
                                        0.07,
                                    width: MediaQuery.of(context).size.height *
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
                                          width:
                                              MediaQuery.of(context).size.width,
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
                                                    fontWeight: FontWeight.bold,
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
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) => UploadPage(file, file.path)))
                    .then((value) {
                  Navigator.of(context).pop();
                });
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
        animation: _controller.video,
        builder: (_, __) {
          final duration = _controller.video.value.duration.inSeconds;
          final pos = _controller.trimPosition * duration;
          final start = _controller.minTrim * duration;
          final end = _controller.maxTrim * duration;

          return Padding(
            padding: Margin.horizontal(height / 4),
            child: Row(children: [
              Text(formatter(Duration(seconds: pos.toInt()))),
              const Expanded(child: SizedBox()),
              OpacityTransition(
                visible: _controller.isTrimming,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(formatter(Duration(seconds: start.toInt()))),
                  const SizedBox(width: 10),
                  Text(formatter(Duration(seconds: end.toInt()))),
                ]),
              )
            ]),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: Margin.vertical(height / 4),
        child: TrimSlider(
            child: TrimTimeline(
                controller: _controller,
                margin: const EdgeInsets.only(top: 10)),
            controller: _controller,
            height: height,
            horizontalMargin: height / 4),
      )
    ];
  }

  Widget _coverSelection() {
    return Container(
        margin: Margin.horizontal(height / 4),
        child: CoverSelection(
          controller: _controller,
          height: height,
          nbSelection: 8,
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

class CropScreen extends StatelessWidget {
  const CropScreen({Key? key, required this.controller}) : super(key: key);

  final VideoEditorController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const Margin.all(30),
          child: Column(children: [
            Expanded(
              child: AnimatedInteractiveViewer(
                maxScale: 2.4,
                child: CropGridViewer(controller: controller),
              ),
            ),
            const SizedBox(height: 15),
            Row(children: [
              Expanded(
                child: SplashTap(
                  onTap: () => context.navigator.pop(),
                  child: const Center(
                    child: Text(
                      "CANCEL",
                      // bold: true,
                    ),
                  ),
                ),
              ),
              buildSplashTap("16:9", 16 / 9,
                  padding: const Margin.horizontal(10)),
              buildSplashTap("1:1", 1 / 1),
              buildSplashTap("4:5", 4 / 5,
                  padding: const Margin.horizontal(10)),
              buildSplashTap("NO", null, padding: const Margin.right(10)),
              Expanded(
                child: SplashTap(
                  onTap: () {
                    //2 WAYS TO UPDATE CROP
                    //WAY 1:
                    controller.updateCrop();
                    /*WAY 2:
                    controller.minCrop = controller.cacheMinCrop;
                    controller.maxCrop = controller.cacheMaxCrop;
                    */
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Crop will be visible after export!!!')));
                    context.navigator.pop();
                  },
                  child: const Center(
                    child: Text(
                      "OK",
                    ),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget buildSplashTap(
    String title,
    double? aspectRatio, {
    EdgeInsetsGeometry? padding,
  }) {
    return SplashTap(
      onTap: () => controller.preferredCropAspectRatio = aspectRatio,
      child: Padding(
        padding: padding ?? Margin.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.aspect_ratio,
              //color: Colors.white
            ),
            Text(
              title,
            ),
          ],
        ),
      ),
    );
  }
}
