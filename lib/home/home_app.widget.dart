import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'components/toggle/toggle.controller.dart';
import 'home_splash_screen.widget.dart';
import 'home_page.widget.dart';
import '/ocr/ocr_result.widget.dart';
import '/ocr/ocr_page.widget.dart';
import '/result/result_page.controller.dart';

class HomeAppWidget extends StatelessWidget {
  final PackageInfo packageInfo;

  const HomeAppWidget({Key? key, required this.packageInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ToggleController()),
        ChangeNotifierProvider(create: (_) => ResultPageController()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white70
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.amber,
          scaffoldBackgroundColor: Colors.black87
        ),
        themeMode: ThemeMode.dark,
        initialRoute: '/',
        routes: {
          '/': (context) => HomeSplashScreen(packageInfo: packageInfo),
          '/home': (context) => HomePageWidget(
                title: packageInfo.appName,
              ),
          '/ocr': (context) => OcrPageWidget(packageInfo: packageInfo),
          '/result': (context) => OcrResultWidget(
                packageInfo: packageInfo,
                recognizedTextResult: null,
              )
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
