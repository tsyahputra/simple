import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:simple/cubit/instance_cubit.dart';
import 'package:simple/model/instance.dart';
import 'package:simple/service/constants.dart';
import 'package:simple/service/instance_rest.dart';

class EditInstancePage extends StatefulWidget {
  final Instance instance;
  const EditInstancePage({super.key, required this.instance});

  @override
  State<EditInstancePage> createState() => _EditInstancePageState();
}

class _EditInstancePageState extends State<EditInstancePage> {
  InstanceCubit instanceCubit = InstanceCubit(InstanceRest());
  final _formState = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _alamatController;
  late String _kabupaten;
  late TextEditingController _telpController;
  late TextEditingController _emailController;
  late TextEditingController _provinsiController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.instance.nama);
    _alamatController = TextEditingController(text: widget.instance.alamat);
    _kabupaten = widget.instance.kabupaten!;
    _telpController = TextEditingController(text: widget.instance.telp);
    _emailController = TextEditingController(text: widget.instance.email);
    _provinsiController = TextEditingController(text: widget.instance.provinsi);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ubah data kantor')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: BlocProvider(
          create: (context) => instanceCubit,
          child: BlocListener<InstanceCubit, InstanceState>(
            listener: (context, state) {
              if (state is InstanceSubmitted) {
                Navigator.pop(context, true);
              } else if (state is InstanceFail) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
              }
            },
            child: Form(
              key: _formState,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      labelText: 'Nama Kantor',
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
                    controller: _alamatController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      labelText: 'Alamat Kantor',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tidak boleh kosong';
                      }
                      return null;
                    },
                    maxLines: 3,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  SizedBox(height: 12.0),
                  DropdownButtonFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      labelText: 'Kabupaten',
                    ),
                    value: _kabupaten,
                    items: listKab.map((e) {
                      return DropdownMenuItem(value: e, child: Text(e));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _kabupaten = value!;
                      });
                    },
                  ),
                  SizedBox(height: 12.0),
                  TextFormField(
                    controller: _provinsiController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      labelText: 'Provinsi',
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
                    controller: _telpController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      labelText: 'Telepon Kantor',
                    ),
                    keyboardType: TextInputType.phone,
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
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 12.0),
                  Text(
                    'Pembaharuan terakhir pada ${DateFormat('dd MMMM yyyy, HH:mm WIB', 'id_ID').format(widget.instance.modified!.toLocal())}',
                  ),
                  SizedBox(height: 16.0),
                  FilledButton.icon(
                    onPressed: () {
                      if (_formState.currentState!.validate()) {
                        instanceCubit.editInstance(
                          Instance(
                            id: widget.instance.id,
                            nama: _nameController.text,
                            alamat: _alamatController.text,
                            kabupaten: _kabupaten,
                            provinsi: _provinsiController.text,
                            telp: _telpController.text,
                            email: _emailController.text,
                          ),
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
