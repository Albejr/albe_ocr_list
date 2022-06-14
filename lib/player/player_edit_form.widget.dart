import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/result/result_page.controller.dart';
import '/shared/database/firebase.dart';
import '/shared/models/result_item_model.dart';
import '/shared/constants/firebase_names.dart' as constants_firebase;
import '/shared/models/player_model.dart';
import '/home/components/toggle/toggle.controller.dart';
import '/home/components/toggle/toggle.widget.dart';

class PlayerEditFormWidget extends StatefulWidget {
  final String playerId;
  final String initialValuePlayer;

  const PlayerEditFormWidget(
      {Key? key, required this.playerId, required this.initialValuePlayer})
      : super(key: key);

  @override
  State<PlayerEditFormWidget> createState() => _PlayerEditFormWidgetState();
}

class _PlayerEditFormWidgetState extends State<PlayerEditFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late ResultPageController resultPageController;

  PlayerModel playerModel = PlayerModel(
      '', '', constants_firebase.undefinedList, false, null, null, null);

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();

      Database.editItem(playerModel.listType, playerModel.id, playerModel.name)
          .then((value) {
        _formKey.currentState?.reset();

        resultPageController.setSelectedTabIndex(
            ResultItemModel.getIndexByListType(playerModel.listType));

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.greenAccent, content: Text(value)));
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.deepOrange,
            content: Text(error.toString())));
      }).whenComplete(() => Navigator.of(context).pop());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.deepOrange,
          content: Text('Formulário inválido.')));
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    resultPageController = context.watch<ResultPageController>();
    final toggleController = context.watch<ToggleController>();

    playerModel = PlayerModel(
        widget.playerId,
        widget.initialValuePlayer,
        ResultItemModel.getListTypeByIndex(toggleController.selectedIndex),
        false,
        null,
        null,
        null);

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          //const Text('Tipo da lista'),
          const Padding(padding: EdgeInsets.all(8), child: ToggleWidget()),
          Padding(
              padding: const EdgeInsets.all(8),
              child: TextFormField(
                  initialValue: widget.initialValuePlayer,
                  decoration: const InputDecoration(
                      labelText: 'Nome',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.zero),
                      ),
                      prefixIcon: Icon(Icons.person),
                      errorStyle: TextStyle(color: Colors.deepOrange),
                      errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.deepOrange))),
                  maxLength: 40,
                  validator: (value) {
                    return (value == null || value.isEmpty)
                        ? 'Campo obrigatório!'
                        : null;
                  },
                  onSaved: (newValue) => {
                        playerModel = PlayerModel(
                            playerModel.id,
                            (newValue?.trim() ?? ''),
                            playerModel.listType,
                            false,
                            null,
                            playerModel.createdDate,
                            null)
                      })),
          Padding(
              padding: const EdgeInsets.all(8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: submitForm,
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                      child: Text('Salvar'),
                    )),
              ))
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
