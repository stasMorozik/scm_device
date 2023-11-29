import 'package:dart_either/dart_either.dart';
import 'package:scm_device/src/core/shared/device_error.dart';
import 'package:scm_device/src/core/token/ports/transformers/transformer_port.dart';
import 'package:scm_device/src/core/token/token.dart';
import 'package:sqlite3/sqlite3.dart';

typedef UpdatingTokenSQLiteAdapter = UpdatingAdapter;

class UpdatingAdapter implements TransformerPort {
  final Database db;

  UpdatingAdapter(this.db);
  
  @override
  Future<Either<DeviceError, Token>> transform(Token token) async {
    final ResultSet result = db.select('SELECT * FROM token');

    if (result.isEmpty) {
      var stm = db.prepare('''
        INSERT INTO token(
          access, 
          refresh
        ) VALUES(
          (?), 
          (?)
        )
      ''');

      stm.execute([token.access, token.refresh]);

      return Right(token);
    }


    var stm = db.prepare(
      '''UPDATE token SET access = (?), refresh = (?)'''
    );

    stm.execute([token.access, token.refresh]);

    return Right(token);
  }
}