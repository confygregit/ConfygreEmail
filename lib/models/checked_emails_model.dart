import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class CheckedEmailsModel {
  int id;
  String emailIds;

  CheckedEmailsModel({
    this.id = 0,
    required this.emailIds,
  });
}