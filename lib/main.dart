import 'package:flutter/material.dart';

void main() {
  runApp(const TaskFlowApp());
}

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaskFlow',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      // Desarrollo C: Cambiamos WelcomeScreen() por TaskListScreen()
      home: const TaskListScreen(),
    );
  }
}

// Desarrollo A: Modelo de datos Task
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

// Trabajo Autónomo Incremental: 5 tareas auténticas del proyecto
const demoTasks = [
  Task(
    id: 1,
    title: 'Configurar estructura del proyecto',
    description: 'Inicializar repositorio Git y verificar entorno Flutter',
    priority: 'Alta',
    isCompleted: true,
  ),
  Task(
    id: 2,
    title: 'Modelar entidad Task',
    description: 'Definir propiedades inmutables id, título, descripción y prioridad',
    priority: 'Alta',
    isCompleted: true,
  ),
  Task(
    id: 3,
    title: 'Construir widget TaskCard',
    description: 'Diseñar tarjeta reutilizable con ListTile e indicadores de estado',
    priority: 'Media',
    isCompleted: false,
  ),
  Task(
    id: 4,
    title: 'Implementar ListView.builder',
    description: 'Renderizar el listado dinámico de tareas bajo demanda en pantalla',
    priority: 'Alta',
    isCompleted: false,
  ),
  Task(
    id: 5,
    title: 'Ejecutar análisis estático y formato',
    description: 'Validar calidad del código con dart format y flutter analyze',
    priority: 'Baja',
    isCompleted: false,
  ),
];

// Desarrollo B: Widget reutilizable TaskCard
class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
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
        // Usamos interpolación de cadenas para que flutter analyze no marque advertencia
        subtitle: Text('${task.priority} · ${task.description}'),
        trailing: const Icon(Icons.chevron_right),
        // Trabajo Autónomo: Acción visual de detalle al tocar la tarjeta
        onTap: () {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Detalle [#${task.id}]: ${task.title} (${task.isCompleted ? "Completada" : "Pendiente"})',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}

// Desarrollo C: Pantalla de listado con ListView.builder
class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis tareas'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: demoTasks.length,
        itemBuilder: (context, index) {
          final task = demoTasks[index];
          return TaskCard(task: task);
        },
      ),
    );
  }
}