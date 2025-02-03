import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class SkippedEmailsHistoryModel {
  int id;
  String email;

  SkippedEmailsHistoryModel({
    this.id = 0,
    required this.email,
  });
}