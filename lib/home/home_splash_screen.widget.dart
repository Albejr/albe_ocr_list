import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:splashscreen/splashscreen.dart';

import 'home_page.widget.dart';

class HomeSplashScreen extends StatefulWidget {
  final PackageInfo packageInfo;
  const HomeSplashScreen({Key? key, required this.packageInfo})
      : super(key: key);

  @override
  State<HomeSplashScreen> createState() => _HomeSplashScreenState();
}

class _HomeSplashScreenState extends State<HomeSplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
        seconds: 1,
        navigateAfterSeconds: HomePageWidget(
          title: widget.packageInfo.appName,
        ),
        loadingText: Text(
          ('${widget.packageInfo.appName}\n${widget.packageInfo.version}'),
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
        imageBackground: const AssetImage('assets/images/background.jpg'),
        loaderColor: Colors.deepOrange);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
