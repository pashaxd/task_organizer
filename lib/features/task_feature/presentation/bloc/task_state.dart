part of 'task_bloc.dart';

abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {

}
class TaskSuccessLoad extends TaskState{
  final List<Task> tasks;
  TaskSuccessLoad({required this.tasks});
}
class TaskUpdate extends TaskState {}
