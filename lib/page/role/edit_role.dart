import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/cubit/role_cubit.dart';
import 'package:simple/model/role.dart';
import 'package:simple/service/role_rest.dart';

class EditRolePage extends StatefulWidget {
  final Role role;
  const EditRolePage({super.key, required this.role});

  @override
  State<EditRolePage> createState() => _EditRolePageState();
}

class _EditRolePageState extends State<EditRolePage> {
  RoleCubit roleCubit = RoleCubit(RoleRest());
  final _formState = GlobalKey<FormState>();
  late TextEditingController _namaController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.role.nama);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ubah hak akses')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: BlocProvider(
          create: (context) => roleCubit,
          child: BlocListener<RoleCubit, RoleState>(
            listener: (context, state) {
              if (state is RoleSubmitted) {
                Navigator.pop(context, true);
              } else if (state is RoleFail) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
              }
            },
            child: Form(
              key: _formState,
              child: Column(
                children: [
                  TextFormField(
                    autofocus: true,
                    controller: _namaController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      labelText: 'Nama lengkap',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tidak boleh kosong';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  SizedBox(height: 16.0),
                  FilledButton.icon(
                    onPressed: () {
                      if (_formState.currentState!.validate()) {
                        roleCubit.editRole(
                          Role(id: widget.role.id, nama: _namaController.text),
                        );
                      }
                    },
                    icon: Icon(Icons.save),
                    label: Text('Simpan'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
