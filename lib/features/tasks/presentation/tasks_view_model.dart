import 'package:flutter/foundation.dart';

import '../data/task_repository.dart';
import '../domain/task.dart';

class TasksViewModel extends ChangeNotifier {
  TasksViewModel(TaskRepository repository)
    : _repository = repository,
      _tasks = repository.getTasks();

  final TaskRepository _repository;
  List<Task> _tasks;

  List<Task> get tasks => List.unmodifiable(_tasks);

  Task? findTask(int? id) {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  void toggleCompleted(int id) {
    final task = findTask(id);
    if (task == null) return;

    _repository.save(task.copyWith(isCompleted: !task.isCompleted));
    _tasks = _repository.getTasks();
    notifyListeners();
  }
}
