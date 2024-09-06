import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    initCamera();
    initTFLite();
    widgetList.add(CameraPreview(cameraController));
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
  }

  late CameraController cameraController;
  late List<CameraDescription> camera;

  List<Widget> widgetList = [];

  var isCameraInitialized = false.obs;
  var isObjectDetected = false.obs;
  var cameraCount = 0;
  // var x = 0.0;
  // var y = 0.0;
  // var w = 0.0;
  // var h = 0.0;
  // var label = "";

  initCamera() async {
    if (await Permission.camera.request().isGranted) {
      camera = await availableCameras();

      cameraController = CameraController(
        camera[1],
        ResolutionPreset.max,
      );
      await cameraController.initialize().then((value) {
        cameraController.startImageStream((image) {
          cameraCount++;
          if (cameraCount % 10 == 0) {
            cameraCount = 0;
            objectDetector(image);
          }
          update();
        });
      });
      isCameraInitialized(true);
      update();
    } else {
      log("Permission denied");
    }
  }

  objectDetector(CameraImage image) async {
    var detector = await Tflite.detectObjectOnFrame(
        bytesList: image.planes.map((e) => e.bytes).toList(),
        asynch: true,
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5,
        imageStd: 127.5,
        // model: "SSDMobileNet",
        // numResultsPerClass: 1,
        // numBoxesPerBlock: 1,
        // numResults: 1,
        rotation: 90,
        threshold: 0.4);
    if (detector != null) {
      // var detectedObject = detector.first;
      // if (detectedObject['confidenceInClass'] * 100 > 45) {
      isObjectDetected(true);
      log("Result is ==> $detector");
      // var label = detectedObject['detectedClass'].toString();
      // var h = detectedObject['rect']['h'];
      // var w = detectedObject['rect']['w'];
      // var x = detectedObject['rect']['x'];
      // var y = detectedObject['rect']['y'];
      // addWidget(label,h,w,x,y);
widgetList.clear();
      widgetList.add(CameraPreview(cameraController));
      for (var i in detector) {
        var detectedObject = i;
        if (detectedObject['confidenceInClass'] * 100 > 45) {
          var label = detectedObject['detectedClass'].toString();
          var h = detectedObject['rect']['h'];
          var w = detectedObject['rect']['w'];
          var x = detectedObject['rect']['x'];
          var y = detectedObject['rect']['y'];
          addWidget(label, h, w, x, y);
        }
      }
      // }else{isObjectDetected(false);}
      update();
    }
  }

  initTFLite() async {
    await Tflite.loadModel(
      // model: "assets/mobilenet_v1_1.0_224.tflite",
      // labels: "assets/mobilenet_v1_1.0_224.txt",

      model: "assets/ssd_mobilenet.tflite",
      labels: "assets/ssd_mobilenet.txt",

      // model: "assets/deeplabv3_257_mv_gpu.tflite",
      // labels: "assets/deeplabv3_257_mv_gpu.txt",

      // model: "assets/yolov2_tiny.tflite",
      // labels: "assets/yolov2_tiny.txt",

      isAsset: true,
      numThreads: 1,
      useGpuDelegate: false,
    );
  }

  late BuildContext context;
  setContext(BuildContext context){
    this.context = context;
    update();
  }

  addWidget(label, h, w, x, y) {
    widgetList.add(Positioned(
      top: (y * 700),
      left: (x * 500),
      child: Container(
        width: (w * 100) * context.width / 100,
        height: (h * 100) * context.height / 100,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: Colors.green,
            width: 4.0,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Colors.white,
              child: Text(label),
            ),
          ],
        ),
      ),
    ));
  }
}
