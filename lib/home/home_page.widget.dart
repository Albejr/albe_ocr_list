import 'package:flutter/material.dart';

import '/player/player_add_form.widget.dart';
import '/result/result_page.widget.dart';

class HomePageWidget extends StatefulWidget {
  final String title;

  const HomePageWidget({Key? key, required this.title}) : super(key: key);

  @override
  State<HomePageWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePageWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/ocr');
              },
              icon: const Icon(Icons.photo_library_outlined)),
        ],
      ),
      body: const ResultPageWidget(),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.amber,
          tooltip: 'Adicionar item',
          child: const Icon(Icons.add),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text('Adicionar'),
                    content: Stack(
                      children: const <Widget>[
                        PlayerAddFormWidget(initialValuePlayer: ''),
                      ],
                    ),
                  );
                });
          }),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
