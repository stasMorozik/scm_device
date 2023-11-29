import 'package:dart_either/dart_either.dart';
import 'package:scm_device/src/core/shared/device_error.dart';
import 'package:scm_device/src/core/token/ports/transformers/transformer_port.dart';
import 'package:scm_device/src/core/token/token.dart';
import 'package:dio/dio.dart';
import 'dart:io';

typedef UpdatingTokenHttpAdapter = UpdatingAdapter;

class UpdatingAdapter implements TransformerPort {
  final String url;
  final Dio dio;

  UpdatingAdapter(this.url, this.dio);
  
  @override
  Future<Either<DeviceError, Token>> transform(Token token) async{
    var options = Options(
      headers: {
        "Cookie": "refresh-token=${token.refresh}"
      },
    );

    try {
      final Response response = await dio.put(
        url, options: options
      );
      
      final cookies = response.headers.map['set-cookie'];

      if (cookies == null) {
        return Left(DeviceError("Не удалось обновить токен на сервере"));
      }

      if (cookies.isEmpty) {
        return Left(DeviceError("Не удалось обновить токен на сервере"));
      }

      if (cookies.length < 2) {
        return Left(DeviceError("Не удалось обновить токен на сервере"));
      }

      var maybeAccessTokenHeader = cookies[0];
      var maybeRefreshTokenHeader = cookies[1];

      var maybeAccessTokenCookie = Cookie.fromSetCookieValue(maybeAccessTokenHeader);
      var maybeRefreshTokenCookie = Cookie.fromSetCookieValue(maybeRefreshTokenHeader);

      var accessTokenString = '';
      var refreshTokenString = '';

      if (maybeAccessTokenCookie.name == 'access-token') {
        accessTokenString = maybeAccessTokenCookie.value;
      }

      if (maybeAccessTokenCookie.name == 'refresh-token') {
        refreshTokenString = maybeAccessTokenCookie.value;
      }

      if (maybeRefreshTokenCookie.name == 'access-token') {
        accessTokenString = maybeAccessTokenCookie.value;
      }

      if (maybeRefreshTokenCookie.name == 'refresh-token') {
        refreshTokenString = maybeAccessTokenCookie.value;
      }

      if (accessTokenString.isEmpty || refreshTokenString.isEmpty) {
        return Left(DeviceError("Не удалось обновить токен на сервере"));
      }

      return Right(Token(accessTokenString, refreshTokenString));
    } on DioException catch (_) {
      return Left(DeviceError("Не удалось обновить токен на сервере"));
    }
  }
}