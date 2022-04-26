import 'package:flutter/foundation.dart';

class ResultPageController extends ChangeNotifier {
  int selectedTabIndex = 0;
  bool isProcessing = false;

  setSelectedTabIndex(int index) {
    selectedTabIndex = index;
    notifyListeners();
  }

  setIsProcessing(bool value) {
    isProcessing = value;
    notifyListeners();
  }
}
