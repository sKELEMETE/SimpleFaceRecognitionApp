import 'package:flutter/material.dart';

import 'camera_actions.dart';
import 'camera_overlays.dart';
import 'storage_page.dart';

class CameraPage extends StatefulWidget {
  final bool isRegister;
  final VoidCallback onToggleMode;

  const CameraPage({
    super.key,
    required this.isRegister,
    required this.onToggleMode,
  });

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with CameraActions {
  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    detector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          CameraPreviewWidget(controller: controller!),

          const FaceGuide(),

          StorageButton(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StoragePage()),
              );
            },
          ),

          MessageOverlay(
            message: message,
            color: messageColor,
          ),

          if (loading) const LoadingOverlay(),

          BottomBar(
            isRegister: widget.isRegister,
            onToggleMode: widget.onToggleMode,
            onCapture: capture,
          ),
        ],
      ),
    );
  }
}