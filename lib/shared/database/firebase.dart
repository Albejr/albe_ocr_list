import 'package:albe_ocr_list/shared/models/result_item_model.dart';
import 'package:albe_ocr_list/shared/utils/generate_index_search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/player_model.dart';
import '/shared/constants/firebase_names.dart' as constants_firebase;

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class DatabaseFirebaseFirestore {
  // the stream that provides all our data from the firestore database with real time changes
  static Stream<QuerySnapshot> get allBlackList => _firestore
      .collection(constants_firebase.blackList)
      //.orderBy(constants_firebase.playerName)
      .snapshots();

  static Stream<QuerySnapshot> get allWhiteList => _firestore
      .collection(constants_firebase.whiteList)
      //.orderBy(constants_firebase.playerName)
      .snapshots();

  static Future<List<PlayerModel>> getItems(String coolectionPath) async {
    // Get docs from collection reference
    QuerySnapshot querySnapshot =
        await _firestore.collection(coolectionPath).get();
    // Get data from docs and convert map to List
    //final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    // for a specific field
    final allData = querySnapshot.docs
        .map((doc) => PlayerModel(
            doc.id,
            doc.get(constants_firebase.playerName).toString().trim(),
            coolectionPath,
            false,
            null,
            doc.get('CreatedDate'),
            null))
        .where((element) => element.name.trim().isNotEmpty)
        .toList();

    allData
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    //debugPrint(allData.map((e) => e).join(' - '));
    return allData;
  }

  static Future<bool> checkNameAlreadyExist(
      String coolectionPath, String name) async {
    final QuerySnapshot result = await _firestore
        .collection(coolectionPath)
        .where(constants_firebase.playerName, isEqualTo: name)
        .limit(1)
        .get();
    return result.size > 0;
  }

  static Future<String> addItem(String coolectionPath, String value) async {
    return await checkNameAlreadyExist(coolectionPath, value).then(
        (isAlreadyExist) => (isAlreadyExist)
            ? Future.error('Item já exite nesta lista.')
            : checkNameAlreadyExist(
                    ResultItemModel.getInvertedByListType(coolectionPath),
                    value)
                .then((isAlreadyExist) => (isAlreadyExist)
                    ? Future.error('Item já exite em outra lista.')
                    : _firestore
                        .collection(coolectionPath)
                        .add({
                          constants_firebase.playerName: value,
                          'OriginalSource': coolectionPath,
                          'Platform ': defaultTargetPlatform.name,
                          'CreatedDate': DateTime.now(),
                          constants_firebase.indexSearch: GenerateIndexSearch.create(value)
                        })
                        .then((response) => '$value foi adicionado.')
                        .catchError(
                            (error) => throw 'Falha ao adicionar:\n $error')));
  }

  static Future<String> editItem(
      String coolectionPath, String id, String value) async {
    String listName = ResultItemModel.getTitleOfTheList(coolectionPath);
    await checkNameAlreadyExist(coolectionPath, value).then((isAlreadyExist) {
      if (isAlreadyExist) {
        Future.error('Item já exite na lista $listName!');
      } else {
        checkNameAlreadyExist(
                ResultItemModel.getInvertedByListType(coolectionPath), value)
            .then((isAlreadyExist) {
          if (isAlreadyExist) {
            listName = ResultItemModel.getTitleOfTheList(
                ResultItemModel.getInvertedByListType(coolectionPath));
            Future.error('Item já exite na lista $listName!');
          } else {
            _firestore
                .collection(coolectionPath)
                .doc(id)
                .set({
                  constants_firebase.playerName: value,
                  'CreatedDate': DateTime.now(),
                  constants_firebase.indexSearch: GenerateIndexSearch.create(value)
                })
                .then((response) => '$value foi modificado.')
                .catchError((error) => throw 'Falha ao editar:\n $error');
          }
        });
      }
    });

    return '';
  }

  static Future<String> deleteItem(String coolectionPath, String id) async {
    var doc = await _firestore.collection(coolectionPath).doc(id).get();
    if (doc.exists == false) {
      return Future.error('Item não encontrado.');
    }

    Map<String, dynamic> data = doc.data()!;
    String name = data[constants_firebase.playerName];

    return await _firestore
        .collection(coolectionPath)
        .doc(id)
        .delete()
        .then((response) => '$name foi removido.')
        .catchError((error) => throw 'Falha ao remover:\n $error');
  }

  static Future<String> moveItem(String coolectionPath, String id) async {
    String targetCoolectionPath =
        (coolectionPath != constants_firebase.blackList)
            ? constants_firebase.blackList
            : constants_firebase.whiteList;

    var doc = await _firestore.collection(coolectionPath).doc(id).get();
    if (doc.exists == false) {
      return Future.error('Item não encontrado.');
    }

    Map<String, dynamic> data = doc.data()!;
    String name = data[constants_firebase.playerName];
    bool alreadyExistName =
        await checkNameAlreadyExist(targetCoolectionPath, name);

    if (alreadyExistName) {
      return Future.error('Item já existe no destino.');
    }

    return _firestore
        .collection(targetCoolectionPath)
        .add({
          constants_firebase.playerName: data[constants_firebase.playerName],
          'OriginalSource': data['OriginalSource'] ?? coolectionPath,
          'Platform ': data['Platform'] ?? defaultTargetPlatform.name,
          'CreatedDate': DateTime.now(),
          constants_firebase.indexSearch:
              GenerateIndexSearch.create(data[constants_firebase.playerName])
        })
        .then((response) => _firestore
            .collection(coolectionPath)
            .doc(id)
            .delete()
            .then((response2) => Future.value('$name foi transferido.'))
            .catchError((error2) => throw 'Falha ao transferir:\n $error2'))
        .catchError((error) => throw 'Falha ao adicionar no destino:\n $error');
  }
}
