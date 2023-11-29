import 'dart:io';
import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:scm_device/src/core/token/token.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:scm_device/src/core/token/features/getting.dart';
import 'package:scm_device/src/adapters/file/content/saving_adapter.dart';
import 'package:scm_device/src/adapters/http/content/getting_binary_adapter.dart';
import 'package:scm_device/src/adapters/http/content/getting_list_adapter.dart';
import 'package:scm_device/src/adapters/http/token/updating_adapter.dart';
import 'package:scm_device/src/adapters/sqlite/content/deleting_adapter.dart';
import 'package:scm_device/src/adapters/sqlite/content/inserting_adapter.dart';
import 'package:scm_device/src/adapters/sqlite/token/getting_adapter.dart';
import 'package:scm_device/src/adapters/sqlite/token/updating_adapter.dart';
import 'package:scm_device/src/core/content/features/saving.dart';
import 'package:scm_device/src/core/token/features/refreshing.dart';

run(SendPort _) async {
  const idDevice = String.fromEnvironment("ID");
  const urlRefreshToken = String.fromEnvironment("URL_REFRESH_TOKEN");
  const urlGettingListContent = String.fromEnvironment("URL_GETTING_CONTENT_LIST");
  const contentDir = String.fromEnvironment("CONTENT_DIR");
  const webDavUser = String.fromEnvironment("WEB_DAV_USER");
  const webDavPassword = String.fromEnvironment("WEB_DAV_PASSWORD");
  const dbPath = String.fromEnvironment("DB_PATH");
  
  final database = sqlite3.open(dbPath, mutex: false);
  final dio = Dio();

  final adapter_0 = GettingTokenSQLiteAdapter(database);
  final adapter_1 = UpdatingTokenHttpAdapter(urlRefreshToken, dio);
  final adapter_2 = UpdatingTokenSQLiteAdapter(database);

  final feature_0 = Refreshing(
    adapter_0,
    adapter_1,
    adapter_2
  );
  final adapter_3 = GettingContentListHttpAdapter(
    '$urlGettingListContent/$idDevice', 
    dio
  );
  final adapter_4 = GettingContentBinaryHttpAdapter(
    webDavUser, 
    webDavPassword, 
    dio
  );
  final adapter_5 = SavingContentFileSystemAdapter();
  final adapter_6 = InsertingContentSQLiteAdapter(database);
  final adapter_7 = DeletingContentSQLiteAdapter(database);
  final feature_1 = Saving(
    feature_0, 
    adapter_3, 
    adapter_4, 
    adapter_5, 
    adapter_6,
    adapter_7,
    contentDir
  );
  final feature_2 = Getting(adapter_0);

  connect(feature_2, feature_0, feature_1);
}

connect(
  Getting featureGettingToken, 
  Refreshing featureRefreshingToken, 
  Saving featureSavingContent
) async {
  stderr.writeln("Попытка получить токен из локальной базы данных");
  final either = await featureGettingToken.get();

  either.mapLeft(
    (error) => stderr.writeln(error.message)
  );

  either.map(
    (value) async => {
      stderr.writeln("Получен токен из локальной базы данных"),
      await connector(value, featureGettingToken, featureRefreshingToken, featureSavingContent)
    }
  );
}

connector(
  Token token,
  Getting featureGettingToken, 
  Refreshing featureRefreshingToken, 
  Saving featureSavingContent
) async {
  const urlWebsocket = String.fromEnvironment("URL_WEBSOCKET");
  const idDevice = String.fromEnvironment("ID");

  final wsUrl = Uri.parse('$urlWebsocket/$idDevice?token=${token.access}');
  final channel = WebSocketChannel.connect(wsUrl);

  try {
    await channel.ready;
    stdout.writeln("Успешный коннект");
  } catch(e) {
    stderr.writeln("Не получилось установить соеденение, засыпаю на 180 секунд");
    sleep(const Duration(seconds: 180));
    stdout.writeln("Попытка обновить токен");
    featureRefreshingToken.refresh().then(
      (either) => {
        either.map(
          (value) => {
            stdout.writeln("Токен обновлен"),
            stdout.writeln("Попытка реконнекта"),
            connect(
              featureGettingToken, 
              featureRefreshingToken, 
              featureSavingContent
            )
          }
        ),
        either.mapLeft(
          (error) => stderr.writeln(error.message)
        )
      }
    );
  }

  channel.stream.listen(
    (message) {
      stdout.writeln("Попытка сохранить контент");
      featureSavingContent.save().then(
        (either) => {
          either.map(
            (value) => stdout.writeln("Сохранен контент")
          ),
          either.mapLeft(
            (error) => stderr.writeln(error.message)
          )
        }
      );
    },
    onError: (error) {
      stderr.writeln("Обрыв соединения, засыпаю на 180 секунд");
      sleep(const Duration(seconds: 180));
      stdout.writeln("Попытка обновить токен");
      featureRefreshingToken.refresh().then(
        (either) => {
          either.map(
            (value) =>  {
              stdout.writeln("Токен обновлен"),
              stdout.writeln("Попытка реконнекта"),
              connect(
                featureGettingToken, 
                featureRefreshingToken, 
                featureSavingContent,
              )
            }
          ),
          either.mapLeft(
            (error) => stderr.writeln(error.message)
          )
        }
      );
    },
    onDone: () {
      stderr.writeln("Обрыв соединения, засыпаю на 180 секунд");
      sleep(const Duration(seconds: 180));
      stdout.writeln("Попытка обновить токен");
      featureRefreshingToken.refresh().then(
        (either) => {
          either.map(
            (value) =>  {
              stdout.writeln("Токен обновлен"),
              stdout.writeln("Попытка реконнекта"),
              connect(
                featureGettingToken, 
                featureRefreshingToken, 
                featureSavingContent
              )
            }
          ),
          either.mapLeft(
            (error) => stderr.writeln(error.message)
          )
        }
      );
    },
  );
}