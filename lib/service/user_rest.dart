import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:get_ip_address/get_ip_address.dart';
import 'package:simple/model/role.dart';
import 'package:simple/model/user.dart';
import 'package:simple/service/constants.dart';
import 'package:simple/service/local_storage.dart';

class UserRest {
  final Dio _dio = Dio();

  Future<Users> getAllUsers(int offset, String lastSearchTerm) async {
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    final response = await _dio.get(
      AppUrl.users,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${userLoggedIn.accessToken}',
        },
      ),
      queryParameters: {
        'offset': '$offset',
        if (lastSearchTerm != '') 'search': lastSearchTerm,
      },
    );
    if (response.statusCode == 200) {
      return Users.fromJson(response.data);
    } else {
      return Users(users: [], total: 0);
    }
  }

  Future<Either<String, InstancesRoles>> beforeAddUser() async {
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      final response = await _dio.get(
        AppUrl.beforeAddUser,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${userLoggedIn.accessToken}',
          },
        ),
      );
      return Right(InstancesRoles.fromJson(response.data));
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.response!.data['message']);
      } else {
        return Left('Connection time out.');
      }
    }
  }

  Future<Either<String, User>> viewUser(int userId) async {
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      final response = await _dio.get(
        '${AppUrl.viewUser}/$userId',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${userLoggedIn.accessToken}',
          },
        ),
      );
      return Right(User.fromJson(response.data));
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.response!.data['message']);
      } else {
        return Left('Connection time out.');
      }
    }
  }

  Future<Either<String, bool>> addUser(User user, String password) async {
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      await _dio.post(
        AppUrl.addUser,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${userLoggedIn.accessToken}',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          "nama": user.nama,
          "email": user.email,
          "password": password,
          "role_id": "${user.roleId}",
          "instance_id": "${user.instanceId}",
        },
      );
      return Right(true);
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.response!.data['message']);
      } else {
        return Left('Connection time out.');
      }
    }
  }

  Future<Either<String, bool>> editUser(User user, String password) async {
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      await _dio.put(
        '${AppUrl.editUser}/${user.id}',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${userLoggedIn.accessToken}',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          "nama": user.nama,
          "email": user.email,
          "password": password,
          "role_id": "${user.roleId}",
          "instance_id": "${user.instanceId}",
        },
      );
      return Right(true);
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.response!.data['message']);
      } else {
        return Left('Connection time out.');
      }
    }
  }

  Future<Either<String, bool>> editUserOnly(User user) async {
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      await _dio.patch(
        '${AppUrl.editUserOnly}/${user.id}',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${userLoggedIn.accessToken}',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          "nama": user.nama,
          "email": user.email,
          "role_id": user.roleId,
          "instance_id": user.instanceId,
        },
      );
      return Right(true);
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.response!.data['message']);
      } else {
        return Left('Connection time out.');
      }
    }
  }

  Future<Either<String, bool>> changePassword(
    int userId,
    String password,
  ) async {
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      await _dio.patch(
        '${AppUrl.changePassword}/$userId',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${userLoggedIn.accessToken}',
            'Content-Type': 'application/json',
          },
        ),
        data: {"password": password},
      );
      await LocalStorage.clear();
      return Right(true);
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.response!.data['message']);
      } else {
        return Left('Connection time out.');
      }
    }
  }

  Future<Either<String, bool>> deleteUser(int id) async {
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      await _dio.delete(
        AppUrl.users,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${userLoggedIn.accessToken}',
            'Content-Type': 'application/json',
          },
        ),
        data: {"id": id},
      );
      return Right(true);
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.response!.data['message']);
      } else {
        return Left('Connection time out.');
      }
    }
  }

  Future<Either<String, UserLoggedIn>> masuk(
    String email,
    String password,
    String fcmToken,
  ) async {
    try {
      var ipAddress = IpAddress(type: RequestType.json);
      dynamic ipData = await ipAddress.getIpAddress();
      final response = await _dio.post(
        AppUrl.masuk,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'email': email,
          'password': password,
          'fcm_token': fcmToken,
          'ip': ipData['ip'],
        },
      );
      UserLoggedIn userLoggedIn = UserLoggedIn.fromJson(response.data);
      await LocalStorage.setUserProfile(userLoggedIn);
      return Right(userLoggedIn);
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.response!.data['message']);
      } else {
        return Left('Connection time out.');
      }
    }
  }

  Future<Either<String, UserLoggedIn>> getUserLoggedIn() async {
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    if (userLoggedIn.accessToken == '') {
      return Left('Silahkan login terlebih dahulu.');
    }
    return Right(userLoggedIn);
  }

  Future<Either<String, bool>> verifyCaptcha() async {
    try {
      var ipAddress = IpAddress(type: RequestType.json);
      dynamic ipData = await ipAddress.getIpAddress();
      final response = await _dio.post(
        AppUrl.verifyCaptcha,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
        data: {'ip': ipData['ip']},
      );
      if (response.statusCode == 200) {
        return Right(true);
      } else {
        return Left(response.statusMessage!);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.response!.data['message']);
      } else {
        return Left('Connection time out.');
      }
    }
  }

  Future<Either<String, TwoFASecret>> generate2FASecret() async {
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      final response = await _dio.get(
        AppUrl.generate2FASecret,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${userLoggedIn.accessToken}',
          },
        ),
      );
      return Right(TwoFASecret.fromJson(response.data));
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.response!.data['message']);
      } else {
        return Left('Connection time out.');
      }
    }
  }

  Future<Either<String, bool>> verifyAndEnable2FA(String code) async {
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      await _dio.post(
        AppUrl.verifyEnable2FA,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${userLoggedIn.accessToken}',
            'Content-Type': 'application/json',
          },
        ),
        data: {"code": code},
      );
      return Right(true);
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.response!.data['message']);
      } else {
        return Left('Connection time out.');
      }
    }
  }

  Future<Either<String, bool>> disable2FA(String userId) async {
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      await _dio.get(
        '${AppUrl.disable2FA}/$userId',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${userLoggedIn.accessToken}',
          },
        ),
      );
      return Right(true);
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.response!.data['message']);
      } else {
        return Left('Connection time out.');
      }
    }
  }

  Future<Either<String, String>> verifyTwoFAResetPassword(
    String email,
    String code,
  ) async {
    try {
      final response = await _dio.post(
        AppUrl.verify2FAReset,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
        data: {"email": email, "code": code},
      );
      return Right(response.data['reset_token']);
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.response!.data['message']);
      } else {
        return Left('Connection time out.');
      }
    }
  }

  Future<Either<String, bool>> resetPassword(
    String email,
    String password,
    String resetToken,
  ) async {
    try {
      await _dio.post(
        AppUrl.resetPassword,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
        data: {"email": email, "password": password, "reset_token": resetToken},
      );
      return Right(true);
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.response!.data['message']);
      } else {
        return Left('Connection time out.');
      }
    }
  }
}
