import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraController controller;

  const CameraPreviewWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.previewSize?.height ?? 1,
          height: controller.value.previewSize?.width ?? 1,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}

class FaceGuide extends StatelessWidget {
  const FaceGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 260,
        height: 320,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green, width: 2),
          borderRadius: BorderRadius.circular(150),
        ),
      ),
    );
  }
}

class StorageButton extends StatelessWidget {
  final VoidCallback onTap;

  const StorageButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      right: 20,
      child: IconButton(
        icon: const Icon(Icons.storage),
        color: Colors.white,
        onPressed: onTap,
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.green),
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  final bool isRegister;
  final VoidCallback onToggleMode;
  final VoidCallback onCapture;

  const BottomBar({
    super.key,
    required this.isRegister,
    required this.onToggleMode,
    required this.onCapture,
  });

  Widget _item({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: active ? Colors.green.withOpacity(0.2) : Colors.transparent,
          border: Border.all(
            color: active ? Colors.green : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: active ? Colors.green : Colors.white54,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.green : Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 35,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _item(
              icon: Icons.search,
              label: "Scan",
              active: !isRegister,
              onTap: isRegister ? onToggleMode : null,
            ),
            const SizedBox(width: 24),
            GestureDetector(
              onTap: onCapture,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 24),
            _item(
              icon: Icons.person_add,
              label: "Add Face",
              active: isRegister,
              onTap: !isRegister ? onToggleMode : null,
            ),
          ],
        ),
      ),
    );
  }
}