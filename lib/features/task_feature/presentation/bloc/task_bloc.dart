
import 'package:bloc/bloc.dart';

import 'package:task_organizer/features/task_feature/data/repo_impl/task_repository.dart';


import '../../domain/models/task.dart';

part 'task_event.dart';

part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc() : super(TaskInitial()) {
    on<GetTaskList>((event, emit) async {
      emit(TaskLoading());
      final tasks = await TaskRepository().getTasks();
      emit(TaskSuccessLoad(tasks: tasks));
    });

    on<AddNewTask>((event, emit) async {
      emit(TaskLoading());
      final task = Task(
          title: event.title,
          description: event.description,
          isDone: false,
          index: (DateTime.now().millisecondsSinceEpoch / 1000).floor(),
          dueDate: event.dueDate);
      TaskRepository().addTask(task);
      final tasks = await TaskRepository().getTasks();
      emit(TaskSuccessLoad(tasks: tasks));
    });

    on<DeleteTask>((event, emit) async {
      emit(TaskLoading());
      TaskRepository().deleteTask(event.index);
      final tasks = await TaskRepository().getTasks();
      emit(TaskSuccessLoad(tasks: tasks));
    });
  }
}
