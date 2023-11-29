import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dart_either/dart_either.dart';
import 'package:scm_device/src/core/content/content.dart';
import 'package:scm_device/src/core/content/ports/getter_binary_port.dart';
import 'package:scm_device/src/core/shared/device_error.dart';
import 'package:scm_device/src/core/token/token.dart';

typedef GettingContentBinaryHttpAdapter = GettingBinaryAdapter;

class GettingBinaryAdapter implements GetterBinaryPort {
  final String user;
  final String password;
  final Dio dio;
  

  GettingBinaryAdapter(this.user, this.password, this.dio);

  @override
  Future<Either<DeviceError, List<int>>> get(Token _, Content content) async {
    var auth = base64.encode(utf8.encode('$user:$password'));

    var options = Options(
      headers: {
        'Authorization': 'Basic $auth'
      },
      responseType: ResponseType.bytes
    );

    try {
      final rs = await dio.get(content.url, options: options);

      return Right(rs.data as List<int>);
    } on DioException catch (_) {
      return Left(DeviceError("Не удалось получить файлы контента с сервера"));
    } catch (e) {
      return Left(DeviceError("Не удалось получить файлы контента с сервера, ошибка парсинга"));
    }

  }
}