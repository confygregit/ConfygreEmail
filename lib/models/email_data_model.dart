import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';

class EmailDataModel {
  String? emailId;
  String? subject;
  String? senderEmail;
  String? senderName;
  int count = 0;
  bool isStared = false;
  bool isLabeled = false;
  bool isImportant = false;
  bool isOneClickUnsub = false;
  String? mailToString;
  String? mailToSubject;
  String? directString;
  //bool? canBeUnsubscribed = false;
}
