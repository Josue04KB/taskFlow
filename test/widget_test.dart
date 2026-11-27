import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:taskflow/app/taskflow_app.dart';
import 'package:taskflow/features/tasks/data/local_task_repository.dart';
import 'package:taskflow/features/tasks/data/remote_task_repository.dart';
import 'package:taskflow/features/tasks/data/task_api_service.dart';
import 'package:taskflow/features/tasks/data/task_repository.dart';
import 'package:taskflow/features/tasks/presentation/task_form_screen.dart';
import 'package:taskflow/features/tasks/presentation/tasks_view_model.dart';

const _remoteTask = {
  'id': 21,
  'userId': 2,
  'title': 'Tarea remota',
  'completed': false,
};

Widget _appWithRepository(TaskRepository repository) {
  return ChangeNotifierProvider(
    create: (_) => TasksViewModel(repository)..loadTasks(),
    child: const TaskFlowApp(),
  );
}

void main() {
  testWidgets('Muestra cinco tareas y abre el detalle de la elegida', (
    tester,
  ) async {
    final repository = LocalTaskRepository();
    await tester.pumpWidget(_appWithRepository(repository));
    await tester.pumpAndSettle();

    final tasks = await repository.getTasks();
    expect(find.text('Mis tareas'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(5));
    expect(tasks.map((task) => task.id).toSet(), hasLength(5));

    for (final task in [tasks.first, tasks[2]]) {
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

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Mis tareas'), findsOneWidget);
    }
  });

  testWidgets('Actualiza el estado en el detalle y en la tarjeta', (
    tester,
  ) async {
    await tester.pumpWidget(_appWithRepository(LocalTaskRepository()));
    await tester.pumpAndSettle();

    final card = find.widgetWithText(ListTile, 'Construir widget TaskCard');
    final pendingIcon = find.descendant(
      of: card,
      matching: find.byIcon(Icons.radio_button_unchecked),
    );
    final completedIcon = find.descendant(
      of: card,
      matching: find.byIcon(Icons.check_circle),
    );
    expect(pendingIcon, findsOneWidget);

    await tester.tap(card);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Marcar como completada'));
    await tester.pumpAndSettle();
    expect(find.text('Estado: completada'), findsOneWidget);
    expect(find.text('Marcar como pendiente'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(completedIcon, findsOneWidget);

    await tester.tap(card);
    await tester.pumpAndSettle();
    expect(find.text('Estado: completada'), findsOneWidget);
    await tester.tap(find.text('Marcar como pendiente'));
    await tester.pumpAndSettle();
    expect(find.text('Estado: pendiente'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(pendingIcon, findsOneWidget);
  });

  testWidgets('Muestra un mensaje para IDs inexistentes o inválidos', (
    tester,
  ) async {
    await tester.pumpWidget(_appWithRepository(LocalTaskRepository()));
    await tester.pumpAndSettle();

    for (final path in ['/task/999', '/task/invalido']) {
      appRouter.go(path);
      await tester.pumpAndSettle();
      expect(find.text('No se encontró esta tarea.'), findsOneWidget);
    }

    appRouter.go('/');
    await tester.pumpAndSettle();
  });

  testWidgets('Carga, muestra y cambia una tarea remota en memoria', (
    tester,
  ) async {
    final dio = Dio();
    addTearDown(dio.close);
    final pendingResponse = Completer<List<Map<String, Object>>>();
    final requests = <RequestOptions>[];
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          requests.add(options);
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: await pendingResponse.future,
            ),
          );
        },
      ),
    );
    final repository = RemoteTaskRepository(TaskApiService(dio: dio));

    await tester.pumpWidget(_appWithRepository(repository));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final refresh = find.widgetWithIcon(IconButton, Icons.refresh);
    expect(tester.widget<IconButton>(refresh).onPressed, isNull);

    pendingResponse.complete([_remoteTask]);
    await tester.pumpAndSettle();
    expect(requests.single.method, 'GET');
    expect(requests.single.path, '/todos');
    expect(requests.single.queryParameters, {'userId': 2});
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.widget<IconButton>(refresh).onPressed, isNotNull);

    await tester.tap(find.text('Tarea remota'));
    await tester.pumpAndSettle();
    expect(find.text('Detalle de tarea #21'), findsOneWidget);
    expect(find.text('Usuario: 2'), findsOneWidget);
    expect(find.text('Sin descripción (API)'), findsOneWidget);
    expect(find.text('Prioridad: Sin prioridad (API)'), findsOneWidget);
    expect(find.text('Estado: pendiente'), findsOneWidget);

    await tester.tap(find.text('Marcar como completada'));
    await tester.pumpAndSettle();
    expect(find.text('Estado: completada'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(requests, hasLength(1));
  });

  testWidgets('Reintenta una consulta fallida sin reiniciar la app', (
    tester,
  ) async {
    final dio = Dio();
    addTearDown(dio.close);
    var requests = 0;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests++;
          if (requests == 2) {
            handler.reject(
              DioException.connectionError(
                requestOptions: options,
                reason: 'Conexión interrumpida en la prueba',
              ),
            );
            return;
          }
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: [_remoteTask],
            ),
          );
        },
      ),
    );
    final repository = RemoteTaskRepository(TaskApiService(dio: dio));

    await tester.pumpWidget(_appWithRepository(repository));
    await tester.pumpAndSettle();
    expect(find.text('Tarea remota'), findsOneWidget);

    await tester.tap(find.byTooltip('Actualizar tareas'));
    await tester.pumpAndSettle();
    expect(find.text('No se pudieron cargar las tareas.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Todavía no hay tareas para mostrar.'), findsNothing);
    expect(find.text('Tarea remota'), findsNothing);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('Tarea remota'), findsOneWidget);
    expect(find.text('No se pudieron cargar las tareas.'), findsNothing);
    expect(requests, 3);
  });

  testWidgets('Actualiza desde la vista vacía y al deslizar la lista', (
    tester,
  ) async {
    final dio = Dio();
    addTearDown(dio.close);
    var requests = 0;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests++;
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: [if (requests > 1) _remoteTask],
            ),
          );
        },
      ),
    );
    final repository = RemoteTaskRepository(TaskApiService(dio: dio));

    await tester.pumpWidget(_appWithRepository(repository));
    await tester.pumpAndSettle();
    expect(find.text('Todavía no hay tareas para mostrar.'), findsOneWidget);
    expect(find.text('Reintentar'), findsNothing);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Actualizar'));
    await tester.pumpAndSettle();
    expect(find.text('Tarea remota'), findsOneWidget);
    expect(requests, 2);

    await tester.drag(find.byType(ListView), const Offset(0, 350));
    await tester.pumpAndSettle();
    expect(find.text('Tarea remota'), findsOneWidget);
    expect(requests, 3);
  });

  testWidgets('Valida el formulario y devuelve un borrador sin fecha', (
    tester,
  ) async {
    await tester.pumpWidget(_appWithRepository(LocalTaskRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nueva tarea'));
    await tester.pumpAndSettle();
    final save = find.widgetWithText(FilledButton, 'Guardar');
    final title = find.widgetWithText(TextFormField, 'Título');
    final description = find.widgetWithText(TextFormField, 'Descripción');

    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('Escribe un título para la tarea.'), findsOneWidget);
    expect(find.text('Describe brevemente qué hay que hacer.'), findsOneWidget);

    await tester.enterText(title, ' ab ');
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('Usa al menos 3 caracteres.'), findsOneWidget);
    expect(find.byType(TaskFormScreen), findsOneWidget);

    await tester.enterText(title, ' Preparar entrega ');
    await tester.enterText(description, ' Revisar las capturas. ');
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alta').last);
    await tester.pumpAndSettle();
    expect(find.text('Elegir fecha (opcional)'), findsOneWidget);

    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('Tarea creada'), findsOneWidget);
    expect(find.text('Preparar entrega'), findsOneWidget);
    expect(find.byType(TaskFormScreen), findsNothing);
    expect(find.byType(ListTile), findsNWidgets(6));
  });

  testWidgets('Devuelve la fecha elegida y permite cancelar sin mensaje', (
    tester,
  ) async {
    await tester.pumpWidget(_appWithRepository(LocalTaskRepository()));
    await tester.pumpAndSettle();

    final draftResult = appRouter.push<TaskDraft>('/new');
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Título'),
      ' Revisión ',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Descripción'),
      ' Revisar la app. ',
    );
    await tester.tap(find.text('Elegir fecha (opcional)'));
    await tester.pumpAndSettle();
    final picker = tester.widget<DatePickerDialog>(
      find.byType(DatePickerDialog),
    );
    await tester.tap(find.text('Aceptar'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Quitar fecha'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await tester.pumpAndSettle();
    final draft = await draftResult;
    expect(draft?.title, 'Revisión');
    expect(draft?.description, 'Revisar la app.');
    expect(draft?.priority, 'Media');
    expect(draft?.dueDate, picker.initialDate);

    await tester.tap(find.text('Nueva tarea'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Mis tareas'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('Crea, edita y elimina después de la respuesta HTTP', (
    tester,
  ) async {
    final dio = Dio();
    addTearDown(dio.close);
    final requests = <RequestOptions>[];
    var rejectCreation = true;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          if (options.method == 'POST' && rejectCreation) {
            handler.reject(
              DioException.connectionError(
                requestOptions: options,
                reason: 'Conexión interrumpida en la prueba',
              ),
            );
            return;
          }

          final data = switch (options.method) {
            'GET' => [_remoteTask],
            'POST' => {'id': 201, ...(options.data as Map<String, dynamic>)},
            _ => null,
          };
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: options.method == 'POST' ? 201 : 200,
              data: data,
            ),
          );
        },
      ),
    );
    final repository = RemoteTaskRepository(TaskApiService(dio: dio));
    await tester.pumpWidget(_appWithRepository(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nueva tarea'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Título'),
      'Entrega nueva',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Descripción'),
      'Revisar y entregar.',
    );
    final save = find.widgetWithText(FilledButton, 'Guardar');
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('No se pudo crear la tarea.'), findsOneWidget);
    expect(find.text('Tarea creada'), findsNothing);
    expect(find.text('Entrega nueva'), findsOneWidget);
    expect(find.byType(TaskFormScreen), findsOneWidget);

    rejectCreation = false;
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(requests.last.method, 'POST');
    expect(requests.last.path, '/todos');
    expect(requests.last.data, {
      'title': 'Entrega nueva',
      'completed': false,
      'userId': 2,
    });
    expect(find.text('Tarea creada'), findsOneWidget);
    expect(find.text('Entrega nueva'), findsOneWidget);

    await tester.tap(find.text('Tarea remota'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Editar título'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), ' ab ');
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('Usa al menos 3 caracteres.'), findsOneWidget);
    expect(requests.last.method, 'POST');

    await tester.enterText(find.byType(TextFormField), ' Tarea editada ');
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(requests.last.method, 'PATCH');
    expect(requests.last.path, '/todos/21');
    expect(requests.last.data, {'title': 'Tarea editada', 'completed': false});
    expect(find.text('Tarea editada'), findsOneWidget);

    final delete = find.widgetWithText(TextButton, 'Eliminar tarea');
    await tester.tap(delete);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancelar'));
    await tester.pumpAndSettle();
    expect(requests.last.method, 'PATCH');
    expect(find.text('Tarea editada'), findsOneWidget);

    await tester.tap(delete);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pumpAndSettle();
    expect(requests.last.method, 'DELETE');
    expect(requests.last.path, '/todos/21');
    expect(find.text('Tarea eliminada'), findsOneWidget);
    expect(find.text('Tarea editada'), findsNothing);
    expect(find.text('Entrega nueva'), findsOneWidget);
  });

  test(
    'Identifica por separado dos altas que reutilizan el ID remoto',
    () async {
      final dio = Dio();
      addTearDown(dio.close);
      final methods = <String>[];
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            methods.add(options.method);
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 201,
                data: {'id': 201, ...(options.data as Map<String, dynamic>)},
              ),
            );
          },
        ),
      );
      final repository = RemoteTaskRepository(TaskApiService(dio: dio));
      final first = await repository.createTask(
        'Primera tarea',
        'Primera descripción',
        'Alta',
      );
      final second = await repository.createTask(
        'Segunda tarea',
        'Segunda descripción',
        'Baja',
      );

      expect(first.id, isNot(second.id));
      await repository.updateTask(second.copyWith(title: 'Segunda editada'));
      await repository.deleteTask(first.id);
      expect(methods, ['POST', 'POST']);
    },
  );
}
