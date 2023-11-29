import 'dart:io';
import 'dart:isolate';
import 'package:scm_device/src/adapters/sqlite/content/getting_list_adapter.dart';
import 'package:scm_device/src/core/content/features/getting_list.dart';
import 'package:sqlite3/sqlite3.dart';

run(SendPort sendPort) async {
  const dbPath = String.fromEnvironment("DB_PATH");

  final database = sqlite3.open(dbPath, mutex: false);
  final adapter = GettingListContentSQLiteAdapter(database);
  final feature = GettingList(adapter);

  while (true) {
    stdout.writeln("Попытка получить список контента из локальной базы данных");
    await feature.get().then(
      (either) => (
        either.mapLeft(
          (error) => {
            stderr.writeln(error.message),
            stderr.writeln("Засыпаю на 300 сек"),
            sleep(const Duration(seconds: 300)),
          }
        ),
        either.map(
          (list) async => {
            stdout.writeln("Список контента из локальной базы данных, получен"),
            stdout.writeln("Обход списка"),
            for (var content in list) {
              sendPort.send(content.path),
              sleep(Duration(seconds: content.displayDuration))
            }
          }
        )
      ),
    );
  }
}