import 'dart:io';
import 'package:alarming/classes/my_alarm_settings.dart';
import 'package:alarming/classes/smile_detections.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class SmileDetectionRingScreen extends StatefulWidget {
  final MyAlarmSettings alarmSettings;
  late final int taskRepeat;
  late final SmileDetections detections;

  SmileDetectionRingScreen({super.key, required this.alarmSettings}) {
    detections =
        SmileDetections.generate(alarmSettings.extensionSettings.difficulty);
    taskRepeat = alarmSettings.extensionSettings.taskRepeat;
  }

  @override
  State<SmileDetectionRingScreen> createState() =>
      _SmileDetectionRingScreenState();
}

class _SmileDetectionRingScreenState extends State<SmileDetectionRingScreen>
    with TickerProviderStateMixin {
  static List<CameraDescription> _cameras = [];
  late final AnimationController _progressController;
  CameraController? _camera;
  int _cameraIndex = -1;
  int _taskIndex = 0;
  bool _taskDone = false;

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
    ),
  );

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: widget.detections.keepDuration,
    );
    _progressController.addListener(() {
      setState(() {});
    });
    _progressController.addStatusListener(
      (status) {
        if (status == AnimationStatus.completed) {
          doneTask();
        }
      },
    );
    _initialize();
  }

  Future _initialize() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == CameraLensDirection.front) {
        _cameraIndex = i;
        break;
      }
    }
    if (_cameraIndex != -1) {
      _startLiveFeed();
    }
  }

  @override
  void dispose() {
    _faceDetector.close();
    _stopLiveFeed();
    _progressController.stop();
    _progressController.dispose();
    super.dispose();
  }

  Future _startLiveFeed() async {
    final camera = _cameras[_cameraIndex];
    _camera = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    await _camera?.initialize();
    _camera?.startImageStream(_processCameraImage);
    setState(() {});
  }

  Future _stopLiveFeed() async {
    await _camera?.stopImageStream();
    await _camera?.dispose();
  }

  void _processCameraImage(CameraImage image) {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;
    _processImage(inputImage);
  }

  Future<void> _processImage(InputImage inputImage) async {
    final faces = await _faceDetector.processImage(inputImage);
    if (faces.isEmpty) {
      print("[SMILE] FACE IS NOT FOUND.");
      return;
    }

    final Face face = faces.first;
    if (widget.detections.threshold < face.smilingProbability!) {
      if (_progressController.status == AnimationStatus.dismissed) {
        print("[SMILE] ACTIVATE PROGRESS CONTROLLER.");
        _progressController
          ..reset()
          ..forward();
      }
    } else if (_progressController.status == AnimationStatus.completed) {
      print(
          "[SMILE] DEACTIVATE PROGRESS CONTROLLER.${face.smilingProbability!}");
      _progressController.reset();
    }
  }

  Future doneTask() async {
    // アクション中のスヌーズアラームを一分延長
    final now = DateTime.now();
    await MyAlarm.set(
      settings: widget.alarmSettings.copyWith(
        dateTime: DateTime(
          now.year,
          now.month,
          now.day,
          now.hour,
          now.minute,
          now.second,
          0,
        ).add(
          const Duration(minutes: 1),
        ),
      ),
    );

    setState(() {
      _taskIndex = _taskIndex + 1;
    });

    if (widget.taskRepeat <= _taskIndex) {
      setState(() {
        _taskDone = true;
      });
    }
  }

  Future gotoHome(BuildContext context) async {
    if (!context.mounted) return;
    await MyAlarm.stop(widget.alarmSettings.id);
    await MyAlarm.setPeriodic(settings: widget.alarmSettings);

    if (context.mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: _liveFeedBody(context),
        ),
      ),
    );
  }

  Widget _liveFeedBody(BuildContext context) {
    if (_cameras.isEmpty) return Container();
    if (_camera == null) return Container();
    if (_camera?.value.isInitialized == false) return Container();
    if (_taskDone) {
      return ElevatedButton(
        child: const Text("終わり"),
        onPressed: () => gotoHome(context),
      );
    }

    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: CameraPreview(_camera!),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "KEEP SMILE!",
                  style: TextStyle(
                      backgroundColor: Theme.of(context).highlightColor),
                ),
                Text(
                  "$_taskIndex / ${widget.taskRepeat}",
                  style: TextStyle(
                      backgroundColor: Theme.of(context).highlightColor),
                ),
              ],
            ),
          ),
          Center(
            child: SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: _progressController.value,
              ),
            ),
          ),
        ],
      ),
    );
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_camera == null) return null;

    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_camera!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }
}
