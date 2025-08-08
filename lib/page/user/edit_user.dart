import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:simple/cubit/user_cubit.dart';
import 'package:simple/model/instance.dart';
import 'package:simple/model/role.dart';
import 'package:simple/model/user.dart';
import 'package:simple/page/user/two_fa_setup.dart';

class EditUserPage extends StatefulWidget {
  final User user;
  const EditUserPage({super.key, required this.user});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formState = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _emailController;
  final _passwordController = TextEditingController();
  final _repeatpasswordController = TextEditingController();
  bool _obscureText = true;
  bool _repeatobscureText = true;
  late int instanceId;
  late int roleId;
  bool editPasswordToo = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserCubit>().beforeAddUser();
    });
    _namaController = TextEditingController(text: widget.user.nama);
    _emailController = TextEditingController(text: widget.user.email);
    instanceId = widget.user.instanceId;
    roleId = widget.user.roleId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ubah pengguna')),
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
              return Center(child: CircularProgressIndicator());
            } else {
              final instances = state.instancesRoles.instances;
              final roles = state.instancesRoles.roles;
              return Form(
                key: _formState,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
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
                    Row(
                      children: [
                        Switch(
                          value: editPasswordToo,
                          onChanged: (value) {
                            setState(() {
                              editPasswordToo = value;
                            });
                          },
                        ),
                        Text('Ganti kata kunci'),
                      ],
                    ),
                    if (editPasswordToo) SizedBox(height: 12.0),
                    if (editPasswordToo)
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
                    if (editPasswordToo) SizedBox(height: 12.0),
                    if (editPasswordToo)
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
                      selectedItem: instances
                          .where((e) => e.id == instanceId)
                          .first,
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
                      selectedItem: roles.where((e) => e.id == roleId).first,
                      items: (filter, loadProps) {
                        if (filter.length > 2) {
                          return roles.where((e) {
                            final sebagai = e.nama.toLowerCase();
                            return e.nama != 'Administrator' &&
                                sebagai.contains(filter);
                          }).toList();
                        }
                        return roles
                            .where((e) => e.nama != 'Administrator')
                            .toList();
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
                    SizedBox(height: 12.0),
                    widget.user.twoFAEnabled!
                        ? Row(children: [Text('2FA telah aktif')])
                        : Row(
                            children: [
                              Text('2FA belum aktif, aktifkan?'),
                              SizedBox(width: 12.0),
                              ElevatedButton(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TwoFASetupPage(),
                                    ),
                                  );
                                  if (context.mounted) {
                                    Navigator.pop(context, true);
                                  }
                                },
                                child: Text('Ya, aktifkan'),
                              ),
                            ],
                          ),
                    SizedBox(height: 12.0),
                    Text(
                      'Pembaharuan terakhir pada ${DateFormat('dd MMMM yyyy, HH:mm WIB', 'id_ID').format(widget.user.modified!.toLocal())}',
                    ),
                    SizedBox(height: 16.0),
                    OverflowBar(
                      children: [
                        FilledButton.icon(
                          onPressed: () {
                            if (_formState.currentState!.validate()) {
                              if (editPasswordToo) {
                                context.read<UserCubit>().editUser(
                                  User(
                                    id: widget.user.id,
                                    nama: _namaController.text,
                                    email: _emailController.text,
                                    instanceId: instanceId,
                                    roleId: roleId,
                                  ),
                                  _passwordController.text,
                                );
                              } else {
                                context.read<UserCubit>().editUserOnly(
                                  User(
                                    id: widget.user.id,
                                    nama: _namaController.text,
                                    email: _emailController.text,
                                    instanceId: instanceId,
                                    roleId: roleId,
                                  ),
                                );
                              }
                            }
                          },
                          icon: Icon(Icons.save),
                          label: Text('Simpan'),
                        ),
                        if (widget.user.twoFAEnabled!) SizedBox(width: 12.0),
                        if (widget.user.twoFAEnabled!)
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<UserCubit>().disable2FA(
                                widget.user.id!.toString(),
                              );
                            },
                            icon: Icon(Icons.sync_disabled),
                            label: Text('Matikan 2FA'),
                          ),
                        SizedBox(width: 12.0),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<UserCubit>().deleteUser(
                              widget.user.id!,
                            );
                          },
                          icon: Icon(Icons.delete_forever),
                          label: Text('Hapus'),
                        ),
                      ],
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
