import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/main.dart';

void main() {
  testWidgets('Muestra cinco tareas y abre el detalle de la elegida', (
    tester,
  ) async {
    await tester.pumpWidget(const TaskFlowApp());

    expect(find.text('Mis tareas'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(5));
    expect(demoTasks.map((task) => task.id).toSet(), hasLength(5));

    for (final task in [demoTasks.first, demoTasks[2]]) {
      await tester.tap(find.text(task.title));
      await tester.pumpAndSettle();

      expect(find.text('Detalle de tarea #${task.id}'), findsOneWidget);
      expect(find.text(task.title), findsOneWidget);
      expect(find.text(task.description), findsOneWidget);
      expect(find.text('Prioridad: ${task.priority}'), findsOneWidget);
      expect(find.text('Usuario: ${task.userId}'), findsOneWidget);
      expect(
        find.text(
          task.isCompleted ? 'Estado: completada' : 'Estado: pendiente',
        ),
        findsOneWidget,
      );

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Mis tareas'), findsOneWidget);
    }
  });

  testWidgets('Muestra un mensaje para IDs inexistentes o inválidos', (
    tester,
  ) async {
    await tester.pumpWidget(const TaskFlowApp());

    for (final path in ['/task/999', '/task/invalido']) {
      appRouter.go(path);
      await tester.pumpAndSettle();
      expect(find.text('No se encontró esta tarea.'), findsOneWidget);
    }

    appRouter.go('/');
    await tester.pumpAndSettle();
  });
}
