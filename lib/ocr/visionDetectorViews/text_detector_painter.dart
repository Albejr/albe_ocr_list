import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '/shared/constants/firebase_names.dart' as constants_firebase;
import '/shared/models/player_model.dart';
import 'coordinates_translator.dart';

class TextDetectorPainter extends CustomPainter {
  TextDetectorPainter(this.recognizedText, this.absoluteImageSize,
      this.rotation, this.blackList, this.whiteList);

  final RecognizedText recognizedText;
  final Size absoluteImageSize;
  final InputImageRotation rotation;

  final List<String> blackList;
  final List<String> whiteList;

  late PlayerModel playerModel;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.transparent; //Colors.black

    Paint background;

    for (final textBlock in recognizedText.blocks) {
      for (final textLine in textBlock.lines) {
        playerModel = getPlayerModelByText(textLine.text);
        if (playerModel.isMatchText) {
          background = Paint()..color = playerModel.color ?? Colors.black;

          final ParagraphBuilder builder = ParagraphBuilder(
            ParagraphStyle(
                textAlign: TextAlign.left,
                fontSize: 20,
                textDirection: TextDirection.ltr),
          );
          builder.pushStyle(
              ui.TextStyle(color: Colors.black, background: background));
          builder.addText(textLine.text);
          builder.pop();

          final left = translateX(
              textLine.boundingBox.left, rotation, size, absoluteImageSize);
          final top = translateY(
              textLine.boundingBox.top, rotation, size, absoluteImageSize);
          final right = translateX(
              textLine.boundingBox.right, rotation, size, absoluteImageSize);
          final bottom = translateY(
              textLine.boundingBox.bottom, rotation, size, absoluteImageSize);

          canvas.drawRect(
            Rect.fromLTRB(left, top, right, bottom),
            paint,
          );

          canvas.drawParagraph(
            builder.build()
              ..layout(ParagraphConstraints(
                width: right - left,
              )),
            Offset(left, top),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(TextDetectorPainter oldDelegate) {
    return oldDelegate.recognizedText != recognizedText;
  }

  PlayerModel getPlayerModelByText(String textVal) {
    if (blackList.any((element) => isMatchCustom(element, textVal))) {
      return PlayerModel('', textVal, constants_firebase.blackList, true,
          Colors.red, null, null);
    } else if (whiteList.any((element) => isMatchCustom(element, textVal))) {
      return PlayerModel('', textVal, constants_firebase.whiteList, true,
          Colors.green, null, null);
    } else {
      return PlayerModel('', textVal, constants_firebase.undefinedList, false,
          Colors.transparent, null, null);
    }
  }

  bool isMatchCustom(String text1, String text2) {
    return replaceUnidentifiedCharacters(text1) ==
        replaceUnidentifiedCharacters(text2);
  }

  String replaceUnidentifiedCharacters(String textValue) {
    String identifiedBase = '';
    textValue = textValue
        .replaceAll(String.fromCharCode(39), identifiedBase) //'
        .replaceAll(String.fromCharCode(96), identifiedBase) //`
        .replaceAll(String.fromCharCode(180), identifiedBase) //´
        .replaceAll(' ', identifiedBase)
        .replaceAll(';', identifiedBase)
        .replaceAll('!', identifiedBase)
        .replaceAll('"', identifiedBase)
        .replaceAll('.', identifiedBase)
        .replaceAll('_', identifiedBase)
        .replaceAll('-', identifiedBase)
        .replaceAll('=', identifiedBase)
        .replaceAll('[', identifiedBase)
        .replaceAll(']', identifiedBase);
    return textValue.toLowerCase();
  }
}
