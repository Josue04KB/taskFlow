import '../domain/task.dart';
import 'task_repository.dart';

class LocalTaskRepository implements TaskRepository {
  final List<Task> _tasks = [
    const Task(
      id: 1,
      title: 'Configurar estructura del proyecto',
      description: 'Inicializar el repositorio Git local, conectar con la rama remota en GitHub y verificar el entorno de Flutter.',
      priority: 'Alta',
      isCompleted: true,
      userId: 1,
    ),
    const Task(
      id: 2,
      title: 'Modelar entidad Task',
      description: 'Definir los campos de la tarea, incluido el usuario, y comprobar la conversión desde JSON.',
      priority: 'Alta',
      isCompleted: true,
      userId: 1,
    ),
    const Task(
      id: 3,
      title: 'Construir widget TaskCard',
      description: 'Diseñar una tarjeta reutilizable con ListTile, indicadores de estado y callback onTap para navegación.',
      priority: 'Media',
      isCompleted: false,
      userId: 1,
    ),
    const Task(
      id: 4,
      title: 'Implementar navegación con GoRouter',
      description: 'Configurar rutas declarativas (/ y /task/:id) para abrir el detalle de cada tarea y regresar al listado.',
      priority: 'Alta',
      isCompleted: false,
      userId: 1,
    ),
    const Task(
      id: 5,
      title: 'Ejecutar análisis estático y formato',
      description: 'Validar la calidad del código ejecutando dart format lib y flutter analyze sin advertencias.',
      priority: 'Baja',
      isCompleted: false,
      userId: 1,
    ),
  ];

  @override
  Future<List<Task>> getTasks() async => List.unmodifiable(_tasks);

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
    final maxId = _tasks.fold(0, (max, task) => task.id > max ? task.id : max);
    final task = Task(
      id: maxId + 1,
      title: title,
      description: description,
      priority: priority,
      isCompleted: false,
      userId: 1,
      dueDate: dueDate,
    );
    _tasks.add(task);
    return task;
  }

  @override
  Future<void> updateTask(Task task) async => save(task);

  @override
  Future<void> deleteTask(int id) async {
    _tasks.removeWhere((task) => task.id == id);
  }
}
