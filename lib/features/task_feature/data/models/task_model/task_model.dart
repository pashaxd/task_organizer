import 'package:hive_ce/hive.dart';
import 'package:task_organizer/features/task_feature/domain/models/task.dart';

part 'task_model.g.dart';

@HiveType(typeId: 1)
class TaskModel {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final bool isDone;

  @HiveField(3)
  final int index;

  @HiveField(4)

  final DateTime dueDate;

  TaskModel({
    required this.dueDate,
    required this.index,
    required this.name,
    required this.description,
    required this.isDone,
  });

  Task toDomain() {
    return Task(
        title: name,
        description: description,
        index: index,
        dueDate: dueDate);
  }

  TaskModel fromDomain(Task task) {
    return TaskModel(
        isDone: task.isDone,
        name: task.title,
        description: task.description,
        index: task.index,
        dueDate: task.dueDate);
  }
}
