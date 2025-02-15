// 1. 必要な部品を取り込む（インポート）
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

// 自動生成されるコードの設定
part 'todo_database.g.dart';

// 2. テーブル（データを保存する場所）の設計図
class TodoItems extends Table {
  // 各項目の定義
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength()();
  TextColumn get content => text().named('body')();
  DateTimeColumn get createdAt => dateTime().nullable()();
}

// 3. データベースを操作するための道具箱
@DriftDatabase(tables: [TodoItems])
class AppDatabase extends _$AppDatabase {
  // データベースの初期設定
  AppDatabase() : super(_openConnection());
  @override
  int get schemaVersion => 1;

  // やることリストを監視する（変更があったらすぐに分かる）
  Stream<List<TodoItem>> watchTodoItems() => select(todoItems).watch();

  // 全てのやることを取得する
  Future<List<TodoItem>> get allTodoItems => select(todoItems).get();

  // 新しいやることを追加する
  Future<int> addTodoItem({
    required String title, // タイトル（必須）
    required String content, // 内容（必須）
    DateTime? createdAt, // 作成日時（省略可能）
  }) {
    return into(todoItems).insert(
      TodoItemsCompanion(
        title: Value(title),
        content: Value(content),
        createdAt: Value(createdAt ?? DateTime.now()), // 現在時刻を使用
      ),
    );
  }

  // やることを削除する
  Future<void> deleteTodoItem(TodoItem todoItem) {
    return (delete(todoItems)..where((tbl) => tbl.id.equals(todoItem.id))).go();
  }
}

// 4. データベースファイルを開く準備
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // スマートフォンの中にデータを保存する場所を準備
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
