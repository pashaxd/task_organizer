part of 'task_bloc.dart';
class TaskEvent {}

class AddNewTask extends TaskEvent{
  final String title;
  final String description;

  final DateTime dueDate;
  AddNewTask(  {required this.dueDate, required this.title, required this.description, });
}
class GetTaskList extends TaskEvent{
}
class DeleteTask extends TaskEvent {
  final int  index;

  DeleteTask( this.index);
}