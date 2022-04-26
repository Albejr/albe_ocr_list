import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'visionDetectorViews/text_detectorv2_view.dart';

class OcrPageWidget extends StatelessWidget {
  final PackageInfo packageInfo;

  const OcrPageWidget({
    Key? key,
    required this.packageInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: TextDetectorV2View(packageInfo: packageInfo));
  }
}
