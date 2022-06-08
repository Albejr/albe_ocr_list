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
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
        ),
        //imageBackground: const AssetImage('assets/images/background.jpg'),
        gradientBackground: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color.fromRGBO(243, 150, 154, 1),
            Color.fromRGBO(120, 194, 173, 1),
          ],
        ),
        loaderColor: Colors.white);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
