import 'package:dart_either/dart_either.dart';
import 'package:scm_device/src/core/shared/device_error.dart';
import 'package:scm_device/src/core/token/ports/getters/getter_port.dart';
import 'package:scm_device/src/core/token/token.dart';
import 'package:sqlite3/sqlite3.dart';

typedef GettingTokenSQLiteAdapter = GettingAdapter;

class GettingAdapter implements GetterPort {
  final Database db;

  GettingAdapter(this.db);
  
  @override
  Future<Either<DeviceError, Token>> get() async {
    final ResultSet result = db.select('SELECT * FROM token');

    if (result.isEmpty) {
      return Left(DeviceError("Токен не найден")); 
    }

    return Right(Token(result[0]["access"], result[0]["refresh"]));
  }
}