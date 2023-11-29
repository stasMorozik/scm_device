
import 'package:dart_either/dart_either.dart';
import 'package:scm_device/src/core/content/content.dart';
import 'package:scm_device/src/core/content/ports/getter_list_port.dart';
import 'package:scm_device/src/core/shared/device_error.dart';
import 'package:scm_device/src/core/token/token.dart';

class GettingList {
  final GetterListPort getterContentList;

  GettingList(this.getterContentList);

  Future<Either<DeviceError, List<Content>>> get() {
    return getterContentList.get(Token("access", "refresh"));
  }
}