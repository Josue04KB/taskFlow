import '../domain/task.dart';
import 'task_api_service.dart';
import 'task_repository.dart';

class RemoteTaskRepository implements TaskRepository {
  RemoteTaskRepository(this._apiService);

  final TaskApiService _apiService;
  final Set<int> _sessionCreatedIds = {};
  List<Task> _tasks = [];
  int _nextTemporaryId = -1;

  @override
  Future<List<Task>> getTasks() async {
    _tasks = await _apiService.getTasks();
    _sessionCreatedIds.clear();
    return List.unmodifiable(_tasks);
  }

  @override
  void save(Task task) {
    final index = _tasks.indexWhere((item) => item.id == task.id);
    if (index == -1) return;

    _tasks[index] = task;
  }

  @override
  Future<Task> createTask(
    String title,
    String description,
    String priority, {
    DateTime? dueDate,
  }) async {
    final created = await _apiService.createTask(title);
    // JSONPlaceholder can return the same ID on successive simulated writes.
    final id = _tasks.any((task) => task.id == created.id)
        ? _nextTemporaryId--
        : created.id;
    final task = Task(
      id: id,
      title: created.title,
      description: description,
      priority: priority,
      isCompleted: created.isCompleted,
      userId: created.userId,
      dueDate: dueDate,
    );
    _tasks.add(task);
    _sessionCreatedIds.add(id);
    return task;
  }

  @override
  Future<void> updateTask(Task task) async {
    if (!_sessionCreatedIds.contains(task.id)) {
      await _apiService.updateTask(task);
    }
    save(task);
  }

  @override
  Future<void> deleteTask(int id) async {
    if (!_sessionCreatedIds.remove(id)) {
      await _apiService.deleteTask(id);
    }
    _tasks.removeWhere((task) => task.id == id);
  }
}
