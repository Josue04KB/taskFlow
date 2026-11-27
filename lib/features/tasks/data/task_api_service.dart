import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../domain/task.dart';

class TaskApiService {
  static const int userId = 2;

  TaskApiService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://jsonplaceholder.typicode.com',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

  final Dio _dio;

  Future<List<Task>> getTasks() async {
    final response = await _dio.get<List<dynamic>>(
      '/todos',
      queryParameters: {'userId': userId},
    );
    debugPrint('GET /todos?userId=$userId → HTTP ${response.statusCode}');

    final rows = response.data;
    if (rows == null) {
      throw const FormatException('La respuesta no contiene una lista.');
    }

    return [
      for (final row in rows)
        Task.fromJson(Map<String, dynamic>.from(row as Map)),
    ];
  }

  Future<Task> createTask(String title) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/todos',
      data: {'title': title, 'completed': false, 'userId': userId},
    );
    debugPrint('POST /todos → HTTP ${response.statusCode}');

    final json = response.data;
    if (json == null) throw const FormatException('Respuesta vacía.');
    return Task.fromJson(json);
  }

  Future<void> updateTask(Task task) async {
    final response = await _dio.patch<void>(
      '/todos/${task.id}',
      data: {'title': task.title, 'completed': task.isCompleted},
    );
    debugPrint('PATCH /todos/${task.id} → HTTP ${response.statusCode}');
  }

  Future<void> deleteTask(int id) async {
    final response = await _dio.delete<void>('/todos/$id');
    debugPrint('DELETE /todos/$id → HTTP ${response.statusCode}');
  }
}
