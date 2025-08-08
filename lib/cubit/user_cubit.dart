import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:get_ip_address/get_ip_address.dart';
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

  Future<void> onUserInit(String lastSearchTerm) async {
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      final response = await _dio.get(
        AppUrl.users,
        options: Options(
          headers: {'Authorization': 'Bearer ${userLoggedIn.accessToken}'},
        ),
        queryParameters: {
          'offset': '0',
          if (lastSearchTerm != '') 'search': lastSearchTerm,
        },
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

  Future<void> masuk(String email, String password, String fcmToken) async {
    emit(UserLoading());
    try {
      var ipAddress = IpAddress(type: RequestType.json);
      dynamic ipData = await ipAddress.getIpAddress();
      final response = await _dio.post(
        AppUrl.masuk,
        data: {
          'email': email,
          'password': password,
          'fcm_token': fcmToken,
          'ip': ipData['ip'],
        },
      );
      if (response.statusCode == 200) {
        UserLoggedIn userLoggedIn = UserLoggedIn.fromJson(response.data);
        await LocalStorage.setUserProfile(userLoggedIn);
        emit(UserAuthenticated(userLoggedIn: userLoggedIn));
      } else {
        emit(UserFail(response.data['message']));
      }
    } on DioException catch (e) {
      _handleError(e, emit as Emitter<UserState>);
    }
  }

  Future<void> verifyCaptcha() async {
    emit(UserLoading());
    try {
      var ipAddress = IpAddress(type: RequestType.json);
      dynamic ipData = await ipAddress.getIpAddress();
      final response = await _dio.post(
        AppUrl.verifyCaptcha,
        data: {'ip': ipData['ip']},
      );
      if (response.statusCode == 200) {
        emit(UserVerified());
      } else {
        emit(CaptchaFail(response.data['message']));
      }
    } on DioException catch (e) {
      _handleError(e, emit as Emitter<UserState>);
    }
  }
}
