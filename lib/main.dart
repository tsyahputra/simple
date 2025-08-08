import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:simple/cubit/user_cubit.dart';
import 'package:simple/page/user/sign_in.dart';
import 'package:simple/page/user/users_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID').then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserCubit(),
      child: MaterialApp(
        title: 'Simple',
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: BlocBuilder<UserCubit, UserState>(
          builder: (context, state) {
            if (state is UserAuthenticated) {
              return UsersPage();
            }
            return SignInPage();
          },
        ),
      ),
    );
  }
}
