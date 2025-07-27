import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/cubit/user_cubit.dart';
import 'package:simple/page/user_check.dart';
import 'package:simple/service/user_rest.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  final String resetToken;
  const ResetPasswordPage({
    super.key,
    required this.email,
    required this.resetToken,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  UserCubit userCubit = UserCubit(UserRest());
  final _formState = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _repeatpasswordController = TextEditingController();
  bool _obscureText = true;
  bool _repeatobscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Masukkan kata kunci baru')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: BlocProvider(
          create: (context) => userCubit,
          child: BlocListener<UserCubit, UserState>(
            listener: (context, state) {
              if (state is UserFail) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
              } else if (state is UserSubmitted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => UserCheckPoint(),
                  ),
                  (Route<dynamic> route) => false,
                );
              }
            },
            child: Form(
              key: _formState,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Masukkan kata kunci baru untuk akun ${widget.email}'),
                  SizedBox(height: 12.0),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      labelText: 'Kata kunci baru',
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
                  SizedBox(height: 16.0),
                  FilledButton.icon(
                    onPressed: () {
                      if (_formState.currentState!.validate()) {
                        userCubit.resetPassword(
                          widget.email,
                          _passwordController.text,
                          widget.resetToken,
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
