import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:image_picker/image_picker.dart';

import '../controller/scan_controller.dart';

class ImagePickerScreen extends StatefulWidget {
  const ImagePickerScreen({super.key});

  @override
  State<ImagePickerScreen> createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Picker')),
      body: GetBuilder<ImageController>(
        init: ImageController(),
        builder: (controller) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                controller.image == null
                    ? const Text('No image selected.')
                    : SizedBox(
                        height: 275,
                        child: Stack(
                          children: [
                            controller.image == null ? const SizedBox.shrink() : Image.file(controller.image!),
                            controller.isLoading.value ? const Center(child: CircularProgressIndicator()) : controller.pathWidget,
                          ],
                        ),
                      ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => controller.pickImage(ImageSource.camera),
                  child: const Text('Pick Image from Camera'),
                ),
                ElevatedButton(
                  onPressed: () => controller.pickImage(ImageSource.gallery),
                  child: const Text('Pick Image from Gallery'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PotholePainter extends CustomPainter {
  final List<dynamic> results;
  final Size imageSize;

  PotholePainter(this.results, this.imageSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    for (var result in results) {
      final segments = result['segments'];
      final x = segments['x'] as List<dynamic>;
      final y = segments['y'] as List<dynamic>;

      final path = Path();
      if (x.isNotEmpty && y.isNotEmpty) {
        path.moveTo(x[0].toDouble(), y[0].toDouble());
        for (int i = 1; i < x.length; i++) {
          path.lineTo(x[i].toDouble(), y[i].toDouble());
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
