import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'tasks_view_model.dart';

class TaskDraft {
  const TaskDraft({
    required this.title,
    required this.description,
    required this.priority,
    this.dueDate,
  });

  final String title;
  final String description;
  final String priority;
  final DateTime? dueDate;
}

String? validateTaskTitle(String? value) {
  final title = value?.trim() ?? '';
  if (title.isEmpty) return 'Escribe un título para la tarea.';
  if (title.length < 3) return 'Usa al menos 3 caracteres.';
  return null;
}

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  static const _priorities = ['Alta', 'Media', 'Baja'];

  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  String? _priority = 'Media';
  DateTime? _dueDate;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final today = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? today,
      firstDate: DateTime(today.year - 100),
      lastDate: DateTime(today.year + 100, 12, 31),
      confirmText: 'Aceptar',
    );
    if (!mounted || date == null) return;

    setState(() => _dueDate = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final draft = TaskDraft(
      title: _title.text.trim(),
      description: _description.text.trim(),
      priority: _priority!,
      dueDate: _dueDate,
    );
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<TasksViewModel>().createTask(
        draft.title,
        draft.description,
        draft.priority,
        dueDate: draft.dueDate,
      );
    } catch (_) {
      if (mounted) {
        messenger
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(content: Text('No se pudo crear la tarea.')),
          );
      }
      return;
    }

    if (!mounted) return;
    _close(draft);
    messenger
      ..clearSnackBars()
      ..showSnackBar(const SnackBar(content: Text('Tarea creada')));
  }

  void _close([TaskDraft? draft]) {
    if (context.canPop()) {
      context.pop(draft);
      return;
    }

    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder();
    final dueDate = _dueDate;
    final viewModel = context.watch<TasksViewModel>();
    final busy = viewModel.isLoading || viewModel.isWriting;

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva tarea')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: border,
                ),
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: validateTaskTitle,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _description,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: border,
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Describe brevemente qué hay que hacer.'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _priority,
                decoration: const InputDecoration(
                  labelText: 'Prioridad',
                  border: border,
                ),
                items: [
                  for (final priority in _priorities)
                    DropdownMenuItem(value: priority, child: Text(priority)),
                ],
                onChanged: (value) => _priority = value,
                validator: (value) => _priorities.contains(value)
                    ? null
                    : 'Selecciona una prioridad válida.',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDueDate,
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Text(
                        dueDate == null
                            ? 'Elegir fecha (opcional)'
                            : 'Fecha: ${MaterialLocalizations.of(context).formatCompactDate(dueDate)}',
                      ),
                    ),
                  ),
                  if (dueDate != null)
                    IconButton(
                      tooltip: 'Quitar fecha',
                      onPressed: () => setState(() => _dueDate = null),
                      icon: const Icon(Icons.close),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              OverflowBar(
                alignment: MainAxisAlignment.end,
                spacing: 12,
                overflowSpacing: 8,
                children: [
                  TextButton(
                    onPressed: viewModel.isWriting ? null : _close,
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: busy ? null : _submit,
                    child: Text(viewModel.isWriting ? 'Guardando…' : 'Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
