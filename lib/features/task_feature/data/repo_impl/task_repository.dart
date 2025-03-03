import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/models/task.dart';
import '../../domain/repo/task_repo.dart';
import '../models/task_model/task_model.dart';
import '../services/noti_service.dart';

/// Репозиторий для управления задачами в Firestore.
///
/// Этот класс реализует интерфейс TaskRepo и предоставляет методы
/// для добавления, получения, обновления и удаления задач.
class TaskRepository implements TaskRepo {
  final FirebaseFirestore firestore; // Экземпляр Firestore для работы с базой данных
  final FirebaseAuth auth;           // Экземпляр FirebaseAuth для аутентификации
  final NotiService notiService;     // Сервис уведомлений

  TaskRepository({
    required this.firestore,
    required this.auth,
    required this.notiService,
  });

  @override
  Future<void> addTask(Task newTask) async {
    try {
      final user = auth.currentUser; // Получаем текущего пользователя
      if (user == null) throw Exception("User not authenticated");

      // Создаем модель задачи для хранения в Firestore
      final task = TaskModel(
        dueDate: newTask.dueDate,
        isDone: newTask.isDone,
        index: newTask.index,
        name: newTask.title,
        description: newTask.description,
      );

      DateTime createdAt = DateTime.now();
      Duration durationUntilDueDate = newTask.dueDate.difference(createdAt);
      DateTime notificationTime = createdAt.add(durationUntilDueDate ~/ 2); // Время для уведомления

      // Сохраняем задачу в Firestore
      await firestore.collection('users').doc(user.uid).collection('tasks').doc(task.index.toString()).set(task.toMap());

      // Планируем уведомление
      await notiService.scheduleNotification(
        notificationTime,
        id: task.index,
        title: 'Задача ${newTask.title} скоро истечет!',
        body: 'Выполните ее до окончания!',
      );
    } catch (e) {
      print('Ошибка при добавлении задачи: $e');
      throw e; // Пробрасываем исключение дальше
    }
  }

  @override
  Future<List<Task>> getTasks() async {
    try {
      final user = auth.currentUser; // Получаем текущего пользователя
      if (user == null) throw Exception("User not authenticated");

      // Получаем список задач из Firestore
      final querySnapshot = await firestore.collection('users').doc(user.uid).collection('tasks').get();
      final taskModels = querySnapshot.docs.map((doc) {
        return TaskModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
      return taskModels.map((taskModel) => taskModel.toDomain()).toList(); // Преобразуем в доменные модели
    } catch (e) {
      print('Ошибка при получении задач: $e');
      return []; // Возвращаем пустой список в случае ошибки
    }
  }

  @override
  Future<void> updateTask(int index) async {
    try {
      final user = auth.currentUser; // Получаем текущего пользователя
      if (user == null) throw Exception("User not authenticated");

      final docRef = firestore.collection('users').doc(user.uid).collection('tasks').doc(index.toString());
      final doc = await docRef.get(); // Получаем документ задачи

      if (doc.exists) {
        final existingTaskModel = TaskModel.fromMap(doc.data() as Map<String, dynamic>);

        // Обновляем задачу в Firestore
        final updatedTaskModel = TaskModel(
          dueDate: existingTaskModel.dueDate,
          isDone: !existingTaskModel.isDone, // Переключаем состояние
          index: index,
          name: existingTaskModel.name,
          description: existingTaskModel.description,
        );

        await docRef.set(updatedTaskModel.toMap());

        // Отменяем старое уведомление
        await notiService.cancelNotification(index);

        // Если задача снова становится "не завершенной", планируем новое уведомление
        if (!updatedTaskModel.isDone) {
          DateTime createdAt = DateTime.now();
          Duration durationUntilDueDate = updatedTaskModel.dueDate.difference(createdAt);
          DateTime notificationTime = createdAt.add(durationUntilDueDate ~/ 2);

          await notiService.scheduleNotification(
            notificationTime,
            id: index,
            title: 'Задача ${updatedTaskModel.name} скоро истечет!',
            body: 'Выполните ее до окончания!',
          );
        }
      } else {
        print('Задача с индексом $index не найдена.');
      }
    } catch (e) {
      print('Ошибка при обновлении задачи: $e');
      throw e; // Пробрасываем исключение дальше
    }
  }

  @override
  Future<void> deleteTask(int index) async {
    try {
      final user = auth.currentUser; // Получаем текущего пользователя
      if (user == null) throw Exception("User not authenticated");

      // Отменяем уведомление для этой задачи
      await notiService.cancelNotification(index);

      // Удаляем задачу из Firestore
      await firestore.collection('users').doc(user.uid).collection('tasks').doc(index.toString()).delete();
    } catch (e) {
      print('Ошибка при удалении задачи: $e');
      throw e; // Пробрасываем исключение дальше
    }
  }
}