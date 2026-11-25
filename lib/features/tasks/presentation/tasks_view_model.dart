import 'package:flutter/foundation.dart';

import '../data/task_repository.dart';
import '../domain/task.dart';

class TasksViewModel extends ChangeNotifier {
  TasksViewModel(this._repository);

  final TaskRepository _repository;
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _disposed = false;

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => !_isLoading && _errorMessage == null && _tasks.isEmpty;

  Future<void> loadTasks() async {
    if (_isLoading || _disposed) return;

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
    final task = findTask(id);
    if (task == null) return;

    final updated = task.copyWith(isCompleted: !task.isCompleted);
    _repository.save(updated);
    _tasks = [for (final item in _tasks) item.id == id ? updated : item];
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
