import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/drift/todo_database.dart';

final databaseProvider = Provider((ref) => AppDatabase());

final todoListProvider = StreamProvider((ref) {
  final database = ref.watch(databaseProvider);
  return database.watchTodoItems();
});

final todoNotifierProvider =
    NotifierProvider<TodoNotifier, void>(TodoNotifier.new);

class TodoNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> addTodo({
    required String title,
    required String content,
    required DateTime deadline,
  }) async {
    final database = ref.read(databaseProvider);
    await database.addTodoItem(
      title: title,
      content: content,
      createdAt: deadline,
    );
  }

  Future<void> deleteTodo(TodoItem todo) async {
    final database = ref.read(databaseProvider);
    await database.deleteTodoItem(todo);
  }
}
