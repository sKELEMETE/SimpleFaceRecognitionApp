import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';

import 'db_service.dart';
import 'ml_service.dart';

mixin CameraActions<T extends StatefulWidget> on State<T> {
  CameraController? controller;

  bool loading = false;
  String message = '';
  Color messageColor = Colors.transparent;

  final detector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  Future<void> initCamera() async {
    final perm = await Permission.camera.request();
    if (!perm.isGranted) return;

    final cams = await availableCameras();
    final back = cams.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
    );

    controller = CameraController(
      back,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await controller!.initialize();
    setState(() {});
  }

  void showMessage(String text, Color color) {
    setState(() {
      message = text;
      messageColor = color;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        message = '';
        messageColor = Colors.transparent;
      });
    });
  }

  Future<void> capture() async {
    if (loading || controller == null) return;

    setState(() => loading = true);

    try {
      final embeddings = <List<double>>[];

      for (int i = 0; i < 5; i++) {
        final file = await controller!.takePicture();

        final input = InputImage.fromFilePath(file.path);
        final faces = await detector.processImage(input);

        if (faces.isEmpty) {
          showMessage('Try Again!', Colors.red);
          setState(() => loading = false);
          return;
        }

        final bytes = await file.readAsBytes();
        final image = img.decodeImage(bytes)!;

        final rect = faces.first.boundingBox;

        final cropped = img.copyCrop(
          image,
          x: rect.left.toInt(),
          y: rect.top.toInt(),
          width: rect.width.toInt(),
          height: rect.height.toInt(),
        );

        final emb = MLService.instance.predict(cropped);
        embeddings.add(emb);
      }

      final avg = MLService.instance.average(embeddings);

      if ((widget as dynamic).isRegister) {
        await saveFace(avg);
      } else {
        await recognize(avg);
      }
    } catch (_) {
      showMessage('Error! Try Again!', Colors.red);
    }

    setState(() => loading = false);
  }

  Future<void> saveFace(List<double> emb) async {
    final c = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Name'),
        content: TextField(controller: c),
        actions: [
          TextButton(
            onPressed: () async {
              await DBService.instance.insert(c.text, emb);
              Navigator.pop(context);
              showMessage('Saved: ${c.text}', Colors.green);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> recognize(List<double> emb) async {
    final users = await DBService.instance.fetchAll();

    double min = 999;
    String name = 'Unknown';

    for (final u in users) {
      final stored = List<double>.from(jsonDecode(u['embedding']));
      final d = MLService.instance.compare(emb, stored);

      if (d < min) {
        min = d;
        name = u['name'];
      }
    }

    if (min < 0.85) {
      showMessage("It's $name", Colors.green);
    } else {
      showMessage('Try Again!', Colors.red);
    }
  }
}