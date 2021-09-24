import 'dart:async';
import 'dart:io';
import 'package:ionicons/ionicons.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:oknoapp/pages/upload_videopage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class VideoRecorder extends StatefulWidget {
  const VideoRecorder({Key? key}) : super(key: key);

  @override
  _VideoRecorderState createState() {
    return _VideoRecorderState();
  }
}

class _VideoRecorderState extends State<VideoRecorder> {
  File? file;
  CameraController? controller;
  String? videoPath;
  File? videoFile;
  ImagePicker imagePicker = ImagePicker();
  List<CameraDescription>? cameras;
  int? selectedCameraIdx;
  bool _isrecording = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  void initialize() {
    availableCameras().then((availableCameras) {
      cameras = availableCameras;

      if (cameras!.isNotEmpty) {
        setState(() {
          selectedCameraIdx = 0;
        });

        _onCameraSwitched(cameras![selectedCameraIdx!]).then((void v) {});
      }
    }).catchError((err) {
      print('Error: $err.code\nError Message: $err.message');
    });
  }

  @override
  void initState() {
    initialize();
    super.initState();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;

    return Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
          child: WillPopScope(
            onWillPop: () async {
              return true;
            },
            child: Stack(children: [
              Align(
                alignment: Alignment.center,
                child: Transform.scale(
                    scale: controller!.value.aspectRatio / deviceRatio,
                    //fit: BoxFit.contain,
                    child: _cameraPreviewWidget()),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: 120.0,
                  padding: const EdgeInsets.all(20.0),
                  color: Colors.black45,
                  child: Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              _captureControlRowWidget(),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50.0)),
                            onTap: () {
                              _selectImage();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Ionicons.file_tray_full,
                                color: Colors.grey[200],
                                size: 42,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Align(
                      //   alignment: Alignment.center,
                      //   child: Material(
                      //     color: Colors.transparent,
                      //     child: GestureDetector(
                      //       child: Container(
                      //         padding: EdgeInsets.all(4.0),
                      //         child: Icon(
                      //           Ionicons.add_circle,
                      //           size: 72,
                      //           color: _isrecording ? Colors.red : Colors.white,
                      //         ),
                      //       ),
                      //       onTap: () {
                      //         setState(() {
                      //           _isrecording = !_isrecording;
                      //         });
                      //         if (_isrecording) {
                      //           print('aya1');
                      //           controller != null &&
                      //                   controller!.value.isInitialized &&
                      //                   !controller!.value.isRecordingVideo
                      //               ? _onRecordButtonPressed
                      //               : {print('aya1')};
                      //         } else {
                      //           print('aya2');
                      //           controller != null &&
                      //                   controller!.value.isInitialized &&
                      //                   controller!.value.isRecordingVideo
                      //               ? _onStopButtonPressed
                      //               : {print('aya2')};
                      //         }
                      //       },
                      //     ),
                      //   ),
                      // ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _cameraTogglesRowWidget(),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                child: Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                  ],
                ),
              ),
            ]),
          ),
        ));
  }

  IconData _getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return Icons.camera_rear;
      case CameraLensDirection.front:
        return Icons.camera_front;
      case CameraLensDirection.external:
        return Icons.camera;
      default:
        return Icons.device_unknown;
    }
  }

  Widget _cameraPreviewWidget() {
    if (!controller!.value.isInitialized) {
      return const Text(
        'Loading',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
        ),
      );
    }
    return AspectRatio(
      aspectRatio: controller!.value.aspectRatio,
      child: CameraPreview(controller!),
    );
  }

  Widget _cameraTogglesRowWidget() {
    if (cameras! == null) {
      return Container();
    }

    CameraDescription selectedCamera = cameras![selectedCameraIdx!];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(50.0)),
        onTap: _onSwitchCamera,
        child: Container(
          padding: const EdgeInsets.all(4.0),
          child: Icon(
            _getCameraLensIcon(
              lensDirection,
            ),
            color: Colors.grey[200],
            size: 42,
          ),
        ),
      ),
    );
  }

  Widget _captureControlRowWidget() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.videocam),
            color: Colors.blue,
            onPressed: controller != null &&
                    controller!.value.isInitialized &&
                    !controller!.value.isRecordingVideo
                ? _onRecordButtonPressed
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            color: Colors.red,
            onPressed: controller != null &&
                    controller!.value.isInitialized &&
                    controller!.value.isRecordingVideo
                ? _onStopButtonPressed
                : null,
          ),
        ],
      ),
    );
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<void> _onCameraSwitched(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller!.dispose();
    }

    controller = CameraController(cameraDescription, ResolutionPreset.medium);

    controller!.addListener(() {
      if (mounted) {
        setState(() {});
      }

      if (controller!.value.hasError) {
        Fluttertoast.showToast(
            msg: 'Camera error ${controller!.value.errorDescription}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white);
      }
    });

    try {
      await controller!.initialize();
      controller!.value =
          controller!.value.copyWith(previewSize: const Size(1080, 1920));
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _selectImage() async {
    XFile? imageFile = await imagePicker.pickVideo(
      source: ImageSource.gallery,
    );
    setState(() {
      file = File(imageFile!.path);
    });
  }

  void _onSwitchCamera() {
    selectedCameraIdx =
        selectedCameraIdx! < cameras!.length - 1 ? selectedCameraIdx! + 1 : 0;
    CameraDescription selectedCamera = cameras![selectedCameraIdx!];

    _onCameraSwitched(selectedCamera);

    setState(() {
      selectedCameraIdx = selectedCameraIdx;
    });
  }

  void _onRecordButtonPressed() {
    print('aya');
    _startVideoRecording().then((String? filePath) {
      if (filePath != null) {
        Fluttertoast.showToast(
            msg: 'Recording video started',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.white);
      }
    });
  }

  void _onStopButtonPressed() {
    _stopVideoRecording().then((_) async {
      if (mounted) setState(() {});
      Fluttertoast.showToast(
          msg: 'Video recorded to $videoPath',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white);
      File temp = File(videoPath!);
      if (controller!.value.isStreamingImages) {
        await controller!.stopImageStream();
      }
      //controller!.dispose();
      await controller!.dispose();
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => UploadPage(videoFile!)))
          .then((value) {
        initialize();
      });

      await controller!.dispose();
    });
  }

  Future<String?> _startVideoRecording() async {
    print('aya');
    if (!controller!.value.isInitialized) {
      Fluttertoast.showToast(
          msg: 'Please wait',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white);

      return null;
    }

    if (controller!.value.isRecordingVideo) {
      return null;
    }

    final Directory? appDirectory = await getExternalStorageDirectory();
    final String videoDirectory = '${appDirectory!.path}/Videos';
    await Directory(videoDirectory).create(recursive: true);
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = '$videoDirectory/$currentTime.mp4';

    try {
      await controller!.startVideoRecording();
      videoPath = filePath;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    return filePath;
  }

  Future<void> _stopVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      return;
    }

    try {
      await controller!.stopVideoRecording().then((value) {
        videoFile = File(value.path);
      });
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  void _showCameraException(CameraException e) {
    String errorText = 'Error: ${e.code}\nError Message: ${e.description}';
    print(errorText);

    Fluttertoast.showToast(
        msg: 'Error: ${e.code}\n${e.description}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }
}
