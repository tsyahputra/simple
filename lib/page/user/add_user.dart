import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/cubit/user_cubit.dart';
import 'package:simple/model/instance.dart';
import 'package:simple/model/role.dart';
import 'package:simple/model/user.dart';
import 'package:simple/page/widget/loading_indicator.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formState = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatpasswordController = TextEditingController();
  bool _obscureText = true;
  bool _repeatobscureText = true;
  late int instanceId;
  late int roleId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserCubit>().beforeAddUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah pengguna')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: BlocConsumer<UserCubit, UserState>(
          listener: (context, state) {
            if (state is UserSubmitted) {
              Navigator.pop(context, true);
            } else if (state is UserFail) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
            }
          },
          builder: (context, state) {
            if (state is! BeforeAddUser) {
              return LoadingIndicator();
            } else {
              final instances = state.instancesRoles.instances;
              final roles = state.instancesRoles.roles;
              return Form(
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
                    SizedBox(height: 12.0),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        labelText: 'Email',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tidak boleh kosong';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 12.0),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        labelText: 'Kata kunci',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value!.length < 8 || value.isEmpty) {
                          return 'Tidak boleh kurang dari 8 karakter';
                        }
                        if (!RegExp(".*[0-9].*").hasMatch(value)) {
                          return 'Harus memiliki satu atau lebih karakter angka.';
                        }
                        if (!RegExp('.*[a-z].*').hasMatch(value)) {
                          return 'Harus memiliki satu atau lebih huruf.';
                        }
                        if (!RegExp('.*[A-Z].*').hasMatch(value)) {
                          return 'Harus memiliki satu atau lebih huruf kapital.';
                        }
                        if (!RegExp(
                          r'^(?=.*?[!@#$&*~`)\%\-(_+=;:,.<>/?"[{\]}\|^])',
                        ).hasMatch(value)) {
                          return 'Harus memiliki minimal satu atau lebih spesial karakter.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.0),
                    TextFormField(
                      controller: _repeatpasswordController,
                      obscureText: _repeatobscureText,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        labelText: 'Ulangi kata kunci',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _repeatobscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _repeatobscureText = !_repeatobscureText;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Tidak sama dengan kata kunci';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.0),
                    DropdownSearch<Instance>(
                      decoratorProps: DropDownDecoratorProps(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          labelText: 'Pada',
                        ),
                      ),
                      suffixProps: DropdownSuffixProps(
                        clearButtonProps: ClearButtonProps(isVisible: true),
                      ),
                      compareFn: (item, selectedItem) {
                        return item.id == selectedItem.id;
                      },
                      popupProps: PopupProps.menu(
                        title: Text('Cari...'),
                        disableFilter: true,
                        showSearchBox: true,
                        showSelectedItems: true,
                        itemBuilder: (ctx, item, isDis, isSel) {
                          return ListTile(title: Text(item.nama));
                        },
                      ),
                      items: (filter, loadProps) {
                        if (filter.length > 2) {
                          return instances.where((item) {
                            final namaSatuan = item.nama.toLowerCase();
                            return namaSatuan.contains(filter);
                          }).toList();
                        }
                        return instances.toList();
                      },
                      dropdownBuilder: (context, selectedItem) {
                        if (selectedItem == null) {
                          return Text('');
                        }
                        instanceId = selectedItem.id!;
                        return Text(selectedItem.nama);
                      },
                      autoValidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null) {
                          return 'Tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.0),
                    DropdownSearch<Role>(
                      decoratorProps: DropDownDecoratorProps(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          labelText: 'Sebagai',
                        ),
                      ),
                      suffixProps: DropdownSuffixProps(
                        clearButtonProps: ClearButtonProps(isVisible: true),
                      ),
                      compareFn: (item, selectedItem) {
                        return item.id == selectedItem.id;
                      },
                      popupProps: PopupProps.menu(
                        title: Text('Cari...'),
                        disableFilter: true,
                        showSearchBox: true,
                        showSelectedItems: true,
                        itemBuilder: (ctx, item, isDis, isSel) {
                          return ListTile(title: Text(item.nama));
                        },
                      ),
                      items: (filter, loadProps) {
                        if (filter.length > 2) {
                          return roles.where((e) {
                            final sebagai = e.nama.toLowerCase();
                            return sebagai.contains(filter);
                          }).toList();
                        }
                        return roles.toList();
                      },
                      dropdownBuilder: (context, selectedItem) {
                        if (selectedItem == null) {
                          return Text('');
                        }
                        roleId = selectedItem.id!;
                        return Text(selectedItem.nama);
                      },
                      autoValidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null) {
                          return 'Tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    FilledButton.icon(
                      onPressed: () {
                        if (_formState.currentState!.validate()) {
                          context.read<UserCubit>().addUser(
                            User(
                              nama: _namaController.text,
                              email: _emailController.text,
                              roleId: roleId,
                              instanceId: instanceId,
                            ),
                            _passwordController.text,
                          );
                        }
                      },
                      icon: Icon(Icons.save),
                      label: Text('Simpan'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
