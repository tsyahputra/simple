import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:get_ip_address/get_ip_address.dart';
import 'package:simple/model/user.dart';
import 'package:simple/service/constants.dart';
import 'package:simple/service/local_storage.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final Dio _dio = Dio();

  Future<void> masuk(String email, String password, String fcmToken) async {
    emit(AuthLoading());
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
        emit(AuthFail(response.data['message']));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        emit(AuthFail(e.response!.data['message']));
      } else {
        emit(AuthFail('Connection time out.'));
      }
    }
  }

  Future<void> verifyCaptcha() async {
    var ipAddress = IpAddress(type: RequestType.json);
    dynamic ipData = await ipAddress.getIpAddress();
    final response = await _dio.post(
      AppUrl.verifyCaptcha,
      data: {'ip': ipData['ip']},
    );
    if (response.statusCode != 200) {
      emit(CaptchaFail(response.data['message']));
    }
  }

  Future<void> checkAuthStatus() async {
    UserLoggedIn userLoggedIn = await LocalStorage.getUserLoggedIn();
    if (userLoggedIn.accessToken != '') {
      emit(UserAuthenticated(userLoggedIn: userLoggedIn));
    } else {
      await LocalStorage.clear();
      emit(UserUnauthenticated());
    }
  }

  Future<void> keluar() async {
    emit(AuthLoading());
    await LocalStorage.clear();
    emit(UserUnauthenticated());
  }
}
