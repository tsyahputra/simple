import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:simple/model/role.dart';
import 'package:simple/service/constants.dart';
import 'package:simple/service/local_storage.dart';

class RoleRest {
  final Dio _dio = Dio();

  Future<Either<String, List<Role>>> getRoles() async {
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      final response = await _dio.get(
        AppUrl.roles,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${userLoggedIn.token}',
          },
        ),
      );
      List<Role> roles =
          List<Role>.from(response.data.map((x) => Role.fromJson(x)));
      return Right(roles);
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.response!.data['message']);
      } else {
        return const Left('Connection time out.');
      }
    }
  }

  Future<Either<String, bool>> addRole(String nama) async {
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      final response = await _dio.post(
        AppUrl.addrole,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${userLoggedIn.token}',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          "nama": nama,
        },
      );
      if (response.statusCode == 200) {
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

  Future<Either<String, bool>> editRole(Role role) async {
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      final response = await _dio.put(
        '${AppUrl.editrole}/${role.id}',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${userLoggedIn.token}',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          "nama": role.nama,
        },
      );
      if (response.statusCode == 200) {
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

  Future<Either<String, bool>> deleteRole(int id) async {
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      final response = await _dio.delete(
        AppUrl.roles,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${userLoggedIn.token}',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          "id": "$id",
        },
      );
      if (response.statusCode == 200) {
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
}
