class AppUrl {
  static String appTitle = 'Simple';
  static String apiUrl = 'http://127.0.0.1:8201';

  static String masuk = '$apiUrl/masuk';
  static String verifyCaptcha = '$apiUrl/verifycaptcha';

  static String instances = '$apiUrl/instances';
  static String viewInstance = '$instances/view';
  static String addInstance = '$instances/add';
  static String editInstance = '$instances/edit';

  static String roles = '$apiUrl/roles';
  static String addrole = '$roles/add';
  static String editrole = '$roles/edit';

  static String users = '$apiUrl/users';
  static String beforeAddUser = '$users/beforeadd';
  static String addUser = '$users/add';
  static String viewUser = '$users/view';
  static String editUser = '$users/edit';
  static String editUserOnly = '$users/editonly';
  static String changePassword = '$users/changepassword';
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
