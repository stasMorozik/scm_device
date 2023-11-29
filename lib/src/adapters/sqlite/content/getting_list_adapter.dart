
import 'package:dart_either/dart_either.dart';
import 'package:scm_device/src/core/content/content.dart';
import 'package:scm_device/src/core/content/ports/getter_list_port.dart';
import 'package:scm_device/src/core/shared/device_error.dart';
import 'package:scm_device/src/core/token/token.dart';
import 'package:sqlite3/sqlite3.dart';

typedef GettingListContentSQLiteAdapter = GettingListAdapter;

class GettingListAdapter implements GetterListPort {
    final Database db;

    GettingListAdapter(this.db);

  @override
  Future<Either<DeviceError, List<Content>>> get(Token _) async {
    final ResultSet result = db.select('SELECT * FROM contents');

    if (result.isEmpty) {
      return Left(DeviceError("Контент не найден в локальной базе данных")); 
    }

    final List<Content> contents = [];

    for (final Row row in result) {
      contents.add(Content(
        row["id"], 
        row["displayDuration"], 
        row["url"], 
        row["name"], 
        row["dir"], 
        row["path"], 
        []
      ));
    }

    return Right(contents);
  }
}