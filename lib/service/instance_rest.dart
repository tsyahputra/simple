import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:simple/model/instance.dart';
import 'package:simple/service/constants.dart';
import 'package:simple/service/local_storage.dart';

class InstanceRest {
  final Dio _dio = Dio();

  Future<Instances> getAllInstances(int offset, String lastSearchTerm) async {
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    final response = await _dio.get(
      AppUrl.instances,
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
      return Instances.fromJson(response.data);
    } else {
      return Instances(instances: [], total: 0);
    }
  }

  Future<Either<String, Instance>> viewInstance(int instanceId) async {
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      final response = await _dio.get(
        '${AppUrl.viewInstance}/$instanceId',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${userLoggedIn.accessToken}',
          },
        ),
      );
      return Right(Instance.fromJson(response.data));
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(e.response!.data['message']);
      } else {
        return const Left('Connection time out.');
      }
    }
  }

  Future<Either<String, bool>> addInstance(Instance instance) async {
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      await _dio.post(
        AppUrl.addInstance,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${userLoggedIn.accessToken}',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'nama': instance.nama,
          'alamat': instance.alamat,
          'kabupaten': instance.kabupaten,
          'provinsi': instance.provinsi,
          'telp': instance.telp,
          'email': instance.email,
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

  Future<Either<String, bool>> editInstance(Instance instance) async {
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      await _dio.put(
        '${AppUrl.editInstance}/${instance.id}',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${userLoggedIn.accessToken}',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'nama': instance.nama,
          'alamat': instance.alamat,
          'kabupaten': instance.kabupaten,
          'provinsi': instance.provinsi,
          'telp': instance.telp,
          'email': instance.email,
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

  Future<Either<String, bool>> deleteInstance(int id) async {
    final userLoggedIn = await LocalStorage.getUserLoggedIn();
    try {
      await _dio.delete(
        AppUrl.instances,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${userLoggedIn.accessToken}',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          "id": id,
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
}
