import 'package:dart_either/dart_either.dart';
import 'package:scm_device/src/core/content/content.dart';
import 'package:scm_device/src/core/content/ports/getter_list_port.dart';
import 'package:scm_device/src/core/content/ports/getter_binary_port.dart';
import 'package:scm_device/src/core/content/ports/transformer_port.dart';
import 'package:scm_device/src/core/shared/device_error.dart';
import 'package:scm_device/src/core/token/features/refreshing.dart';
import 'package:scm_device/src/core/token/token.dart';

class Saving {
  final Refreshing refreshingTokenFeature;
  final GetterListPort getterContentList;
  final GetterBinaryPort gettBinaryContent;
  final TransformerPort transformerFile;
  final TransformerPort transformerStorageInserting;
  final TransformerPort transformerStorageDeleting;
  final String dirName;

  Saving(
    this.refreshingTokenFeature,
    this.getterContentList,
    this.gettBinaryContent,
    this.transformerFile,
    this.transformerStorageInserting,
    this.transformerStorageDeleting,
    this.dirName
  );

  Future<Either<DeviceError, bool>>save() async {
    var f_0 = refreshingTokenFeature.getter.get();

    var f_1 = f_0.thenFlatMapEither(
      (token) => getterContentList.get(token).then(
        (either) => either.map((list) => {token, list})
      )
    );

    var f_2 = f_1.then(
      (e_0) => e_0.fold(
        ifLeft: (_) =>  refreshingTokenFeature.refresh()
        .thenFlatMapEither(
          (_) => refreshingTokenFeature.getter.get()
        ).thenFlatMapEither(
          (token) => getterContentList.get(token).thenFlatMapEither(
            (list) => Right({token, list})
          )
        ), 
        ifRight: (value) => Future.value(value).toEitherFuture((e, s) => DeviceError(""))
      )
    );

    var f_3 = f_2.thenFlatMapEither(
      (set) async => await Future.wait(
        (set.last as List<Content>).map(
          (content) => gettBinaryContent.get(set.first as Token, content).thenFlatMapEither(
            (binary) => Right( Content(
              content.id, 
              content.displayDuration, 
              content.url, 
              content.name,
              content.dir, 
              content.path, 
              binary
            ) )
          )
        )
      ).then(
        (eithers) => Either.sequence(eithers)
      )
    );

    var now = DateTime.now();
    var year = now.year.toString();
    var month = now.month.toString();
    var day = now.day.toString();
    var hours = now.hour.toString();
    var minute = now.minute.toString();
    var second = now.second.toString();

    var todayDirName = '$year-$month-$day-$hours-$minute-$second';

    var f_4 = f_3.thenFlatMapEither(
      (list) async => await Future.wait(
        list.map(
          (content) => Content(
            content.id, 
            content.displayDuration, 
            content.url, 
            content.name,
            '$dirName/$todayDirName/${content.id}/', 
            '$dirName/$todayDirName/${content.id}/${content.name}',
            content.binary
          )
        ).map(
          (content) => transformerFile.transform(content).thenFlatMapEither(
            (_) => Right( Content(
              content.id, 
              content.displayDuration, 
              content.url, 
              content.name,
              content.dir,
              content.path,
              []
            ) )
          )
        )
      ).then(
        (eithers) => Either.sequence(eithers)
      )
    );

    var f_5 = f_4.thenFlatMapEither(
      (list) async => await Future.wait(
        list.map(
          (content) => transformerStorageInserting.transform(content)
        )
      ).then(
        (eithers) => Either.sequence(eithers)
      )
    );

    var f_6 = f_5.thenFlatMapEither(
      (list) => transformerStorageDeleting.transform(null)
    );

    return f_6.thenFlatMapEither((value) => const Right(true));
  }
}