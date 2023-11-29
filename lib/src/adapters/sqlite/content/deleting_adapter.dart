import 'package:dart_either/dart_either.dart';
import 'package:scm_device/src/core/content/content.dart';
import 'package:scm_device/src/core/content/ports/transformer_port.dart';
import 'package:scm_device/src/core/shared/device_error.dart';
import 'package:sqlite3/sqlite3.dart';

typedef DeletingContentSQLiteAdapter = DeletingAdapter;

class DeletingAdapter implements TransformerPort {
  final Database db;

  DeletingAdapter(this.db);

  @override
  Future<Either<DeviceError, bool>> transform(Content? content) async {

    var stm_0 = db.prepare('''
      DELETE FROM contents WHERE isNew = (?)
    ''');

    stm_0.execute([0]);

    var stm_1 = db.prepare('''
      UPDATE contents SET isNew = (?) WHERE isNew = (?)
    ''');

    stm_1.execute([0, 1]);

    return const Right(true);
  }
}