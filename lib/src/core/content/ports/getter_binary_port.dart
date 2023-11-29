import 'package:dart_either/dart_either.dart';
import 'package:scm_device/src/core/content/content.dart';
import 'package:scm_device/src/core/shared/device_error.dart';
import 'package:scm_device/src/core/token/token.dart';

abstract class GetterBinaryPort {
  Future<Either<DeviceError, List<int>>>get(
    Token token, 
    Content content
  );
}