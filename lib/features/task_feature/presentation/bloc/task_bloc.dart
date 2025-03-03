import 'package:bloc/bloc.dart';
import 'package:task_organizer/features/task_feature/data/repo_impl/task_repository.dart';
import '../../domain/models/task.dart';

part 'task_event.dart';
part 'task_state.dart';

/// BLoC для управления состоянием задач.

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository taskRepository; // Репозиторий для работы с задачами
  String currentFilter = 'All'; // Текущий фильтр задач
  bool sortByDate = false; // Флаг для сортировки задач по дате

  TaskBloc({required this.taskRepository}) : super(TaskInitial()) {
    // Обработка события получения списка задач
    on<GetTaskList>((event, emit) async {
      emit(TaskLoading()); // Эмитируем состояние загрузки
      try {
        final tasks = await taskRepository.getTasks(); // Получаем задачи
        final filteredAndSortedTasks = _applySort(_applyFilter(tasks)); // Применяем фильтр и сортировку
        emit(TaskSuccessLoad(tasks: filteredAndSortedTasks)); // Эмитируем успешное состояние
      } catch (e) {
        print('Error fetching tasks: $e');
      }
    });

    // Обработка события добавления новой задачи
    on<AddNewTask>((event, emit) async {
      try {
        final task = Task(
          title: event.title,
          description: event.description,
          isDone: false,
          index: (DateTime.now().millisecondsSinceEpoch / 1000).floor(),
          dueDate: event.dueDate,
        );
        await taskRepository.addTask(task); // Добавляем задачу
        final tasks = await taskRepository.getTasks(); // Получаем обновленный список задач
        final filteredAndSortedTasks = _applySort(_applyFilter(tasks));
        emit(TaskSuccessLoad(tasks: filteredAndSortedTasks)); // Эмитируем успешное состояние
      } catch (e) {
        print('Error adding task: $e');

      }
    });

    // Обработка события удаления задачи
    on<DeleteTask>((event, emit) async {
      try {
        await taskRepository.deleteTask(event.index); // Удаляем задачу
        final tasks = await taskRepository.getTasks(); // Получаем обновленный список задач
        final filteredAndSortedTasks = _applySort(_applyFilter(tasks));
        emit(TaskSuccessLoad(tasks: filteredAndSortedTasks)); // Эмитируем успешное состояние
      } catch (e) {
        print('Error deleting task: $e');

      }
    });

    // Обработка события обновления задачи
    on<UpdateTask>((event, emit) async {
      try {
        await taskRepository.updateTask(event.index); // Обновляем задачу
        final tasks = await taskRepository.getTasks(); // Получаем обновленный список задач
        final filteredAndSortedTasks = _applySort(_applyFilter(tasks));
        emit(TaskSuccessLoad(tasks: filteredAndSortedTasks)); // Эмитируем успешное состояние
      } catch (e) {
        print('Error updating task: $e');

      }
    });

    // Обработка события фильтрации задач
    on<FilterTasks>((event, emit) async {
      currentFilter = event.filter; // Устанавливаем текущий фильтр
      try {
        final tasks = await taskRepository.getTasks(); // Получаем список задач
        emit(TaskSuccessLoad(tasks: _applyFilter(tasks))); // Эмитируем успешное состояние с отфильтрованными задачами
      } catch (e) {
        print('Error filtering tasks: $e');

      }
    });

    // Обработка события сортировки задач
    on<SortTasks>((event, emit) async {
      sortByDate = event.sortByDate; // Устанавливаем флаг сортировки
      try {
        final tasks = await taskRepository.getTasks(); // Получаем список задач
        final filteredTasks = _applyFilter(tasks);
        emit(TaskSuccessLoad(tasks: _applySort(filteredTasks))); // Эмитируем успешное состояние с отсортированными задачами
      } catch (e) {
        print('Error sorting tasks: $e');

      }
    });
  }

  /// Применяет фильтр к списку задач.
  List<Task> _applyFilter(List<Task> tasks) {
    final filteredTasks = tasks.where((task) {
      if (currentFilter == 'Completed') {
        return task.isDone; // Фильтруем завершенные задачи
      } else if (currentFilter == 'Pending') {
        return !task.isDone; // Фильтруем незавершенные задачи
      }
      return true; // Возвращаем все задачи, если фильтр "Все"
    }).toList();

    return filteredTasks; // Возвращаем отфильтрованные задачи
  }

  /// Применяет сортировку к списку задач.
  List<Task> _applySort(List<Task> tasks) {
    if (sortByDate) {
      tasks.sort((a, b) {
        return a.dueDate.compareTo(b.dueDate); // Сортировка по возрастанию даты
      });
    } else {
      tasks.sort((a, b) {
        return b.dueDate.compareTo(a.dueDate); // Сортировка по убыванию даты
      });
    }

    return tasks; // Возвращаем отсортированные задачи
  }
}