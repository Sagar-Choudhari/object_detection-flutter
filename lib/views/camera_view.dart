import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ob_detect/controller/scan_controller.dart';

class CameraView extends StatelessWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ScanController>(
        init: ScanController(),
        builder: (controller) {
          controller.setContext(context);
      return controller.isCameraInitialized.value
              ? Stack(
                  children: controller.widgetList
                )
              : const Center(child: Text("Loading preview..."));
        },
      ),
    );
  }
}
