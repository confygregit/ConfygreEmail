import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class UserCredentialModel {
  int id;
  String userEmail;
  String accessToken;
  String idToken;

  UserCredentialModel({
    this.id = 0,
    required this.userEmail,
    required this.accessToken,
    required this.idToken,
  });
}