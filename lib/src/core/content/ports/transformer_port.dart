import 'package:dart_either/dart_either.dart';
import 'package:scm_device/src/core/content/content.dart';
import 'package:scm_device/src/core/shared/device_error.dart';

abstract class TransformerPort {
  Future<Either<DeviceError, bool>> transform(Content? content);
}