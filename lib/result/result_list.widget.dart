import 'package:flutter/material.dart';
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

  FutureBuilder<ResultItemModel> builderFutureWidget(
      Future<ResultItemModel> futureResultItemModel) {
    return FutureBuilder(
        future: futureResultItemModel,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            ResultItemModel resultItemModel = snapshot.data as ResultItemModel;
            return Column(
                children: resultPageController.isProcessing
                    ? const [
                        SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(
                              color: Colors.deepOrange,
                            ))
                      ]
                    : builderListCard(resultItemModel));
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error.toString()}');
          } else {
            return Column(children: const [
              SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    color: Colors.deepOrange,
                  ))
            ]);
          }
        });
  }

  List<Widget> builderListCard(ResultItemModel resultItemModel) {
    return resultItemModel.players
        .map<Widget>((item) => Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.zero),
              ),
              color: resultItemModel.color,
              child: ListTile(
                  dense: true,
                  leading: Text(
                      (resultItemModel.players.indexOf(item) + 1).toString(),
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.5), fontSize: 10)),
                  trailing: Icon(Icons.touch_app,
                      color: Colors.black.withOpacity(0.3)),
                  title: Text(item.name,
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
                                  child: Text(item.name),
                                )),
                            Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                child: ListTile(
                                    leading: const Icon(Icons.edit_note),
                                    tileColor: Colors.blueAccent,
                                    title: const Text('Editar'),
                                    onTap: () =>
                                        _editItem(contextModal, item))),
                            Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                child: ListTile(
                                    leading: const Icon(
                                        Icons.drive_file_move_outlined),
                                    tileColor: Colors.amber,
                                    title: const Text('Transferir de lista'),
                                    onTap: () =>
                                        _moveItem(contextModal, item))),
                            Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                child: ListTile(
                                    leading: const Icon(Icons.delete),
                                    tileColor: Colors.pink,
                                    title: const Text('Remover'),
                                    onTap: () =>
                                        _deleteItem(contextModal, item))),
                          ]);
                        });
                  }),
            ))
        .toList();
  }

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
  Widget build(BuildContext context) {
    resultPageController = context.watch<ResultPageController>();
    return Container(
        margin: const EdgeInsets.all(9.0),
        width: MediaQuery.of(context).size.width,
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: <Widget>[
            if (widget.listType == constants_firebase.blackList)
              builderFutureWidget(ResultItemModel.getNamesBlackList())
            else if (widget.listType == constants_firebase.whiteList)
              builderFutureWidget(ResultItemModel.getNamesWhiteList())
            else
              Container()
          ],
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
