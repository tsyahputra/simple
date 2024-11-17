import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/cubit/role_cubit.dart';
import 'package:simple/model/role.dart';
import 'package:simple/page/role/add_role.dart';
import 'package:simple/page/role/edit_role.dart';
import 'package:simple/service/role_rest.dart';

class RolesPage extends StatefulWidget {
  const RolesPage({super.key});

  @override
  State<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends State<RolesPage> {
  RoleCubit roleCubit = RoleCubit(RoleRest());

  @override
  void initState() {
    super.initState();
    roleCubit.getAllRole();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => roleCubit,
      child: BlocConsumer<RoleCubit, RoleState>(
        listener: (context, state) {
          if (state is RoleFail) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.errorMessage)));
          }
        },
        builder: (context, state) {
          if (state is! RoleLoaded) {
            return CircularProgressIndicator();
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Data Hak Akses',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        onPressed: () async {
                          var result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddRolePage(),
                            ),
                          );
                          if (result != null) roleCubit.getAllRole();
                        },
                        icon: const Icon(Icons.add_circle),
                        tooltip: 'Tambah hak akses',
                      ),
                    ],
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.roles.length,
                    itemBuilder: (context, index) {
                      return daftarRole(state.roles[index], context);
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget daftarRole(Role role, BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(Icons.rule)),
        title: Text(role.nama),
        onTap: () async {
          var result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditRolePage(role: role),
            ),
          );
          if (result != null) roleCubit.getAllRole();
        },
      ),
    );
  }
}
