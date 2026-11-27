import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../domain/task.dart';
import 'task_form_screen.dart';
import 'tasks_view_model.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final int? taskId;

  Future<void> _editTitle(BuildContext context, Task task) async {
    final formKey = GlobalKey<FormState>();
    String? title;
    final newTitle = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar título'),
        scrollable: true,
        content: Form(
          key: formKey,
          child: TextFormField(
            initialValue: task.title,
            decoration: const InputDecoration(labelText: 'Título'),
            validator: validateTaskTitle,
            onSaved: (value) => title = value?.trim(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final form = formKey.currentState!;
              if (!form.validate()) return;

              form.save();
              Navigator.pop(dialogContext, title);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (!context.mounted || newTitle == null) return;

    try {
      await context.read<TasksViewModel>().updateTask(
        task.copyWith(title: newTitle),
      );
      if (context.mounted) _showMessage(context, 'Tarea actualizada');
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, 'No se pudo actualizar la tarea.');
      }
    }
  }

  Future<void> _deleteTask(BuildContext context, Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Eliminar «${task.title}»?'),
        scrollable: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (!context.mounted || confirmed != true) return;

    try {
      await context.read<TasksViewModel>().deleteTask(task.id);
      if (!context.mounted) return;

      _showMessage(context, 'Tarea eliminada');
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, 'No se pudo eliminar la tarea.');
      }
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TasksViewModel>();
    final task = viewModel.findTask(taskId);
    final dueDate = task?.dueDate;
    final busy = viewModel.isLoading || viewModel.isWriting;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          task == null ? 'Detalle de tarea' : 'Detalle de tarea #${task.id}',
        ),
      ),
      body: task == null
          ? const Center(child: Text('No se encontró esta tarea.'))
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(task.description),
                const SizedBox(height: 16),
                Text('Prioridad: ${task.priority}'),
                Text(
                  task.isCompleted ? 'Estado: completada' : 'Estado: pendiente',
                ),
                Text('Usuario: ${task.userId}'),
                if (dueDate != null)
                  Text(
                    'Fecha: ${MaterialLocalizations.of(context).formatCompactDate(dueDate)}',
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: busy
                      ? null
                      : () => viewModel.toggleCompleted(task.id),
                  child: Text(
                    task.isCompleted
                        ? 'Marcar como pendiente'
                        : 'Marcar como completada',
                  ),
                ),
                OutlinedButton(
                  onPressed: busy ? null : () => _editTitle(context, task),
                  child: const Text('Editar título'),
                ),
                TextButton(
                  onPressed: busy ? null : () => _deleteTask(context, task),
                  child: Text(
                    'Eliminar tarea',
                    style: busy
                        ? null
                        : TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ],
            ),
    );
  }
}
