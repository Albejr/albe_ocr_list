import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/shared/models/chips_model.dart';
import '/result/result_page.controller.dart';
import '/shared/database/firebase.dart';
import '/shared/models/result_item_model.dart';
import '/shared/constants/firebase_names.dart' as constants_firebase;
import '/shared/models/player_model.dart';
import '/home/components/toggle/toggle.controller.dart';
import '/home/components/toggle/toggle.widget.dart';

class PlayerAddFormWidget extends StatefulWidget {
  final String initialValuePlayer;

  const PlayerAddFormWidget({Key? key, required this.initialValuePlayer})
      : super(key: key);

  @override
  State<PlayerAddFormWidget> createState() => _PlayerAddFormWidgetState();
}

class _PlayerAddFormWidgetState extends State<PlayerAddFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();

  late ResultPageController resultPageController;
  late List<ChipsModel> initialChipsList = getChipsByListType(playerModel.listType);

  PlayerModel playerModel =
      PlayerModel('', '', constants_firebase.undefinedList, false, null, null);

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();

      Database.addItem(
              playerModel.listType, playerModel.name, playerModel.chips)
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

  static List<ChipsModel> getChipsByListType(String listType) {
    switch (listType) {
      case constants_firebase.blackList:
        return [];
      case constants_firebase.whiteList:
        return [ChipsModel("Iniciante", false), ChipsModel("Esconde", false)];
      default:
        return [];
    }
  }

  List<Widget> buildChips() {
    List<Widget> chips = [];
    for (int i = 0; i < initialChipsList.length; i++) {
      Widget item = Padding(
        padding: const EdgeInsets.only(left: 10, right: 5),
        child: InputChip(
          label: Text(initialChipsList[i].label),
          elevation: 5.0,
          showCheckmark: false,
          disabledColor: Colors.grey,
          selectedColor: Colors.amber,
          selected: initialChipsList[i].isSelected,
          onSelected: (bool value) {
            setState(() {
              initialChipsList[i].isSelected = value;
            });
          },
          // onPressed: () {
          // setState(() {
          //   var isSelected = initialChipsList[i].isSelected;
          //   initialChipsList[i].isSelected = !isSelected;
          // });
          // },
        ),
      );
      chips.add(item);
    }
    return chips;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    resultPageController = context.watch<ResultPageController>();
    final toggleController = context.watch<ToggleController>();

    if (_name.text.isEmpty && widget.initialValuePlayer.isNotEmpty) {
      _name.text = widget.initialValuePlayer;
    }

    playerModel = PlayerModel(
        '',
        _name.text,
        ResultItemModel.getListTypeByIndex(toggleController.selectedIndex),
        false,
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
                  controller: _name,
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
                            '',
                            (newValue?.trim() ?? ''),
                            playerModel.listType,
                            false,
                            null,
                            initialChipsList
                                .where((w) => w.isSelected)
                                .map((m) => m.label)
                                .toList())
                      })),
          Padding(
              padding: const EdgeInsets.all(8),
              child: Wrap(
                direction: Axis.horizontal,
                children: buildChips(),
              )),
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
