import 'package:hive_ce/hive.dart';
import 'package:task_organizer/features/task_feature/domain/models/task.dart';
import 'package:task_organizer/features/task_feature/domain/repo/task_repo.dart';

import '../models/task_model/task_model.dart';

class TaskRepository implements TaskRepo {

  @override
  Future<void> addTask(Task newTask) async {
    try {
      final task = TaskModel(
        dueDate: newTask.dueDate,
        isDone: newTask.isDone,
        index: newTask.index,
        name: newTask.title,
        description: newTask.description,
      );

      final box = await Hive.openBox<TaskModel>('myBox');
      await box.put(task.index, task);
    } catch (e) {
      print('Ошибка при добавлении задачи: $e');
    }
  }

  @override
  Future<void> deleteTask(int index) async {
    try {
      final box = await Hive.openBox<TaskModel>('myBox');
      if (box.containsKey(index)) {
        await box.delete(index);
        print('Задача с индексом $index была удалена.');
      } else {
        print('Задача с индексом $index не найдена.');
      }
    } catch (e) {
      print('Ошибка при удалении задачи: $e');
    }
  }

  @override
  Future<List<Task>> getTasks() async {
    try {
      final box = await Hive.openBox<TaskModel>('myBox');
      final taskModels = box.values.cast<TaskModel>().toList();
      final tasks = taskModels.map((taskModel) => taskModel.toDomain())
          .toList();
      return tasks;
    } catch (e) {
      print('Ошибка при получении задач: $e');
      return [];
    }
  }

  @override
  Future<void> updateTask(Task newTask) async {
    try {
      final taskModel = TaskModel(
        dueDate: newTask.dueDate,
        isDone: newTask.isDone,
        index: newTask.index,
        name: newTask.title,
        description: newTask.description,
      );

      final box = await Hive.openBox<TaskModel>('myBox');
      await box.put(taskModel.index, taskModel);
    } catch (e) {
      print('Ошибка при обновлении задачи: $e');
    }
  }
}

