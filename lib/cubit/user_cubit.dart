import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:simple/model/role.dart';
import 'package:simple/model/user.dart';
import 'package:simple/service/user_rest.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserRest userRest;

  UserCubit(this.userRest) : super(UserInitial());

  void onUserInit() async {
    final users = await userRest.getAllUsers(0, '');
    if (users.users.length < 10) {
      emit(
        UsersLoaded(
          users: users.users,
          hasReachedMax: true,
          total: users.total!,
        ),
      );
    } else {
      emit(
        UsersLoaded(
          users: users.users,
          hasReachedMax: false,
          total: users.total!,
        ),
      );
    }
  }

  void onUserFetched() async {
    Users users;
    try {
      UsersLoaded usersLoaded = state as UsersLoaded;
      if (usersLoaded.hasReachedMax) return;
      users = await userRest.getAllUsers(usersLoaded.users.length, '');
      users.users.isEmpty
          ? emit(
              UsersLoaded(
                users: usersLoaded.users,
                hasReachedMax: true,
                total: usersLoaded.total,
              ),
            )
          : emit(
              UsersLoaded(
                users: usersLoaded.users + users.users,
                hasReachedMax: false,
                total: usersLoaded.total,
              ),
            );
    } on Exception catch (_) {
      emit(UserFail('Gagal'));
    }
  }

  void onUserSearch(String lastSearchTerm) async {
    final users = await userRest.getAllUsers(0, lastSearchTerm);
    emit(
      UsersLoaded(users: users.users, hasReachedMax: true, total: users.total!),
    );
  }

  void beforeAddUser() async {
    var result = await userRest.beforeAddUser();
    result.fold((l) => emit(UserFail(l)), (r) => emit(BeforeAddUser(r)));
  }

  void viewUser(int userId) async {
    var result = await userRest.viewUser(userId);
    result.fold((l) => emit(UserFail(l)), (r) => emit(UserLoaded(r)));
  }

  void addUser(User user, String password) async {
    var result = await userRest.addUser(user, password);
    result.fold((l) => emit(UserFail(l)), (_) => emit(UserSubmitted()));
  }

  void editUser(User user, String password) async {
    var result = await userRest.editUser(user, password);
    result.fold((l) => emit(UserFail(l)), (_) => emit(UserSubmitted()));
  }

  void editUserOnly(User user) async {
    var result = await userRest.editUserOnly(user);
    result.fold((l) => emit(UserFail(l)), (_) => emit(UserSubmitted()));
  }

  void changePassword(int id, String password) async {
    var result = await userRest.changePassword(id, password);
    result.fold((l) => emit(UserFail(l)), (_) => emit(UserSubmitted()));
  }

  void deleteUser(int id) async {
    var result = await userRest.deleteUser(id);
    result.fold((l) => emit(UserFail(l)), (_) => emit(UserSubmitted()));
  }

  void masuk(String email, String password, String fcmToken) async {
    var result = await userRest.masuk(email, password, fcmToken);
    result.fold((l) => emit(UserFail(l)), (r) => emit(UserAuthenticated(r)));
  }

  void getUserLoggedIn() async {
    var result = await userRest.getUserLoggedIn();
    result.fold((l) => emit(UserFail(l)), (r) => emit(UserAuthenticated(r)));
  }

  void verifyCaptcha() async {
    var result = await userRest.verifyCaptcha();
    result.fold((l) => emit(CaptchaFail(l)), (_) => emit(UserVerified()));
  }

  void generateSecret() async {
    emit(UserLoading());
    final result = await userRest.generate2FASecret();
    result.fold((l) => emit(UserFail(l)), (r) => emit(TwoFASecretGenerated(r)));
  }

  void verifyAndEnable2FA(String code) async {
    emit(UserLoading());
    final result = await userRest.verifyAndEnable2FA(code);
    result.fold((l) => emit(UserFail(l)), (r) => emit(UserVerified()));
  }

  void disable2FA(String userId) async {
    emit(UserLoading());
    final result = await userRest.disable2FA(userId);
    result.fold((l) => emit(UserFail(l)), (_) => emit(UserSubmitted()));
  }

  void verifyTwoFAResetPassword(String email, String code) async {
    emit(UserLoading());
    final result = await userRest.verifyTwoFAResetPassword(email, code);
    result.fold((l) => emit(UserFail(l)), (r) => emit(ResetTokenReceived(r)));
  }

  void resetPassword(String otp, String email, String password) async {
    var result = await userRest.resetPassword(otp, email, password);
    result.fold((l) => emit(UserFail(l)), (_) => emit(UserSubmitted()));
  }
}
