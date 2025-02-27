import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';
import 'package:task_organizer/features/task_feature/presentation/widgets/task_field.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart';

import '../bloc/task_bloc.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime? dueDate;

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(GetTaskList());
    tz.initializeTimeZones();
  }

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
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.close),
                ),
                TaskField(
                  controller: titleController,
                  hintText: 'Write the title',
                ),
                SizedBox(height: 16.0),
                TaskField(
                  controller: descriptionController,
                  hintText: 'Write the description',
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
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
                      Navigator.of(context).pop();
                      context.read<TaskBloc>().add(AddNewTask(
                            title: titleController.text,
                            description: descriptionController.text,
                            dueDate: dueDate!,
                          ));
                      titleController.text = '';
                      descriptionController.text = '';
                    }
                  },
                  child: Text('Add task'),
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
          return Center(child: CircularProgressIndicator());
        } else if (state is TaskSuccessLoad) {
          final tasks = state.tasks;
          return Scaffold(
            appBar: AppBar(
              title: Text('Tasks'),
            ),
            body: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      height: MediaQuery.of(context).size.height * 0.1,
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.green,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tasks[index].title,
                                style: TextStyle(fontSize: 25),
                              ),
                              Text(tasks[index].description),
                              if (tasks[index].dueDate != null)
                                Text(
                                  'Due: ${DateFormat('dd-MM – kk:mm').format(tasks[index].dueDate!)}',
                                  style: TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {
                              context
                                  .read<TaskBloc>()
                                  .add(DeleteTask(tasks[index].index));
                            },
                            icon: Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                _addingTask();
              },
              child: Icon(Icons.add),
            ),
          );
        } else {
          return Center(child: Text('Error loading tasks'));
        }
      },
    );
  }
}
