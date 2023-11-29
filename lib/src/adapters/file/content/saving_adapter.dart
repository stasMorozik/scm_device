import 'dart:io';
import 'package:dart_either/dart_either.dart';
import 'package:scm_device/src/core/content/content.dart';
import 'package:scm_device/src/core/content/ports/transformer_port.dart';
import 'package:scm_device/src/core/shared/device_error.dart';

typedef SavingContentFileSystemAdapter = SavingAdapter;

class SavingAdapter implements TransformerPort {
  SavingAdapter();
  
  @override
  Future<Either<DeviceError, bool>> transform(Content? content) async {
    var bool = await Directory(content!.dir).exists();

    if (!bool) {
      await Directory(content.dir).create(recursive: true);
    }

    var file = File(content.path);

    await file.writeAsBytes(content.binary);

    return const Right(true);
  }
}