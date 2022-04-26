import 'package:albe_ocr_aoe/home/components/toggle/toggle.controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/result/result_page.controller.dart';
import '/shared/models/result_item_model.dart';
import '/shared/constants/firebase_names.dart' as constants_firebase;

class ToggleWidget extends StatefulWidget {
  const ToggleWidget({Key? key}) : super(key: key);

  @override
  State<ToggleWidget> createState() => _ToggleWidgetState();
}

class _ToggleWidgetState extends State<ToggleWidget> {
  int selectedIndex = 0;
  List<bool> selectionListValues = [true, false];
  List<Color> selectionListColors = [Colors.red, Colors.green];
  List<String> selectionListLabels = [
    ResultItemModel.getTitleOfTheList(constants_firebase.blackList),
    ResultItemModel.getTitleOfTheList(constants_firebase.whiteList)
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ToggleController>();

    final resultPageController = context.watch<ResultPageController>();
    selectedIndex = resultPageController.selectedTabIndex;
    selectionListValues = [selectedIndex == 0, selectedIndex == 1];

    return Center(
      child: ToggleButtons(
        selectedColor: Colors.black,
        fillColor: selectionListColors[selectedIndex],
        selectedBorderColor: selectionListColors[selectedIndex],
        onPressed: (int index) {
          controller.setSelectedIndex(index);
          resultPageController.setSelectedTabIndex(index);

          setState(() {
            selectedIndex = index;
            for (int i = 0; i < selectionListValues.length; i++) {
              selectionListValues[i] = (i == index);
            }
          });
        },
        isSelected: selectionListValues,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(selectionListLabels[0]),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(selectionListLabels[1]),
          )
        ],
      ),
    );
  }
}
