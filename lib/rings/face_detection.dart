import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionRingScreen extends StatefulWidget {
  const FaceDetectionRingScreen({super.key});

  @override
  State<FaceDetectionRingScreen> createState() =>
      _FaceDetectionRingScreenState();
}

class _FaceDetectionRingScreenState extends State<FaceDetectionRingScreen> {
  final FaceDetector _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
    enableLandmarks: true,
  ));

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("カメラを起動して顔をとらえるところまでできたらOK"),
          ],
        ),
      ),
    );
  }
}
