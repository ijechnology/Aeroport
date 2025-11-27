import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthController extends GetxController {
  final userBox = Hive.box('users');
  final sessionBox = Hive.box('session');

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool register(String username, String password) {
    if (userBox.containsKey(username)) return false;

    final hashed = hashPassword(password);
    userBox.put(username, hashed);
    return true;
  }

  bool login(String username, String password) {
    final hashed = hashPassword(password);
    final stored = userBox.get(username);

    if (stored == hashed) {
      sessionBox.put('isLoggedIn', true);
      sessionBox.put('username', username);
      return true;
    }
    return false;
  }

  void logout() {
    sessionBox.clear();
  }

  String getUsername() {
    return sessionBox.get('username', defaultValue: '');
  }

  bool get isLoggedIn => sessionBox.get('isLoggedIn', defaultValue: false);
}
