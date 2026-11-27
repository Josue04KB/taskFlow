import '../domain/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks();

  void save(Task task);

  Future<Task> createTask(
    String title,
    String description,
    String priority, {
    DateTime? dueDate,
  });

  Future<void> updateTask(Task task);

  Future<void> deleteTask(int id);
}
