import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class MLService {
  static final MLService instance = MLService._internal();

  late Interpreter interpreter;

  MLService._internal();

  Future<void> initialize() async {
    interpreter = await Interpreter.fromAsset(
      'assets/mobilefacenet.tflite',
    );
  }

  List<double> predict(img.Image image) {
    final resized = img.copyResize(
      image,
      width: 112,
      height: 112,
    );

    final input = _toFloat32(resized);

    final output = List.filled(1 * 128, 0.0).reshape([1, 128]);

    interpreter.run(input.reshape([1, 112, 112, 3]), output);

    return _normalize(List<double>.from(output[0]));
  }

  Float32List _toFloat32(img.Image image) {
    final data = Float32List(112 * 112 * 3);

    int i = 0;

    for (int y = 0; y < 112; y++) {
      for (int x = 0; x < 112; x++) {
        final p = image.getPixel(x, y);

        data[i++] = (p.r - 127.5) / 128;
        data[i++] = (p.g - 127.5) / 128;
        data[i++] = (p.b - 127.5) / 128;
      }
    }

    return data;
  }

  List<double> _normalize(List<double> v) {
    double sum = 0;

    for (final x in v) {
      sum += x * x;
    }

    final norm = sqrt(sum);

    return v.map((e) => e / norm).toList();
  }

  double compare(List<double> a, List<double> b) {
    double sum = 0;

    for (int i = 0; i < a.length; i++) {
      final d = a[i] - b[i];
      sum += d * d;
    }

    return sqrt(sum);
  }

  List<double> average(List<List<double>> list) {
    final res = List<double>.filled(128, 0);

    for (final v in list) {
      for (int i = 0; i < 128; i++) {
        res[i] += v[i];
      }
    }

    for (int i = 0; i < 128; i++) {
      res[i] /= list.length;
    }

    return _normalize(res);
  }
}