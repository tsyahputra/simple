import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:get_ip_address/get_ip_address.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
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
          'Authorization': 'Bearer ${userLoggedIn.token}',
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
            'Authorization': 'Bearer ${userLoggedIn.token}',
          },
        ),
      );
      return Right(InstancesRoles.fromJson(response.data));
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.response!.data['message']);
      } else {
        return const Left('Connection time out.');
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
            'Authorization': 'Bearer ${userLoggedIn.token}',
          },
        ),
      );
      return Right(User.fromJson(response.data));
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.response!.data['message']);
      } else {
        return const Left('Connection time out.');
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
            'Authorization': 'Bearer ${userLoggedIn.token}',
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
      return const Right(true);
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.response!.data['message']);
      } else {
        return const Left('Connection time out.');
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
            'Authorization': 'Bearer ${userLoggedIn.token}',
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
      return const Right(true);
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.response!.data['message']);
      } else {
        return const Left('Connection time out.');
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
            'Authorization': 'Bearer ${userLoggedIn.token}',
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
      return const Right(true);
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.response!.data['message']);
      } else {
        return const Left('Connection time out.');
      }
    }
  }

  Future<Either<String, bool>> changePassword(
    int userId,
    String password,
  ) async {
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      final response = await _dio.patch(
        '${AppUrl.changePassword}/$userId',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${userLoggedIn.token}',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          "password": password,
        },
      );
      if (response.statusCode == 200) {
        await LocalStorage.clear();
        return const Right(true);
      } else {
        return Left(response.data['message']);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.response!.data['message']);
      } else {
        return const Left('Connection time out.');
      }
    }
  }

  Future<Either<String, bool>> deleteUser(String id) async {
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      await _dio.delete(
        AppUrl.users,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${userLoggedIn.token}',
            'Content-Type': 'application/json',
          },
        ),
        data: {"id": id},
      );
      return const Right(true);
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.response!.data['message']);
      } else {
        return const Left('Connection time out.');
      }
    }
  }

  Future<Either<String, UserLoggedIn>> masuk(
      String email, String password) async {
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
        return const Left('Connection time out.');
      }
    }
  }

  Future<Either<String, UserLoggedIn>> getUserLoggedIn() async {
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    if (userLoggedIn.token == '') {
      return const Left('Silahkan login terlebih dahulu.');
    }
    bool hasExpired = JwtDecoder.isExpired(userLoggedIn.token!);
    if (!hasExpired) {
      return Right(userLoggedIn);
    } else {
      return const Left('Sesi anda telah berakhir. Silahkan login kembali.');
    }
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
        data: {
          'ip': ipData['ip'],
        },
      );
      if (response.statusCode == 200) {
        return const Right(true);
      } else {
        return Left(response.statusMessage!);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.response!.data['message']);
      } else {
        return const Left('Connection time out.');
      }
    }
  }
}
