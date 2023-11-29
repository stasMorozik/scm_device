import 'package:dart_either/dart_either.dart';
import 'package:scm_device/src/core/content/content.dart';
import 'package:scm_device/src/core/content/ports/transformer_port.dart';
import 'package:scm_device/src/core/shared/device_error.dart';
import 'package:sqlite3/sqlite3.dart';

typedef InsertingContentSQLiteAdapter = InsertingAdapter;

class InsertingAdapter implements TransformerPort {
  final Database db;

  InsertingAdapter(this.db);

  @override
  Future<Either<DeviceError, bool>> transform(Content? content) async {
    
    var stm = db.prepare('''
      INSERT OR REPLACE INTO contents(
        id, 
        displayDuration, 
        url, 
        name, 
        dir, 
        path,
        isNew
      ) VALUES(
        (?), 
        (?), 
        (?),
        (?),
        (?),
        (?),
        (?)
      )
    ''');

    stm.execute([
      content?.id, 
      content?.displayDuration, 
      content?.url,
      content?.name,
      content?.dir,
      content?.path,
      1
    ]);

    return Future(() => const Right(true));
  }
}