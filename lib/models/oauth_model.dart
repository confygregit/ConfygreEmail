import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class OauthModel {
  int id;
  bool useDefaultKey = false;
  String oAuthKey;

  OauthModel({
    this.id = 0,
    required this.useDefaultKey,
    required this.oAuthKey,
  });
}