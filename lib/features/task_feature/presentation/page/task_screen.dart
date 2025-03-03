import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';
import 'package:task_organizer/features/task_feature/presentation/widgets/task_field.dart';
import 'package:uuid/uuid.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart';

import '../bloc/task_bloc.dart';

/// Экран для управления задачами.

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TextEditingController titleController = TextEditingController(); // Контроллер для заголовка задачи
  final TextEditingController descriptionController = TextEditingController(); // Контроллер для описания задачи
  DateTime? dueDate; // Дата выполнения задачи
  bool sortByDate = false; // Флаг для сортировки по дате

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(GetTaskList()); // Запрос списка задач при инициализации
    tz.initializeTimeZones(); // Инициализация временных зон
  }

  /// Открывает диалог выбора даты выполнения задачи.
  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        dueDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }
  }

  /// Открывает диалог для добавления новой задачи.
  void _addingTask() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            height: MediaQuery.of(context).size.height * 0.3,
            child: Column(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Закрытие диалога
                  },
                  icon: Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                ),
                TaskField(
                  controller: titleController,
                  hintText: 'Write the title', // Подсказка для заголовка
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                TaskField(
                  controller: descriptionController,
                  hintText: 'Write the description', // Подсказка для описания
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all(Colors.lightGreenAccent)),
                  onPressed: () async {
                    if (titleController.text.isEmpty ||
                        descriptionController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please fill in both fields.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    await _selectDueDate(context);
                    if (dueDate != null) {
                      Navigator.of(context).pop(); // Закрытие диалога после добавления
                      context.read<TaskBloc>().add(AddNewTask(
                        title: titleController.text,
                        description: descriptionController.text,
                        dueDate: dueDate!,
                      ));
                      titleController.clear(); // Очистка контроллеров
                      descriptionController.clear();
                    }
                  },
                  child: Text('Add task'), // Кнопка для добавления задачи
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return Center(child: CircularProgressIndicator()); // Индикатор загрузки
        } else if (state is TaskSuccessLoad) {
          final tasks = state.tasks; // Получение списка задач

          return Scaffold(
            appBar: AppBar(
              title: Text('Tasks'), // Заголовок экрана
              actions: [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    context.read<TaskBloc>().add(FilterTasks(value)); // Фильтрация задач
                  },
                  itemBuilder: (context) {
                    return {'All', 'Completed', 'Pending'}
                        .map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
                IconButton(
                  icon: Icon(sortByDate ? Icons.arrow_downward : Icons.arrow_upward),
                  onPressed: () {
                    setState(() {
                      sortByDate = !sortByDate; // Переключение флага сортировки
                    });
                    context.read<TaskBloc>().add(SortTasks(sortByDate)); // Сортировка задач
                  },
                ),
              ],
            ),
            body: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: !tasks[index].isDone ? Colors.lightGreenAccent : Colors.redAccent, // Цвет в зависимости от статуса задачи
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (tasks[index].dueDate != null)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Due:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                Text(DateFormat('dd-MM').format(tasks[index].dueDate!), style: TextStyle(fontSize: 12)),
                                Text(DateFormat('kk:mm').format(tasks[index].dueDate!), style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Checkbox(
                                  activeColor: Colors.black,
                                  value: tasks[index].isDone,
                                  onChanged: (bool? value) {
                                    context.read<TaskBloc>().add(UpdateTask(tasks[index].index)); // Обновление статуса задачи
                                  },
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tasks[index].title,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        tasks[index].description,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    context.read<TaskBloc>().add(DeleteTask(tasks[index].index)); // Удаление задачи
                                  },
                                  icon: Icon(Icons.delete, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: _addingTask, // Открытие диалога добавления задачи
              child: Icon(Icons.add, color: Colors.white),
            ),
          );
        } else {
          return Center(child: Text('Error loading tasks')); // Обработка ошибок
        }
      },
    );
  }
}