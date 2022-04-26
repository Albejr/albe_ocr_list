import 'package:flutter/foundation.dart';

class ToggleController extends ChangeNotifier {
  int selectedIndex = 0;

  setSelectedIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}
