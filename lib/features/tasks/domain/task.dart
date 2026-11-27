class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.isCompleted,
    required this.userId,
    this.dueDate,
  });

  final int id;
  final String title;
  final String description;
  final String priority;
  final bool isCompleted;
  final int userId;
  final DateTime? dueDate;

  Task copyWith({String? title, bool? isCompleted}) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description,
      priority: priority,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId,
      dueDate: dueDate,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? 'Sin descripción (API)',
      priority: json['priority'] as String? ?? 'Sin prioridad (API)',
      isCompleted: (json['isCompleted'] ?? json['completed']) as bool,
      userId: json['userId'] as int,
    );
  }
}
