import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:provider/provider.dart';

import '/player/player_edit_form.widget.dart';
import '/shared/database/firebase.dart';
import '/shared/models/player_model.dart';
import '/shared/models/result_item_model.dart';
import '/shared/constants/firebase_names.dart' as constants_firebase;
import 'result_page.controller.dart';

class ResultListWidget extends StatefulWidget {
  final String listType;

  const ResultListWidget(this.listType, {Key? key}) : super(key: key);

  @override
  State<ResultListWidget> createState() => _ResultListWidgetState();
}

class _ResultListWidgetState extends State<ResultListWidget> {
  late ResultPageController resultPageController;

  Future<void> _moveItem(
    BuildContext context,
    PlayerModel item,
  ) {
    resultPageController.setIsProcessing(true);
    return Database.moveItem(item.listType, item.id).then((value) {
      resultPageController.setSelectedTabIndex(
          ResultItemModel.getIndexByListType(
              ResultItemModel.getInvertedByListType(item.listType)));
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.greenAccent, content: Text(value)));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.deepOrange, content: Text(error.toString())));
    }).whenComplete(() {
      resultPageController.setIsProcessing(false);
      Navigator.of(context).pop();
    });
  }

  Future<void> _editItem(BuildContext context, PlayerModel item) {
    return showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Editar'),
            content: Stack(
              children: <Widget>[
                PlayerEditFormWidget(
                    playerId: item.id, initialValuePlayer: item.name),
              ],
            ),
          );
        }).then((value) {
      if (value != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.greenAccent, content: Text(value)));
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.deepOrange, content: Text(error.toString())));
    }).whenComplete(() => Navigator.of(context).pop());
  }

  Future<void> _deleteItem(BuildContext context, PlayerModel item) {
    resultPageController.setIsProcessing(true);
    return Database.deleteItem(item.listType, item.id).then((value) {
      resultPageController.setSelectedTabIndex(
          ResultItemModel.getIndexByListType(item.listType));
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.greenAccent, content: Text(value)));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.deepOrange, content: Text(error.toString())));
    }).whenComplete(() {
      resultPageController.setIsProcessing(false);
      Navigator.of(context).pop();
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    resultPageController = context.watch<ResultPageController>();
    return resultPageController.isProcessing
        ? Column(children: const [
            Padding(
              padding: EdgeInsets.all(15),
              child: SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  )),
            )
          ])
        : Scrollbar(
            child: PaginateFirestore(
              itemBuilderType: PaginateBuilderType.listView,
              itemBuilder: (context, documentSnapshots, index) {
                final data = documentSnapshots[index].data() as Map?;

                PlayerModel playerModel = PlayerModel(
                    documentSnapshots[index].id,
                    data![constants_firebase.playerName],
                    widget.listType,
                    false,
                    null,
                    null,
                    data['CreatedDate']);

                ResultItemModel resultItemModel =
                    ResultItemModel.getTile(widget.listType);

                return Card(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.zero),
                  ),
                  color: resultItemModel.color,
                  child: ListTile(
                      dense: true,
                      leading: Text((index + 1).toString(),
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 10)),
                      trailing:
                          const Icon(Icons.touch_app, color: Colors.black38),
                      title: Text(playerModel.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w300)),
                      onTap: () {
                        showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext contextModal) {
                              return Wrap(children: <Widget>[
                                Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Center(
                                      child: Column(children: [
                                        Text(playerModel.name,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold)),
                                        Text(documentSnapshots[index].id,
                                            style: const TextStyle(
                                                color: Colors.white38,
                                                fontSize: 8)),
                                      ]),
                                    )),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 8),
                                    child: ListTile(
                                        leading: const Icon(Icons.edit_note),
                                        tileColor: Colors.blueAccent,
                                        title: const Text('Editar'),
                                        onTap: () => _editItem(
                                            contextModal, playerModel))),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 8),
                                    child: ListTile(
                                        leading: const Icon(
                                            Icons.drive_file_move_outlined),
                                        tileColor: Colors.amber,
                                        title:
                                            const Text('Transferir de lista'),
                                        onTap: () => _moveItem(
                                            contextModal, playerModel))),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 8),
                                    child: ListTile(
                                        leading: const Icon(Icons.delete),
                                        tileColor: Colors.pink,
                                        title: const Text('Remover'),
                                        onTap: () => _deleteItem(
                                            contextModal, playerModel))),
                              ]);
                            });
                      }),
                );
              },
              query: FirebaseFirestore.instance
                  .collection(widget.listType)
                  .orderBy(constants_firebase.playerName),
              itemsPerPage: 15,
              isLive: true,
            ),
          );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
