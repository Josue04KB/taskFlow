import 'package:flutter/foundation.dart';

import '../data/task_repository.dart';
import '../domain/task.dart';

class TasksViewModel extends ChangeNotifier {
  TasksViewModel(this._repository);

  final TaskRepository _repository;
  List<Task> _tasks = [];
  bool _isLoading = false;
  bool _isWriting = false;
  String? _errorMessage;
  bool _disposed = false;

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  bool get isWriting => _isWriting;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => !_isLoading && _errorMessage == null && _tasks.isEmpty;

  Future<void> loadTasks() async {
    if (_isLoading || _isWriting || _disposed) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _repository.getTasks();
    } catch (error) {
      _tasks = [];
      _errorMessage = 'No se pudieron cargar las tareas.';
      debugPrint('Error al cargar tareas: $error');
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Task? findTask(int? id) {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  void toggleCompleted(int id) {
    if (_isLoading || _isWriting) return;
    final task = findTask(id);
    if (task == null) return;

    final updated = task.copyWith(isCompleted: !task.isCompleted);
    _repository.save(updated);
    _replaceTask(updated);
    notifyListeners();
  }

  Future<void> createTask(
    String title,
    String description,
    String priority, {
    DateTime? dueDate,
  }) => _write(() async {
    final task = await _repository.createTask(
      title,
      description,
      priority,
      dueDate: dueDate,
    );
    _tasks = [..._tasks, task];
    _errorMessage = null;
  });

  Future<void> updateTask(Task task) => _write(() async {
    await _repository.updateTask(task);
    _replaceTask(task);
  });

  Future<void> deleteTask(int id) => _write(() async {
    await _repository.deleteTask(id);
    _tasks = [
      for (final task in _tasks)
        if (task.id != id) task,
    ];
  });

  void _replaceTask(Task updated) {
    _tasks = [
      for (final item in _tasks) item.id == updated.id ? updated : item,
    ];
  }

  Future<void> _write(Future<void> Function() operation) async {
    if (_isLoading || _isWriting || _disposed) {
      throw StateError('Hay otra operación en curso.');
    }

    _isWriting = true;
    notifyListeners();
    try {
      await operation();
    } finally {
      _isWriting = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
