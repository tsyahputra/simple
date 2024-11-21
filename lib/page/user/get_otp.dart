import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_captcha/flutter_captcha.dart';
import 'package:simple/cubit/user_cubit.dart';
import 'package:simple/page/user/reset_password.dart';
import 'package:simple/service/user_rest.dart';

class GetOtpPage extends StatefulWidget {
  const GetOtpPage({super.key});

  @override
  State<GetOtpPage> createState() => _GetOtpPageState();
}

class _GetOtpPageState extends State<GetOtpPage> {
  UserCubit userCubit = UserCubit(UserRest());
  final captchaController = FlutterCaptchaController(
    random: Random.secure(),
  )..init();
  final _emailController = TextEditingController();
  final _formState = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lupa password')),
      body: BlocProvider(
        create: (context) => userCubit,
        child: BlocListener<UserCubit, UserState>(
          listener: (context, state) {
            if (state is UserFail) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.errorMessage)));
            } else if (state is UserSubmitted) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => ResetPasswordPage(
                      email: _emailController.text,
                    ),
                  ),
                  (Route<dynamic> route) => false);
            }
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Form(
              key: _formState,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      labelText: 'Email anda',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tidak boleh kosong';
                      }
                      if (!RegExp(
                              r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                          .hasMatch(value)) {
                        return 'Alamat email tidak valid';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 12.0),
                  Text('Susun gambar berikut untuk melanjutkan'),
                  SizedBox(height: 12.0),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 3,
                    child: showCaptcha(),
                  ),
                  const SizedBox(height: 16.0),
                  FilledButton.icon(
                    onPressed: () {
                      if (_formState.currentState!.validate()) {
                        if (captchaController.checkSolution()) {
                          userCubit.getOTPByEmail(_emailController.text);
                        } else {
                          captchaController.reset();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Capctha anda salah'),
                          ));
                        }
                      }
                    },
                    icon: Icon(Icons.send),
                    label: Text('Kirim OTP'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget showCaptcha() {
    return FlutterCaptcha(
      controller: captchaController,
      crossLine: (
        color: Theme.of(context).primaryColor,
        width: 2,
      ),
      fit: BoxFit.cover,
      draggingBuilder: (_, child) => Opacity(
        opacity: 0.5,
        child: child,
      ),
      child: Image.asset('images/pengayoman.png'),
    );
  }
}
