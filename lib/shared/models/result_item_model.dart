import 'package:albe_ocr_list/shared/models/player_model.dart';
import 'package:flutter/material.dart';

import '/shared/database/firebase.dart';
import '/shared/constants/firebase_names.dart' as constants_firebase;

class ResultItemModel {
  List<PlayerModel> players;
  Icon icon;
  bool showIcon;
  Color color;
  String listTypeAlias;

  ResultItemModel(
      {required this.players,
      required this.icon,
      required this.showIcon,
      required this.color,
      required this.listTypeAlias});

  static Future<ResultItemModel> getNames(String collectionPath) async {
    Color color;
    Icon icon;

    switch (collectionPath) {
      case constants_firebase.blackList:
        color = const Color.fromRGBO(243, 150, 154, 0.7);
        icon = const Icon(Icons.block_flipped, color: Colors.white);
        break;
      case constants_firebase.whiteList:
        color = const Color.fromRGBO(120, 194, 173, 0.7);
        icon = const Icon(Icons.task_alt, color: Colors.white);
        break;
      default:
        color = Colors.blueGrey;
        icon = const Icon(Icons.question_mark, color: Colors.white);
        break;
    }

    return ResultItemModel(
        listTypeAlias: getTitleOfTheList(collectionPath),
        color: color,
        showIcon: true,
        icon: icon,
        players: await DatabaseFirebaseFirestore.getItems(collectionPath));
  }

  static ResultItemModel getTile(String collectionPath) {
    Color color;
    Icon icon;

    switch (collectionPath) {
      case constants_firebase.blackList:
        color = const Color.fromRGBO(243, 150, 154, 0.7);
        icon = const Icon(Icons.block_flipped, color: Colors.white);
        break;
      case constants_firebase.whiteList:
        color = const Color.fromRGBO(120, 194, 173, 0.7);
        icon = const Icon(Icons.task_alt, color: Colors.white);
        break;
      default:
        color = Colors.blueGrey;
        icon = const Icon(Icons.question_mark, color: Colors.white);
        break;
    }

    return ResultItemModel(
        listTypeAlias: getTitleOfTheList(collectionPath),
        color: color,
        showIcon: true,
        icon: icon,
        players: []);
  }

  static String getTitleOfTheList(String listType) {
    switch (listType) {
      case constants_firebase.blackList:
        return 'Avançado';
      case constants_firebase.whiteList:
        return 'Normal';
      default:
        return 'Indefinido';
    }
  }

  static String getListTypeByIndex(int index) {
    switch (index) {
      case 0:
        return constants_firebase.blackList;
      case 1:
        return constants_firebase.whiteList;
      default:
        return constants_firebase.undefinedList;
    }
  }

  static int getIndexByListType(String listType) {
    switch (listType) {
      case constants_firebase.blackList:
        return 0;
      case constants_firebase.whiteList:
        return 1;
      default:
        return -1;
    }
  }

  static String getInvertedByListType(String listType) {
    switch (listType) {
      case constants_firebase.blackList:
        return constants_firebase.whiteList;
      case constants_firebase.whiteList:
        return constants_firebase.blackList;
      default:
        return constants_firebase.undefinedList;
    }
  }
}
