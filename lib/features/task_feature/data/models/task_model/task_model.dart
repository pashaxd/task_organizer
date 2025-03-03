import 'package:hive_ce/hive.dart';
import 'package:task_organizer/features/task_feature/domain/models/task.dart';

/// Модель для представления задачи в базе данных.
///
/// Этот класс используется для преобразования объектов
/// между доменной моделью и форматом, удобным для хранения в базе данных.
class TaskModel {
  final String name;        // Заголовок задачи
  final String description; // Описание задачи
  final bool isDone;       // Статус выполнения задачи
  final int index;         // Индекс задачи
  final DateTime dueDate;  // Дата выполнения задачи

  TaskModel({
    required this.dueDate,
    required this.index,
    required this.name,
    required this.description,
    required this.isDone,
  });

  /// Преобразование модели задачи в доменную модель.
  Task toDomain() {
    return Task(
      title: name,
      description: description,
      index: index,
      dueDate: dueDate,
      isDone: isDone,
    );
  }

  /// Создание модели задачи из доменной модели.
  TaskModel fromDomain(Task task) {
    return TaskModel(
      isDone: task.isDone,
      name: task.title,
      description: task.description,
      index: task.index,
      dueDate: task.dueDate,
    );
  }

  /// Преобразование модели задачи в Map для хранения в базе данных.
  Map<String, dynamic> toMap() {
    return {
      'dueDate': dueDate.toIso8601String(), // Преобразуем дату в строку
      'isDone': isDone,
      'index': index,
      'name': name,
      'description': description,
    };
  }

  /// Создание модели задачи из Map, полученного из базы данных.
  static TaskModel fromMap(Map<String, dynamic> map) {
    return TaskModel(
      dueDate: DateTime.parse(map['dueDate']), // Преобразуем строку обратно в DateTime
      isDone: map['isDone'],
      index: map['index'],
      name: map['name'],
      description: map['description'],
    );
  }
}