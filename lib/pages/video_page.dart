import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
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

class _VideoRecorderState extends State<VideoRecorder>
    with WidgetsBindingObserver {
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
    WidgetsBinding.instance!.addObserver(this);
    initialize();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    controller!.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height - MediaQuery.of(context).padding.top;
    final deviceRatio = size.width / height;

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
                        alignment: Alignment.centerRight,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50.0)),
                            onTap: () {
                              _isrecording ? null : _selectImage();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.asset(
                                'assets/gallery_button.png',
                                color: Colors.grey[200],
                                width: 42.0,
                                height: 42.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Material(
                          color: Colors.transparent,
                          child: GestureDetector(
                            child: Container(
                                padding: const EdgeInsets.all(4.0),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 800),
                                  transitionBuilder: (widget, animation) =>
                                      ScaleTransition(
                                    scale: animation,
                                    child: widget,
                                  ),
                                  switchInCurve: Curves.easeInExpo,
                                  switchOutCurve: Curves.easeOutExpo,
                                  child: _isrecording
                                      ? Image.asset(
                                          'assets/shutter2.png',
                                          key: UniqueKey(),
                                          width: 72.0,
                                          height: 72.0,
                                        )
                                      : Image.asset(
                                          'assets/shutter.png',
                                          key: UniqueKey(),
                                          width: 72.0,
                                          height: 72.0,
                                        ),
                                )),
                            onTap: () {
                              setState(() {
                                _isrecording = !_isrecording;
                              });
                              if (_isrecording) {
                                controller != null &&
                                        controller!.value.isInitialized &&
                                        !controller!.value.isRecordingVideo
                                    ? _onRecordButtonPressed()
                                    : null;
                              } else {
                                controller != null &&
                                        controller!.value.isInitialized &&
                                        controller!.value.isRecordingVideo
                                    ? _onStopButtonPressed()
                                    : null;
                              }
                            },
                          ),
                        ),
                      ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(50.0)),
        onTap: _isrecording ? null : _onSwitchCamera,
        child: Container(
          padding: const EdgeInsets.all(4.0),
          child: Image.asset(
            'assets/switch_camera.png',
            color: Colors.grey[200],
            width: 42.0,
            height: 42.0,
          ),
        ),
      ),
    );
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<void> _onCameraSwitched(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller!.dispose();
    }

    controller = CameraController(cameraDescription, ResolutionPreset.veryHigh);

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
    await controller!.dispose();
    XFile? imageFile = await imagePicker.pickVideo(
      source: ImageSource.gallery,
    );
    if (imageFile != null) {
      file = File(imageFile.path);
      Navigator.of(context)
          .push(MaterialPageRoute(
              builder: (context) => UploadPage(file!, file!.path)))
          .then((value) {
        initialize();
      });
    } else {
      initialize();
    }
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
      if (controller!.value.isStreamingImages) {
        await controller!.stopImageStream();
      }
      await controller!.dispose();
      Navigator.of(context)
          .push(MaterialPageRoute(
              builder: (context) => UploadPage(videoFile!, videoPath!)))
          .then((value) {
        initialize();
      });
    });
  }

  Future<String?> _startVideoRecording() async {
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
        videoFile!.rename(videoPath!);
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
