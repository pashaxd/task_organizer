part of 'task_bloc.dart';

abstract class TaskState {}

class TaskInitial extends TaskState {
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TaskInitial;

  @override
  int get hashCode => runtimeType.hashCode;
}

class TaskLoading extends TaskState {}

class TaskSuccessLoad extends TaskState {
  final List<Task> tasks;

  TaskSuccessLoad({required this.tasks});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is TaskSuccessLoad &&
              tasks == other.tasks);

  @override
  int get hashCode => tasks.hashCode;
}

class TaskUpdate extends TaskState {}