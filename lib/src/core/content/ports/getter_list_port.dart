import 'package:dart_either/dart_either.dart';
import 'package:scm_device/src/core/content/content.dart';
import 'package:scm_device/src/core/shared/device_error.dart';
import 'package:scm_device/src/core/token/token.dart';

abstract class GetterListPort {
  Future<Either<DeviceError, List<Content>>>get(
    Token token
  );
}