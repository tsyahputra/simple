import 'package:flutter/material.dart';
import 'package:simple/model/user.dart';
import 'package:simple/page/user/users_page.dart';

enum DrawerSelection { kantor, hakakses, pengguna, profil }

class AdminBasePage extends StatefulWidget {
  final UserLoggedIn userLoggedIn;
  const AdminBasePage({super.key, required this.userLoggedIn});

  @override
  State<AdminBasePage> createState() => _AdminBasePageState();
}

class _AdminBasePageState extends State<AdminBasePage> {
  DrawerSelection _drawerSelection = DrawerSelection.pengguna;
  late Widget _currentPage = UsersPage();
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
