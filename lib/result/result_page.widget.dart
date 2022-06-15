import 'package:albe_ocr_list/shared/database/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/home/components/toggle/toggle.controller.dart';
import '/shared/models/result_item_model.dart';
import '/shared/constants/firebase_names.dart' as constants_firebase;
import 'result_page.controller.dart';
import 'result_list.widget.dart';

class ResultPageWidget extends StatefulWidget {
  const ResultPageWidget({Key? key}) : super(key: key);

  @override
  State<ResultPageWidget> createState() => _ResultPageWidgetState();
}

class _ResultPageWidgetState extends State<ResultPageWidget>
    with SingleTickerProviderStateMixin {
  final List<Tab> listTabs = <Tab>[
    Tab(
        child: Column(children: <Widget>[
      Text(ResultItemModel.getTitleOfTheList(constants_firebase.blackList)),
      Padding(
          padding: const EdgeInsets.only(top: 5),
          child: StreamBuilder<QuerySnapshot>(
              stream: DatabaseFirebaseFirestore
                  .allBlackList, // a previously-obtained Future<String> or null
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                return Text(
                  (snapshot.data?.docs.length.toString() ?? '-'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w200, fontSize: 12),
                );
              }))
    ])),
    Tab(
        child: Column(children: <Widget>[
      Text(ResultItemModel.getTitleOfTheList(constants_firebase.whiteList)),
      Padding(
          padding: const EdgeInsets.only(top: 5),
          child: StreamBuilder<QuerySnapshot>(
              stream: DatabaseFirebaseFirestore
                  .allWhiteList, // a previously-obtained Future<String> or null
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                return Text(
                  (snapshot.data?.docs.length.toString() ?? '-'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w200, fontSize: 12),
                );
              }))
    ])),
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: listTabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ResultPageController>();
    final toggleController = context.watch<ToggleController>();

    _tabController.index = toggleController.selectedIndex;

    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(243, 150, 154, 1),
                        Color.fromRGBO(120, 194, 173, 1),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.amber,
                        indicatorWeight: 3,
                        labelColor: Colors.black,
                        tabs: listTabs,
                        onTap: (index) {
                          controller.setSelectedTabIndex(index);
                          toggleController.setSelectedIndex(index);
                        },
                      )
                    ],
                  )),
            ),
            body: Container(
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(243, 150, 154, 1),
                    Color.fromRGBO(120, 194, 173, 1),
                  ],
                ),
              ),
              child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    ResultListWidget(constants_firebase.blackList),
                    ResultListWidget(constants_firebase.whiteList)
                  ]),
            )));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
