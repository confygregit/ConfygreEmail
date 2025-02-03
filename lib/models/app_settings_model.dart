import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class AppSettingsModel {
  int id;
  //bool unsubscribeAndMoveToTrash = false;
  bool permanentDelete = false;
  bool blockTheSender = false;
  bool deleteAllMailsFromTheSender = false;
  bool showSkippedEmails = false;
  bool showOnlyUnsubscribableEmails = false;

  AppSettingsModel({
    this.id = 0,
    //required this.unsubscribeAndMoveToTrash,
    required this.permanentDelete,
    required this.blockTheSender,
    required this.deleteAllMailsFromTheSender,
    required this.showSkippedEmails,
    required this.showOnlyUnsubscribableEmails,
  });
}