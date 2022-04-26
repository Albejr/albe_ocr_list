import 'package:albe_ocr_aoe/shared/models/player_model.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '/player/player_add_form.widget.dart';
import '/shared/models/result_item_model.dart';
import '/shared/constants/firebase_names.dart' as constants_firebase;

class OcrResultWidget extends StatelessWidget {
  final PackageInfo packageInfo;
  final RecognizedText? recognizedTextResult;

  const OcrResultWidget({
    Key? key,
    required this.packageInfo,
    required this.recognizedTextResult,
  }) : super(key: key);

  List<String> result() {
    List<String> lstRecognizedText = [];
    if (recognizedTextResult != null) {
      for (TextBlock block in recognizedTextResult!.blocks) {
        for (TextLine line in block.lines) {
          final String lineText = line.text;
          lstRecognizedText.add(lineText.toLowerCase());
        }
      }
    }
    return lstRecognizedText;
  }

  Future<List<ResultItemModel>> getFutureResultItemModelByDataBase() async {
    List<String> recognizedListResult = result();

    ResultItemModel b = await ResultItemModel.getNamesBlackList();
    b = ResultItemModel(
        color: b.color,
        icon: b.icon,
        showIcon: false,
        listTypeAlias: b.listTypeAlias,
        players: b.players
            .where((element) =>
                recognizedListResult.contains(element.name.toLowerCase()))
            .toList());

    ResultItemModel w = await ResultItemModel.getNamesWhiteList();
    w = ResultItemModel(
        color: w.color,
        icon: w.icon,
        showIcon: false,
        listTypeAlias: w.listTypeAlias,
        players: w.players
            .where((element) =>
                recognizedListResult.contains(element.name.toLowerCase()))
            .toList());

    List<String> bLower =
        b.players.map((val) => val.name.toLowerCase()).toList();
    List<String> wLower =
        w.players.map((val) => val.name.toLowerCase()).toList();

    List<String> undefinedListType = [];
    for (var element in recognizedListResult) {
      String e = element.toLowerCase();

      if ((bLower.contains(e) == false) &&
          (wLower.contains(e) == false) &&
          undefinedListType.contains(e) == false) {
        undefinedListType.add(element);
      }
    }

    ResultItemModel u = ResultItemModel(
        listTypeAlias:
            ResultItemModel.getTitleOfTheList(constants_firebase.undefinedList),
        color: const Color.fromRGBO(5, 137, 245, 0.7),
        icon: const Icon(Icons.touch_app, color: Colors.white),
        showIcon: true,
        players: undefinedListType
            .map((e) => PlayerModel(
                '', e, constants_firebase.undefinedList, false, null))
            .toList());

    // b.players.sort();
    // w.players.sort();
    // u.players.sort();

    return <ResultItemModel>[b, w, u];
  }

  List<Widget> builderListCard(
      BuildContext context, List<ResultItemModel> resultItemModelList) {
    return resultItemModelList
        .map<Widget>((item) => Column(children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  item.listTypeAlias,
                  style:
                      TextStyle(fontSize: 20, color: item.color.withOpacity(1)),
                ),
              ),
              Card(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.zero),
                ),
                //color: item.color,
                child: item.players.isNotEmpty
                    ? Column(
                        children: item.players
                            .map<Widget>((player) => ListTile(
                                tileColor: item.color,
                                dense: true,
                                trailing: item.showIcon
                                    ? Icon(
                                        item.icon.icon,
                                        color: Colors.black.withOpacity(0.3),
                                      )
                                    : const SizedBox.shrink(),
                                title: Text(player.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w300)),
                                onTap: () {
                                  if (item.listTypeAlias ==
                                      ResultItemModel.getTitleOfTheList(
                                          constants_firebase.undefinedList)) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext dialogContext) {
                                          return AlertDialog(
                                            title: const Text('Adicionar'),
                                            content: Stack(
                                              children: <Widget>[
                                                PlayerAddFormWidget(
                                                    initialValuePlayer:
                                                        player.name),
                                              ],
                                            ),
                                          );
                                        });
                                  }
                                }))
                            .toList())
                    : const ListTile(
                        //tileColor: item.color,
                        dense: true,
                        title: Center(
                            child: Text('Nenhum item identificado.',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w300)))),
              )
            ]))
        .toList();
  }

  FutureBuilder<List<ResultItemModel>> builderFutureWidget() {
    return FutureBuilder(
        future: getFutureResultItemModelByDataBase(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<ResultItemModel> resultItemModelList =
                snapshot.data as List<ResultItemModel>;
            return Column(
                children: builderListCard(context, resultItemModelList));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(packageInfo.appName),
        ),
        body: Container(
            margin: const EdgeInsets.all(9.0),
            width: MediaQuery.of(context).size.width,
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              children: <Widget>[builderFutureWidget()],
            )));
  }
}
