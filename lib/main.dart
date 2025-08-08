import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:simple/cubit/auth_cubit.dart';
import 'package:simple/cubit/user_cubit.dart';
import 'package:simple/page/responsive/admin_base.dart';
import 'package:simple/page/user/sign_in.dart';
import 'package:simple/page/widget/loading_indicator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID').then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit()..checkAuthStatus(),
        ),
        BlocProvider<UserCubit>(create: (context) => UserCubit()),
      ],
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
        home: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthFail) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
            }
          },
          builder: (context, state) {
            if (state is UserAuthenticated) {
              switch (state.userLoggedIn.user!.roleId) {
                case 1:
                  return AdminBasePage(userLoggedIn: state.userLoggedIn);
                default:
                  return AdminBasePage(userLoggedIn: state.userLoggedIn);
              }
            } else if (state is UserUnauthenticated) {
              return SignInPage();
            }
            return Scaffold(body: LoadingIndicator());
          },
        ),
      ),
    );
  }
}
