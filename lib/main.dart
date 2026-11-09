import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const TaskFlowApp());
}

// Modelo de datos Task
class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.isCompleted,
  });

  final int id;
  final String title;
  final String description;
  final String priority;
  final bool isCompleted;
}

// Listado de tareas locales del proyecto
const demoTasks = [
  Task(
    id: 1,
    title: 'Configurar estructura del proyecto',
    description: 'Inicializar el repositorio Git local, conectar con la rama remota en GitHub y verificar el entorno de Flutter.',
    priority: 'Alta',
    isCompleted: true,
  ),
  Task(
    id: 2,
    title: 'Modelar entidad Task',
    description: 'Definir las propiedades inmutables id, título, descripción, prioridad y estado booleano de completado.',
    priority: 'Alta',
    isCompleted: true,
  ),
  Task(
    id: 3,
    title: 'Construir widget TaskCard',
    description: 'Diseñar una tarjeta reutilizable con ListTile, indicadores de estado y callback onTap para navegación.',
    priority: 'Media',
    isCompleted: false,
  ),
  Task(
    id: 4,
    title: 'Implementar navegación con GoRouter',
    description: 'Configurar rutas declarativas (/ y /task/:id) para abrir el detalle de cada tarea y regresar al listado.',
    priority: 'Alta',
    isCompleted: false,
  ),
  Task(
    id: 5,
    title: 'Ejecutar análisis estático y formato',
    description: 'Validar la calidad del código ejecutando dart format lib y flutter analyze sin advertencias.',
    priority: 'Baja',
    isCompleted: false,
  ),
];

// Desarrollo A: Declaración de rutas con GoRouter
final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const TaskListScreen()),
    GoRoute(
      path: '/task/:id',
      builder: (context, state) {
        final taskId = int.parse(state.pathParameters['id']!);
        return TaskDetailScreen(taskId: taskId);
      },
    ),
  ],
);

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Desarrollo A: Uso de MaterialApp.router
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'TaskFlow',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}

// Desarrollo B: TaskCard navegable mediante callback opcional onTap
class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, this.onTap});

  final Task task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: task.isCompleted ? Colors.green : null,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text('${task.priority} · ${task.description}'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

// Pantalla principal con el listado de tareas
class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis tareas'), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: demoTasks.length,
        itemBuilder: (context, index) {
          final task = demoTasks[index];
          return TaskCard(
            task: task,
            // Desarrollo B: Navegación enviando el id en la ruta
            onTap: () => context.push('/task/${task.id}'),
          );
        },
      ),
    );
  }
}

// Desarrollo C y Trabajo Autónomo: Pantalla de detalle de la tarea
class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final int taskId;

  @override
  Widget build(BuildContext context) {
    final task = demoTasks.firstWhere((item) => item.id == taskId);

    return Scaffold(
      appBar: AppBar(title: Text('Detalle de tarea #${task.id}')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text(
              task.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.flag_outlined, size: 18),
                  label: Text('Prioridad: ${task.priority}'),
                ),
                Chip(
                  avatar: Icon(
                    task.isCompleted
                        ? Icons.check_circle
                        : Icons.pending_actions,
                    size: 18,
                    color: task.isCompleted ? Colors.green : Colors.orange,
                  ),
                  label: Text(
                    task.isCompleted
                        ? 'Estado: completada'
                        : 'Estado: pendiente',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Trabajo Autónomo: Acción visual contextual en el detalle
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      task.isCompleted
                          ? 'La tarea "${task.title}" ya está registrada como completada.'
                          : 'Recordatorio activado para "${task.title}" (Prioridad ${task.priority}).',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: Icon(
                task.isCompleted
                    ? Icons.verified_outlined
                    : Icons.notifications_active_outlined,
              ),
              label: Text(
                task.isCompleted ? 'Verificar entrega' : 'Activar recordatorio',
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver al listado'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
