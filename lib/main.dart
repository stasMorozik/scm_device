import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:scm_device/src/adapters/file/content/saving_adapter.dart';
import 'package:scm_device/src/adapters/http/content/getting_binary_adapter.dart';
import 'package:scm_device/src/adapters/http/content/getting_list_adapter.dart';
import 'package:scm_device/src/adapters/http/token/updating_adapter.dart';
import 'package:scm_device/src/adapters/sqlite/content/deleting_adapter.dart';
import 'package:scm_device/src/adapters/sqlite/content/inserting_adapter.dart';
import 'package:scm_device/src/adapters/sqlite/token/getting_adapter.dart';
import 'package:scm_device/src/applications/deamon/getting_content_list/run.dart' as gettingContentList;
import 'package:scm_device/src/applications/deamon/websocket_client/run.dart' as websocketClient;
import 'package:scm_device/src/core/content/features/saving.dart';
import 'package:scm_device/src/core/token/features/refreshing.dart';
import 'package:scm_device/src/adapters/sqlite/token/updating_adapter.dart';
import 'package:scm_device/src/applications/ui/my_app.dart';
import 'package:scm_device/src/core/token/token.dart';

void main(List<String> args) async {
  const accessToken = String.fromEnvironment("ACCESS_TOKEN");
  const refreshToken = String.fromEnvironment("REFRESH_TOKEN");
  const id = String.fromEnvironment("ID");
  const urlRefreshToken = String.fromEnvironment("URL_REFRESH_TOKEN");
  const urlGettingListContent = String.fromEnvironment("URL_GETTING_CONTENT_LIST");
  const contentDir = String.fromEnvironment("CONTENT_DIR");
  const webDavUser = String.fromEnvironment("WEB_DAV_USER");
  const webDavPassword = String.fromEnvironment("WEB_DAV_PASSWORD");
  const dbPath = String.fromEnvironment("DB_PATH");

  final receivePort = ReceivePort();
  final database = sqlite3.open(dbPath, mutex: false);

  database.execute('''
    DROP TABLE IF EXISTS token;
  ''');

  database.execute('''
    CREATE TABLE token(
      access TEXT, 
      refresh TEXT
    );
  ''');

  database.execute('''
    DROP TABLE IF EXISTS contents;
  ''');

  database.execute('''
    CREATE TABLE contents(
      id TEXT PRIMARY KEY, 
      displayDuration INTEGER,
      url TEXT,
      name TEXT,
      dir TEXT,
      path TEXT,
      isNew INTEGER
    );
  ''');

  final dio = Dio();

  final adapter_0 = UpdatingTokenSQLiteAdapter(database);

  await adapter_0.transform(Token(accessToken, refreshToken));

  final adapter_1 = GettingTokenSQLiteAdapter(database);
  final adapter_2 = UpdatingTokenHttpAdapter(urlRefreshToken, dio);

  final feature_0 = Refreshing(
    adapter_1,
    adapter_2,
    adapter_0
  );

  final adapter_3 = GettingContentListHttpAdapter(
    '$urlGettingListContent/$id', 
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

  stdout.writeln("Попытка сохранить контент");
  await feature_1.save().then((either) => {
    either.mapLeft((error) => stdout.writeln(error.message)),
    either.map((value) => stdout.writeln("Сохранен контент"))
  });

  await Isolate.spawn(websocketClient.run, receivePort.sendPort);

  await Isolate.spawn(gettingContentList.run, receivePort.sendPort);

  final controller = StreamController<String>();

  receivePort.listen((contentPath) {
    controller.sink.add(contentPath);
  });

  runApp(MyApp(stream: controller.stream));
}