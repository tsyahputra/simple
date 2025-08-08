import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/cubit/auth_cubit.dart';
import 'package:simple/model/user.dart';
import 'package:simple/page/user/users_page.dart';
import 'package:simple/service/constants.dart';

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
    return kIsWeb ? webLayout() : mobileLayout();
  }

  Widget webLayout() {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userLoggedIn.user!.instance!.nama),
        actions: [Text(widget.userLoggedIn.user!.nama), SizedBox(width: 8.0)],
      ),
      body: Row(
        children: [
          adminMenuWeb(),
          Expanded(
            child: Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.only(left: 24.0, right: 24.0, top: 6.0),
              child: _currentPage,
            ),
          ),
        ],
      ),
    );
  }

  Widget adminMenuWeb() {
    return NavigationRail(
      leading: CircleAvatar(child: Image.asset('images/pengayoman.png')),
      backgroundColor: Theme.of(context).focusColor,
      labelType: NavigationRailLabelType.all,
      onDestinationSelected: (index) {
        setState(() {
          selectedIndex = index;
          switch (index) {
            case 0:
              //   _drawerSelection = DrawerSelection.kantor;
              //   _currentPage = InstancesPage();
              //   break;
              // case 1:
              //   _drawerSelection = DrawerSelection.hakakses;
              //   _currentPage = RolesPage();
              //   break;
              // case 2:
              _drawerSelection = DrawerSelection.pengguna;
              _currentPage = UsersPage();
              break;
          }
        });
      },
      destinations: [
        NavigationRailDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: Text('Daftar Pengguna'),
        ),
        NavigationRailDestination(
          icon: IconButton(
            onPressed: () => _logoutDialog(context),
            icon: Icon(Icons.logout),
          ),
          label: Text('Keluar'),
        ),
      ],
      selectedIndex: selectedIndex,
    );
  }

  Widget mobileLayout() {
    return Scaffold(
      appBar: AppBar(title: Text(AppUrl.appTitle)),
      drawer: adminMenuMobile(),
      body: Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.all(12.0),
        child: _currentPage,
      ),
    );
  }

  Widget adminMenuMobile() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            accountName: Text(widget.userLoggedIn.user!.nama),
            accountEmail: Text(widget.userLoggedIn.user!.email),
            currentAccountPicture: CircleAvatar(
              child: Image.asset('images/pengayoman.png'),
            ),
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Daftar Pengguna'),
            selected: _drawerSelection == DrawerSelection.pengguna,
            onTap: () {
              setState(() {
                _drawerSelection = DrawerSelection.pengguna;
                _currentPage = UsersPage();
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Keluar'),
            onTap: () {
              Navigator.pop(context);
              _logoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _logoutDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Peringatan'),
          content: Text('Anda yakin akan keluar ?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Tidak'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<AuthCubit>().keluar();
              },
              child: Text('Ya'),
            ),
          ],
        );
      },
    );
  }
}
