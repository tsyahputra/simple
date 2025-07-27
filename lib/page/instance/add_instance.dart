import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/cubit/instance_cubit.dart';
import 'package:simple/model/instance.dart';
import 'package:simple/service/constants.dart';
import 'package:simple/service/instance_rest.dart';

class AddInstancePage extends StatefulWidget {
  const AddInstancePage({super.key});

  @override
  State<AddInstancePage> createState() => _AddInstancePageState();
}

class _AddInstancePageState extends State<AddInstancePage> {
  InstanceCubit instanceCubit = InstanceCubit(InstanceRest());
  final _formState = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  late String _kabupaten;
  late TextEditingController _provinsiController;
  final _telpController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _provinsiController = TextEditingController(text: 'Jambi');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Kantor')),
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
                children: [
                  TextFormField(
                    autofocus: true,
                    controller: _namaController,
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
                      labelText: 'Provnsi',
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
                  SizedBox(height: 16.0),
                  FilledButton.icon(
                    onPressed: () {
                      if (_formState.currentState!.validate()) {
                        instanceCubit.addInstance(
                          Instance(
                            nama: _namaController.text,
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
