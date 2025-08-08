import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:simple/model/role.dart';
import 'package:simple/model/user.dart';
import 'package:simple/service/constants.dart';
import 'package:simple/service/local_storage.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());

  final Dio _dio = Dio();

  void _handleError(DioException error, Emitter<UserState> emit) {
    if (error.response != null) {
      final data = error.response!.data;
      if (error.response!.statusCode == 401) {
        emit(UserFail('Tidak diizinkan. Silahkan masuk kembali.'));
      } else if (error.response!.statusCode! >= 400 &&
          error.response!.statusCode! < 500) {
        emit(UserFail(data['message'] ?? 'An unknown error occurred.'));
      } else if (error.response!.statusCode! >= 500) {
        emit(UserFail('Server error. Please try again later.'));
      }
    } else {
      emit(UserFail('Gagal koneksi: ${error.message}'));
    }
  }

  Future<void> onUserInit() async {
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      final response = await _dio.get(
        AppUrl.users,
        options: Options(
          headers: {'Authorization': 'Bearer ${userLoggedIn.accessToken}'},
        ),
        queryParameters: {'offset': '0'},
      );
      if (response.statusCode == 200) {
        final users = Users.fromJson(response.data);
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
      } else {
        _handleError(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
          ),
          emit as Emitter<UserState>,
        );
      }
    } on DioException catch (e) {
      _handleError(e, emit as Emitter<UserState>);
    }
  }

  Future<void> onUserFetched() async {
    UsersLoaded usersLoaded = state as UsersLoaded;
    if (usersLoaded.hasReachedMax) return;
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      final response = await _dio.get(
        AppUrl.users,
        options: Options(
          headers: {'Authorization': 'Bearer ${userLoggedIn.accessToken}'},
        ),
        queryParameters: {'offset': '${usersLoaded.users.length}'},
      );
      if (response.statusCode == 200) {
        Users newUser = Users.fromJson(response.data);
        newUser.users.isEmpty
            ? emit(
                UsersLoaded(
                  users: usersLoaded.users,
                  hasReachedMax: true,
                  total: newUser.total!,
                ),
              )
            : emit(
                UsersLoaded(
                  users: usersLoaded.users + newUser.users,
                  hasReachedMax: false,
                  total: newUser.total!,
                ),
              );
      } else {
        _handleError(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
          ),
          emit as Emitter<UserState>,
        );
      }
    } on DioException catch (e) {
      _handleError(e, emit as Emitter<UserState>);
    }
  }

  Future<void> onUserSearch(String lastSearchTerm) async {
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      final response = await _dio.get(
        AppUrl.users,
        options: Options(
          headers: {'Authorization': 'Bearer ${userLoggedIn.accessToken}'},
        ),
        queryParameters: {'offset': '0', 'search': lastSearchTerm},
      );
      if (response.statusCode == 200) {
        Users users = Users.fromJson(response.data);
        emit(
          UsersLoaded(
            users: users.users,
            hasReachedMax: true,
            total: users.total!,
          ),
        );
      } else {
        _handleError(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
          ),
          emit as Emitter<UserState>,
        );
      }
    } on DioException catch (e) {
      _handleError(e, emit as Emitter<UserState>);
    }
  }

  Future<void> beforeAddUser() async {
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      final response = await _dio.get(
        AppUrl.beforeAddUser,
        options: Options(
          headers: {'Authorization': 'Bearer ${userLoggedIn.accessToken}'},
        ),
      );
      if (response.statusCode == 200) {
        InstancesRoles instancesRoles = InstancesRoles.fromJson(response.data);
        emit(BeforeAddUser(instancesRoles));
      } else {
        _handleError(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
          ),
          emit as Emitter<UserState>,
        );
      }
    } on DioException catch (e) {
      _handleError(e, emit as Emitter<UserState>);
    }
  }

  Future<void> addUser(User user, String password) async {
    emit(UserLoading());
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      await _dio.post(
        AppUrl.addUser,
        options: Options(
          headers: {'Authorization': 'Bearer ${userLoggedIn.accessToken}'},
        ),
        data: {
          "nama": user.nama,
          "email": user.email,
          "password": password,
          "role_id": "${user.roleId}",
          "instance_id": "${user.instanceId}",
        },
      );
      emit(UserSubmitted());
    } on DioException catch (e) {
      _handleError(e, emit as Emitter<UserState>);
    }
  }

  Future<void> editUser(User user, String password) async {
    emit(UserLoading());
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      await _dio.put(
        '${AppUrl.editUser}/${user.id}',
        options: Options(
          headers: {'Authorization': 'Bearer ${userLoggedIn.accessToken}'},
        ),
        data: {
          "nama": user.nama,
          "email": user.email,
          "password": password,
          "role_id": "${user.roleId}",
          "instance_id": "${user.instanceId}",
        },
      );
      emit(UserSubmitted());
    } on DioException catch (e) {
      _handleError(e, emit as Emitter<UserState>);
    }
  }

  Future<void> editUserOnly(User user) async {
    emit(UserLoading());
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      await _dio.patch(
        '${AppUrl.editUserOnly}/${user.id}',
        options: Options(
          headers: {'Authorization': 'Bearer ${userLoggedIn.accessToken}'},
        ),
        data: {
          "nama": user.nama,
          "email": user.email,
          "role_id": "${user.roleId}",
          "instance_id": "${user.instanceId}",
        },
      );
      emit(UserSubmitted());
    } on DioException catch (e) {
      _handleError(e, emit as Emitter<UserState>);
    }
  }

  Future<void> changePassword(int userId, String password) async {
    emit(UserLoading());
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      await _dio.patch(
        '${AppUrl.changePassword}/$userId',
        options: Options(
          headers: {'Authorization': 'Bearer ${userLoggedIn.accessToken}'},
        ),
        data: {"password": password},
      );
      await LocalStorage.clear();
      // TODO: changed ?
      emit(UserChanged());
    } on DioException catch (e) {
      _handleError(e, emit as Emitter<UserState>);
    }
  }

  Future<void> deleteUser(int id) async {
    emit(UserLoading());
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      await _dio.delete(
        AppUrl.users,
        options: Options(
          headers: {'Authorization': 'Bearer ${userLoggedIn.accessToken}'},
        ),
        data: {"id": id},
      );
      emit(UserSubmitted());
    } on DioException catch (e) {
      _handleError(e, emit as Emitter<UserState>);
    }
  }

  Future<void> disable2FA(String userId) async {
    emit(UserLoading());
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      await _dio.get(
        '${AppUrl.disable2FA}/$userId',
        options: Options(
          headers: {'Authorization': 'Bearer ${userLoggedIn.accessToken}'},
        ),
      );
      emit(UserSubmitted());
    } on DioException catch (e) {
      _handleError(e, emit as Emitter<UserState>);
    }
  }

  Future<void> generate2FASecret() async {
    emit(UserLoading());
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      final response = await _dio.get(
        AppUrl.generate2FASecret,
        options: Options(
          headers: {'Authorization': 'Bearer ${userLoggedIn.accessToken}'},
        ),
      );
      emit(TwoFASecretGenerated(TwoFASecret.fromJson(response.data)));
    } on DioException catch (e) {
      _handleError(e, emit as Emitter<UserState>);
    }
  }

  Future<void> verifyAndEnable2FA(String code) async {
    emit(UserLoading());
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      await _dio.post(
        AppUrl.verifyEnable2FA,
        options: Options(
          headers: {'Authorization': 'Bearer ${userLoggedIn.accessToken}'},
        ),
        data: {"code": code},
      );
      emit(UserSubmitted());
    } on DioException catch (e) {
      _handleError(e, emit as Emitter<UserState>);
    }
  }

  Future<void> verifyTwoFAResetPassword(String email, String code) async {
    emit(UserLoading());
    try {
      final response = await _dio.post(
        AppUrl.verify2FAReset,
        data: {"email": email, "code": code},
      );
      emit(ResetTokenReceived(response.data['reset_token']));
    } on DioException catch (e) {
      _handleError(e, emit as Emitter<UserState>);
    }
  }

  Future<void> resetPassword(
    String email,
    String password,
    String resetToken,
  ) async {
    try {
      await _dio.post(
        AppUrl.verify2FAReset,
        data: {"email": email, "password": password, "reset_token": resetToken},
      );
      emit(UserSubmitted());
    } on DioException catch (e) {
      _handleError(e, emit as Emitter<UserState>);
    }
  }
}
