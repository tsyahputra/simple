import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/cubit/user_cubit.dart';
import 'package:simple/page/responsive/admin_base.dart';
import 'package:simple/page/user/sign_in.dart';
import 'package:simple/service/user_rest.dart';

class UserCheckPoint extends StatefulWidget {
  const UserCheckPoint({super.key});

  @override
  State<UserCheckPoint> createState() => _UserCheckPointState();
}

class _UserCheckPointState extends State<UserCheckPoint> {
  UserCubit userCubit = UserCubit(UserRest());

  @override
  void initState() {
    super.initState();
    userCubit.getUserLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => userCubit,
        child: BlocListener<UserCubit, UserState>(
          listener: (context, state) {
            if (state is UserFail) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => SignInPage(),
                ),
                (Route<dynamic> route) => false,
              );
            } else if (state is UserAuthenticated) {
              switch (state.userLoggedIn.user!.roleId) {
                // Admin
                case 1:
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          AdminBasePage(userLoggedIn: state.userLoggedIn.user!),
                    ),
                    (Route<dynamic> route) => false,
                  );
                  break;
                // Koordinator
                // case 2:
                //   Navigator.pushAndRemoveUntil(
                //       context,
                //       MaterialPageRoute(
                //         builder: (BuildContext context) => KoordinatorBasePage(
                //           userLoggedIn: state.userLoggedIn.user!,
                //         ),
                //       ),
                //       (Route<dynamic> route) => false);
                //   break;
                // Perancang
                // case 3:
                //   Navigator.pushAndRemoveUntil(
                //       context,
                //       MaterialPageRoute(
                //         builder: (BuildContext context) => PerancangBasePage(
                //           userLoggedIn: state.userLoggedIn.user!,
                //         ),
                //       ),
                //       (Route<dynamic> route) => false);
                //   break;
                // Satker
                // default:
                //   Navigator.pushAndRemoveUntil(
                //       context,
                //       MaterialPageRoute(
                //         builder: (BuildContext context) => SatkerBasePage(
                //           userLoggedIn: state.userLoggedIn.user!,
                //         ),
                //       ),
                //       (Route<dynamic> route) => false);
              }
            }
          },
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
