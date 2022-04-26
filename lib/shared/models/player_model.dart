import 'package:flutter/material.dart';

class PlayerModel {
  final String id;
  final String name;
  final String listType;
  final bool isMatchText;
  final Color? color;

  PlayerModel(this.id, this.name, this.listType, this.isMatchText, this.color);
}
