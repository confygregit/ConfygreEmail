import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class TilesDataModel {
  int id;
  String dateTimeInUTC;
  int unsubscribed;
  int skipped;
  int deleted;
  int available;

  TilesDataModel({
    this.id = 0,
    required this.dateTimeInUTC,
    required this.unsubscribed,
    required this.deleted,
    required this.skipped,
    this.available = -1,
  });
}