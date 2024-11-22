import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:simple/model/user.dart';
import 'package:simple/service/constants.dart';

class LocalStorage {
  static const storage = FlutterSecureStorage();

  static Future clear() async {
    await storage.deleteAll();
  }

  static Future<UserLoggedIn> getUserLoggedIn() async {
    final Dio dio = Dio();
    var userSimple = await storage.read(key: 'userLoggedIn');
    if (userSimple == null || userSimple.isEmpty || userSimple == '') {
      return UserLoggedIn(user: null, accessToken: '', refreshToken: '');
    }
    UserLoggedIn userLoggedIn = UserLoggedIn.fromJson(jsonDecode(userSimple));
    bool tokenExpired = JwtDecoder.isExpired(userLoggedIn.accessToken!);
    if (!tokenExpired) {
      return userLoggedIn;
    } else {
      final response = await dio.get(
        AppUrl.refreshToken,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${userLoggedIn.refreshToken}',
          },
        ),
      );
      UserLoggedIn newUserToken = UserLoggedIn.fromJson(response.data);
      await setUserProfile(newUserToken);
      return newUserToken;
    }
  }

  static Future setUserProfile(UserLoggedIn userLoggedIn) async {
    await storage.write(
      key: 'userLoggedIn',
      value: jsonEncode(userLoggedIn.toJson()),
    );
  }
}
