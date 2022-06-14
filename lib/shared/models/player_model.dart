import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PlayerModel {
  final String id;
  final String name;
  final String listType;
  final bool isMatchText;
  final Color? color;
  final List<String>? chips;
  final Timestamp? createdDate;
  final List<String>? indexSearch;

  PlayerModel(this.id, this.name, this.listType, this.isMatchText, this.color, this.chips, this.createdDate, this.indexSearch);
}
