import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:simple/model/user.dart';

class LocalStorage {
  static const storage = FlutterSecureStorage();

  static Future clear() async {
    await storage.deleteAll();
  }

  static Future<UserLoggedIn> getUserLoggedIn() async {
    var userLoggedIn = await storage.read(key: 'userLoggedIn');
    if (userLoggedIn == null) {
      return UserLoggedIn(user: null, accessToken: '', refreshToken: '');
    }
    return UserLoggedIn.fromJson(jsonDecode(userLoggedIn));
  }

  static Future setUserProfile(UserLoggedIn userLoggedIn) async {
    await storage.write(
      key: 'userLoggedIn',
      value: jsonEncode(userLoggedIn.toJson()),
    );
  }
}
