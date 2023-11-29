import 'package:dart_either/dart_either.dart';
import 'package:scm_device/src/core/shared/device_error.dart';
import 'package:scm_device/src/core/token/ports/getters/getter_port.dart';
import 'package:scm_device/src/core/token/token.dart';

class Getting {
  final GetterPort getter;

  Getting(this.getter);

  Future<Either<DeviceError, Token>> get() {
    return getter.get();
  }
}