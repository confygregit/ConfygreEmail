import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class UnsubscribedEmailHisotryModel {
  int id;
  String email;
  int count;

  UnsubscribedEmailHisotryModel({
    this.id = 0,
    required this.email,
    required this.count,
  });
}