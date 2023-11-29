import 'package:dio/dio.dart';
import 'package:dart_either/dart_either.dart';
import 'package:scm_device/src/core/content/content.dart';
import 'package:scm_device/src/core/content/ports/getter_list_port.dart';
import 'package:scm_device/src/core/shared/device_error.dart';
import 'package:scm_device/src/core/token/token.dart';
import 'package:path/path.dart';
import 'dart:io';

typedef GettingContentListHttpAdapter = GettingListAdapter;

class GettingListAdapter implements GetterListPort {
  final String url;
  final Dio dio;

  GettingListAdapter(this.url, this.dio);
  
  @override
  Future<Either<DeviceError, List<Content>>> get(Token token) async {
    var options = Options(
      headers: {
        "Cookie": "access-token=${token.access}"
      }
    );

    try {
      final Response response = await dio.get(
        url, options: options
      );

      final Map responseBody = response.data;

      if (responseBody.isEmpty) {
        return Left(DeviceError("Не удалось получить плэйлист с сервера, ошибка парсинга"));
      }

      if (responseBody.containsKey("contents") == false) {
        return Left(DeviceError("Не удалось получить плэйлист с сервера, ошибка парсинга"));
      }

      if ((responseBody["contents"] is List) == false) {
        return Left(DeviceError("Не удалось получить плэйлист с сервера, ошибка парсинга"));
      }

      final List<Content> list = [];

      for (var content in responseBody["contents"]){
        if ((content is Map) == false) {
          return Left(DeviceError("Не удалось получить плэйлист с сервера, ошибка парсинга"));
        }

        if (content.containsKey("id") == false) {
          return Left(DeviceError("Не удалось получить плэйлист с сервера, ошибка парсинга"));
        }

        if (content.containsKey("displayDuration") == false) {
          return Left(DeviceError("Не удалось получить плэйлист с сервера, ошибка парсинга"));
        }

        if (content.containsKey("file") == false) {
          return Left(DeviceError("Не удалось получить плэйлист с сервера, ошибка парсинга"));
        }

        if ((content["file"] is Map) == false) {
          return Left(DeviceError("Не удалось получить плэйлист с сервера, ошибка парсинга"));
        }

        if (content["file"].containsKey("url") == false) {
          return Left(DeviceError("Не удалось получить плэйлист с сервера, ошибка парсинга"));
        }

        final File file = File(content["file"]["url"]);
        final filename = basename(file.path);

        list.add(Content(
          content["id"], 
          content["displayDuration"], 
          content["file"]["url"], 
          filename,
          '',
          '',
          []
        ));
      }

      return Right(list); 
    } on DioException catch (_) {
      return Left(DeviceError("Не удалось получить плэйлист с сервера"));
    } catch (e) {
      return Left(DeviceError("Не удалось получить плэйлист с сервера, ошибка парсинга"));
    }
  }
}