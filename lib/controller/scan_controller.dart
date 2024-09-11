import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../views/camera_view.dart';

class ImageController extends GetxController {
  late File? image = File("");

  List<dynamic> results = [];

  RxBool isLoading = false.obs;

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      image = File(pickedFile.path);
      isLoading(true);
      update();
      _performInference();
    }
  }

  Widget pathWidget = const SizedBox.shrink();

  Future<void> _performInference() async {
    if (image == null) return;

    const url = "https://api.ultralytics.com/v1/predict/Uv9pVTr81THoytWKxp4u";
    final headers = {
      "x-api-key": "b68ef6788f6093873edf5cf821cced16c6d7859c00",
    };
    final data = {
      "imgsz": "640",
      "conf": "0.25",
      "iou": "0.45",
    };

    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers.addAll(headers)
      ..fields.addAll(data)
      ..files.add(await http.MultipartFile.fromPath('file', image!.path));

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);
      // Print JSON response
      var response0 = await jsonEncode(jsonResponse);
      var response1 = await jsonDecode(response0);

      results = await response1['images'][0]['results'];
      pathWidget = await CustomPaint(
          size: Size.infinite,
          willChange: true,
          painter: PotholePainter(
            await results,
            Size(Image.file(image!).width ?? 275, Image.file(image!).height ?? 183),
          ));
      isLoading(false);
      update();
      log("got response... $response1");
    } catch (e, s) {
      log('Error during inference: $e');
      log('Error during inference: $s');
    }
  }
}
