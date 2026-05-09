import 'package:flutter/material.dart';

import 'camera_page.dart';
import 'db_service.dart';
import 'ml_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DBService.instance.database;
  await MLService.instance.initialize();

  runApp(const FaceApp());
}

class FaceApp extends StatelessWidget {
  const FaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const CameraHome(),
    );
  }
}

class CameraHome extends StatefulWidget {
  const CameraHome({super.key});

  @override
  State<CameraHome> createState() => _CameraHomeState();
}

class _CameraHomeState extends State<CameraHome> {
  bool isRegister = false;

  void toggleMode() {
    setState(() {
      isRegister = !isRegister;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CameraPage(
      isRegister: isRegister,
      onToggleMode: toggleMode,
    );
  }
}