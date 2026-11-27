import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'task_form_screen.dart';
import 'tasks_view_model.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TasksViewModel>();
    final busy = viewModel.isLoading || viewModel.isWriting;
    Future<void> refresh() => context.read<TasksViewModel>().loadTasks();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis tareas'),
        actions: [
          IconButton(
            tooltip: 'Actualizar tareas',
            onPressed: busy ? null : refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(viewModel, refresh),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: busy
            ? null
            : () {
                ScaffoldMessenger.of(context).clearSnackBars();
                context.push<TaskDraft>('/new');
              },
        icon: const Icon(Icons.add),
        label: const Text('Nueva tarea'),
      ),
    );
  }

  Widget _buildBody(TasksViewModel viewModel, Future<void> Function() refresh) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(semanticsLabel: 'Cargando tareas'),
      );
    }

    final errorMessage = viewModel.errorMessage;
    if (errorMessage != null || viewModel.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                errorMessage ?? 'Todavía no hay tareas para mostrar.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: refresh,
                child: Text(errorMessage == null ? 'Actualizar' : 'Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final tasks = viewModel.tasks;
    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Card(
            child: ListTile(
              leading: Icon(
                task.isCompleted
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
              ),
              title: Text(task.title),
              subtitle: Text('Prioridad: ${task.priority}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/task/${task.id}'),
            ),
          );
        },
      ),
    );
  }
}
