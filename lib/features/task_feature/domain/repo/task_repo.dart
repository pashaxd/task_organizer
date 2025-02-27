import '../models/task.dart';

abstract class TaskRepo{
  Future<void> addTask(Task newTask);
  Future<List<Task>> getTasks();
  Future<void> deleteTask(int index);
  Future <void> updateTask(Task task);
}