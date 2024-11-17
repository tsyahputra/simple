import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_captcha/flutter_captcha.dart';
import 'package:simple/cubit/user_cubit.dart';
import 'package:simple/page/responsive/responsiveness.dart';
import 'package:simple/page/user_check.dart';
import 'package:simple/service/constants.dart';
import 'package:simple/service/user_rest.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  UserCubit userCubit = UserCubit(UserRest());
  final captchaController = FlutterCaptchaController(
    random: Random.secure(),
  )..init();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formState = GlobalKey<FormState>();
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    userCubit.verifyCaptcha();
  }

  @override
  void dispose() {
    captchaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => userCubit,
        child: BlocListener<UserCubit, UserState>(
          listener: (context, state) {
            if (state is UserFail) {
              if (state.errorMessage == "Silahkan jawab CAPTCHA") {
                captchaController.reset();
                showCaptcha(context);
              }
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.errorMessage)));
            } else if (state is UserAuthenticated) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => UserCheckPoint(),
                  ),
                  (Route<dynamic> route) => false);
            } else if (state is CaptchaFail) {
              captchaController.reset();
              showCaptcha(context);
            }
          },
          child: kIsWeb
              ? ResponsiveLayout(
                  largeScreen: largeLayout(),
                  mediumScreen: mediumLayout(),
                  smallScreen: smallLayout(),
                )
              : smallLayout(),
        ),
      ),
    );
  }

  Widget largeLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            color: Theme.of(context).splashColor,
            child: Image.asset('images/login.png'),
          ),
        ),
        Expanded(
          child: Container(
            constraints: BoxConstraints(maxWidth: 21),
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: loginForm(),
          ),
        ),
      ],
    );
  }

  Widget mediumLayout() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage('images/login.png')),
      ),
      child: Card(
        color: Theme.of(context).splashColor,
        margin: EdgeInsets.all(40.0),
        child: loginForm(),
      ),
    );
  }

  Widget smallLayout() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Center(
            child: SizedBox(
              width: 375,
              child: loginForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget loginForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 80,
          width: 80,
          child: Image.asset('images/pengayoman.png'),
        ),
        SizedBox(height: 8.0),
        Text(
          'KEMENTERIAN HUKUM RI',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          'KANTOR WILAYAH JAMBI',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 20.0),
        Center(
          child: SizedBox(
            width: 480,
            child: Card(
              elevation: 5,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Form(
                  key: _formState,
                  child: Column(
                    children: [
                      Text(
                        AppUrl.appTitle.toUpperCase(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.key),
                            suffixIcon: IconButton(
                              icon: _obscureText
                                  ? Icon(Icons.visibility_off)
                                  : Icon(Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 12.0),
                      FilledButton(
                        onPressed: () async {
                          if (_formState.currentState!.validate()) {
                            userCubit.masuk(
                              _emailController.text,
                              _passwordController.text,
                            );
                          }
                        },
                        child: Text('Masuk'),
                      ),
                      SizedBox(height: 8.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          '\u00a9 2024 Kantor Wilayah Kementerian Hukum dan HAM Jambi',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }

  void showCaptcha(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) {
        return Scaffold(
          body: Center(
            child: FlutterCaptcha(
              controller: captchaController,
              crossLine: (
                color: Theme.of(context).primaryColor,
                width: 10,
              ),
              fit: BoxFit.cover,
              draggingBuilder: (_, child) => Opacity(
                opacity: 0.5,
                child: child,
              ),
              child: Image.asset('images/pengayoman.png'),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (captchaController.checkSolution()) {
                Navigator.of(context).pop();
              } else {
                captchaController.reset();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Capctha anda salah'),
                ));
              }
            },
            child: Icon(Icons.check),
          ),
        );
      },
    ));
  }
}
