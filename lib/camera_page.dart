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
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: !showResult,
      onPopInvoked: (didPop) {
        if (showResult) closeResult();
      },
      child: Scaffold(
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

            if (loading) const LoadingOverlay(),

            if (showResult)
              Material(
                color: Colors.black.withOpacity(0.88),
                child: Center(
                  child: Container(
                    width: 340,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121212),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isError
                            ? Colors.redAccent
                            : (isQrResult
                                ? Colors.blueAccent
                                : Colors.greenAccent),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isError
                              ? Icons.error
                              : (isQrResult
                                  ? Icons.qr_code_2
                                  : Icons.verified),
                          size: 52,
                          color: isError
                              ? Colors.redAccent
                              : (isQrResult
                                  ? Colors.blueAccent
                                  : Colors.greenAccent),
                        ),

                        const SizedBox(height: 14),

                        Text(
                          resultText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 22),

                        GestureDetector(
                          onTap: closeResult,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 26,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isError
                                  ? Colors.redAccent
                                  : (isQrResult
                                      ? Colors.blueAccent
                                      : Colors.greenAccent),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              "CLOSE",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            BottomBar(
              isRegister: widget.isRegister,
              onToggleMode: widget.onToggleMode,
              onCapture: capture,
            ),
          ],
        ),
      ),
    );
  }
}