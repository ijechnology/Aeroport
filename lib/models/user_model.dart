import 'dart:convert';
import 'package:crypto/crypto.dart';

class UserModel {
  final String username;
  final String passwordHash;

  UserModel({required this.username, required this.passwordHash});

  static String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}
