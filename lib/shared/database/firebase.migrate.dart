import 'package:albe_ocr_list/shared/utils/generate_index_search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '/shared/constants/firebase_names.dart' as constants_firebase;

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class DatabaseFirebaseFirestoreMigrate {
  //DatabaseFirebaseFirestoreMigrate.updateAllIndexSearchbyName(constants_firebase.blackList);
  static Future<void> updateAllIndexSearchbyName(String coolectionPath) async {
    _firestore
        .collection(coolectionPath)
        .orderBy(constants_firebase.playerName)
        .get()
        .then((querySnapshot) {
      int idxItem = 0;
      for (var item in querySnapshot.docs) {
        idxItem++;
        String name = item.get(constants_firebase.playerName);

        debugPrint('${idxItem.toString()} $name');
        //debugPrint(GenerateIndexSearch.create(name).join("|"));

        _firestore
            .collection(coolectionPath)
            .doc(item.id)
            .update({'IndexSearch': GenerateIndexSearch.create(name)});
      }
    });
  }

  //DatabaseFirebaseFirestoreMigrate.updateAllNameByIndexSearch(constants_firebase.blackList);
  static Future<void> updateAllNameByIndexSearch(String coolectionPath) async {
    _firestore
        .collection(coolectionPath)
        .orderBy(constants_firebase.playerName)
        .get()
        .then((querySnapshot) {
      int idxItem = 0;
      for (var item in querySnapshot.docs) {
        idxItem++;
        Map<String, dynamic> data = item.data();

        if (data['IndexSearch'] != null) {
          List<String> lstNames = [];
          for (var idx in data['IndexSearch']) {
            lstNames.add(idx);
          }

          if (lstNames.isNotEmpty) {
            List<String> lstNewName = [];
            for (var i = 0; i < lstNames.length; i++) {
              int nextIndex = (i + 1);
              if (nextIndex < lstNames.length &&
                  lstNames[i].length > lstNames[nextIndex].length) {
                lstNewName.add(lstNames[i]);
              }
            }

            String name = lstNames.last;
            if (lstNewName.isNotEmpty) {
              if (lstNewName.last != lstNames.last) {
                lstNewName.add(lstNames.last);
              }
              name = lstNewName.join(" ");
            }

            debugPrint('${idxItem.toString()} $name');

            _firestore
                .collection(coolectionPath)
                .doc(item.id)
                .update({constants_firebase.playerName: name});
          }
        }
      }
    });
  }
}
