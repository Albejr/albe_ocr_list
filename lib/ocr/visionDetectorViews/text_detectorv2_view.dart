import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../ocr_result.widget.dart';
import 'camera_view.dart';
import 'text_detector_painter.dart';
import '/shared/database/firebase.dart';
import '/shared/constants/firebase_names.dart' as constants_firebase;

class TextDetectorV2View extends StatefulWidget {
  final PackageInfo packageInfo;
  const TextDetectorV2View({Key? key, required this.packageInfo})
      : super(key: key);

  @override
  State<TextDetectorV2View> createState() => _TextDetectorViewV2State();
}

class _TextDetectorViewV2State extends State<TextDetectorV2View> {
  TextRecognizer textRecognizer = TextRecognizer();
  bool isBusy = false;
  CustomPaint? customPaint;
  List<String> lstRecognizedText = [];

  List<String> blackList = [];
  List<String> whiteList = [];

  @override
  void initState() {
    Database.getItems(constants_firebase.blackList)
        .then((value) => blackList = value.map((e) => e.name).toList());
    Database.getItems(constants_firebase.whiteList)
        .then((value) => whiteList = value.map((e) => e.name).toList());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: widget.packageInfo.appName,
      customPaint: customPaint,
      onImage: (inputImage) {
        processImage(inputImage).then((value) {
          if (value != null && customPaint == null) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => OcrResultWidget(
                    packageInfo: widget.packageInfo,
                    recognizedTextResult: value)));
          }
        });
      },
    );
  }

  @override
  void dispose() async {
    super.dispose();
    await textRecognizer.close();
  }

  Future<RecognizedText?> processImage(InputImage inputImage) async {
    if (isBusy) {
      return null;
    }
    isBusy = true;

    final recognizedText = await textRecognizer.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = TextDetectorPainter(
          recognizedText,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation,
          blackList,
          whiteList);
      customPaint = CustomPaint(painter: painter);
    } else {
      if (inputImage.filePath != null) {
        customPaint = null;
        //customPrint(recognizedText);
      }
    }
    isBusy = false;

    if (mounted) {
      setState(() {});
    }

    return recognizedText;
  }

  void customPrint(RecognizedText recognizedText) {
    if (kDebugMode) {
      // String text = recognizedText.text;
      // print('Text: $text');
      // print('Found: ${recognizedText.blocks.length} textBlocks');

      for (TextBlock block in recognizedText.blocks) {
        // final String blockText = block.text;
        // print('Text block: $blockText');
        for (TextLine line in block.lines) {
          final String lineText = line.text;
          print('Text block: $lineText');
          //lstRecognizedText.add(lineText);
        }
      }
    }
  }
}
