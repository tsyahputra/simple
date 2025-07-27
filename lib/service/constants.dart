import 'package:flutter/foundation.dart' show kIsWeb;

class AppUrl {
  static String appTitle = 'Simple';
  static String apiUrl = kIsWeb
      ? 'http://127.0.0.1:8081'
      : 'http://10.0.2.2:8081';

  static String masuk = '$apiUrl/masuk';
  static String verifyCaptcha = '$apiUrl/verify-captcha';
  static String verify2FAReset = '$apiUrl/verify-2fa-reset';
  static String resetPassword = '$apiUrl/reset-password';

  static String instances = '$apiUrl/instances';
  static String viewInstance = '$instances/view';
  static String addInstance = '$instances/add';
  static String editInstance = '$instances/edit';

  static String roles = '$apiUrl/roles';
  static String addrole = '$roles/add';
  static String editrole = '$roles/edit';

  static String users = '$apiUrl/users';
  static String beforeAddUser = '$users/before-add';
  static String addUser = '$users/add';
  static String viewUser = '$users/view';
  static String editUser = '$users/edit';
  static String editUserOnly = '$users/edit-only';
  static String changePassword = '$users/change-password';
  static String generate2FASecret = '$users/generate-secret';
  static String verifyEnable2FA = '$users/verify-enable';
  static String disable2FA = '$users/disable-2fa';

  static String refreshToken = '$apiUrl/refresh-token';
}

List<String> listKab = <String>[
  'Kota Jambi',
  'Muaro Jambi',
  'Batanghari',
  'Sarolangun',
  'Merangin',
  'Bungo',
  'Tebo',
  'Tanjung Jabung Barat',
  'Tanjung Jabung Timur',
  'Kerinci',
  'Kota Sungai Penuh',
];
