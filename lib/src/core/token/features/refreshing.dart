import 'package:dart_either/dart_either.dart';
import 'package:scm_device/src/core/shared/device_error.dart';
import 'package:scm_device/src/core/token/ports/getters/getter_port.dart';
import 'package:scm_device/src/core/token/ports/transformers/transformer_port.dart';

class Refreshing {
  final GetterPort getter;
  final TransformerPort remoteTransformer;
  final TransformerPort storageTransformer;

  Refreshing(
    this.getter, 
    this.remoteTransformer, 
    this.storageTransformer
  );

  Future<Either<DeviceError, bool>> refresh() {
    var either_0 = getter.get().thenFlatMapEither(
      (value) => remoteTransformer.transform(value)
    );

    var either_1 = either_0.thenFlatMapEither(
      (value) => storageTransformer.transform(value)
    );

    return either_1.thenFlatMapEither(
      (value) => const Right(true)
    );
  }
}