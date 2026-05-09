import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';

import 'db_service.dart';
import 'ml_service.dart';

mixin CameraActions<T extends StatefulWidget> on State<T> {
  CameraController? controller;

  bool loading = false;

  bool showResult = false;
  String resultText = '';
  bool isQrResult = false;
  bool isError = false;

  final FaceDetector detector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  final BarcodeScanner barcodeScanner = BarcodeScanner();

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

  void showResultScreen({
    required String text,
    required bool qr,
    required bool error,
  }) {
    setState(() {
      showResult = true;
      resultText = text;
      isQrResult = qr;
      isError = error;
    });
  }

  void closeResult() {
    setState(() {
      showResult = false;
      resultText = '';
      isQrResult = false;
      isError = false;
    });
  }

  void showTempError(String text) {
    setState(() {
      showResult = true;
      resultText = text;
      isQrResult = false;
      isError = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) closeResult();
    });
  }

  Future<void> capture() async {
    if (loading || controller == null) return;

    setState(() => loading = true);

    try {
      final file = await controller!.takePicture();
      final input = InputImage.fromFilePath(file.path);

      final faces = await detector.processImage(input);

      if (faces.isNotEmpty) {
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

        if ((widget as dynamic).isRegister) {
          await saveFace(emb);
        } else {
          final name = await _recognizeName(emb);

          if (name == 'Unknown') {
            showTempError('Try Again!');
          } else {
            showResultScreen(
              text: "Face: $name",
              qr: false,
              error: false,
            );
          }
        }

        setState(() => loading = false);
        return;
      }

      final qr = await _scanQr(file.path);

      if (qr.isNotEmpty) {
        showResultScreen(
          text: "QR: $qr",
          qr: true,
          error: false,
        );
      } else {
        showTempError('Try Again!');
      }
    } catch (_) {
      showTempError('Try Again!');
    }

    setState(() => loading = false);
  }

  Future<String> _scanQr(String path) async {
    final input = InputImage.fromFilePath(path);
    final barcodes = await barcodeScanner.processImage(input);

    if (barcodes.isEmpty) return '';
    return barcodes.first.rawValue ?? '';
  }

  Future<String> _recognizeName(List<double> emb) async {
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

    if (min < 0.85) return name;
    return 'Unknown';
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
              showResultScreen(
                text: "Saved: ${c.text}",
                qr: false,
                error: false,
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    detector.close();
    barcodeScanner.close();
    controller?.dispose();
    super.dispose();
  }
}