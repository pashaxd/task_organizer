import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_organizer/features/auth_feature/presentation/bloc/auth_event.dart';
import 'package:task_organizer/features/auth_feature/presentation/bloc/auth_state.dart';
import 'package:task_organizer/features/task_feature/data/repo_impl/task_repository.dart';
import 'package:task_organizer/features/task_feature/domain/models/task.dart';
import 'package:task_organizer/features/task_feature/presentation/bloc/task_bloc.dart';
import 'package:task_organizer/features/auth_feature/data/service/auth_service.dart';
import 'package:task_organizer/features/auth_feature/domain/entity/user.dart';
import 'package:task_organizer/features/auth_feature/presentation/bloc/auth_bloc.dart';

// Моки TaskRepository и AuthService
class MockTaskRepository extends Mock implements TaskRepository {}
class MockAuthService extends Mock implements AuthService {}

// Создаём фиктивный экземпляр Task
final dummyTask = Task(
  title: 'Dummy Task',
  description: 'Dummy Description',
  isDone: false,
  index: 0,
  dueDate: DateTime.now(),
);

void main() {
  setUpAll(() {
    // Регистрируем фиктивные значения для типов, используемых в моках
    registerFallbackValue(dummyTask);
    registerFallbackValue(0); // Для типа int
    registerFallbackValue(DateTime.now()); // Для типа DateTime
  });

  group('Интеграционные тесты для функций Task и Auth', () {
    late MockTaskRepository mockTaskRepository;
    late MockAuthService mockAuthService;
    late TaskBloc taskBloc;
    late AuthBloc authBloc;

    setUp(() {
      mockTaskRepository = MockTaskRepository();
      mockAuthService = MockAuthService();
      taskBloc = TaskBloc(taskRepository: mockTaskRepository);
      authBloc = AuthBloc(authService: mockAuthService);
    });

    tearDown(() {
      taskBloc.close();
      authBloc.close();
    });

    // Тест AuthBloc
    blocTest<AuthBloc, AuthState>(
      'AuthBloc: Регистрация и вход',
      build: () => authBloc,
      act: (bloc) {
        // Мокаем успешную регистрацию
        when(() => mockAuthService.registerWithEmail('test@example.com', 'password'))
            .thenAnswer((_) async => UserModel(uid: '123', email: 'test@example.com'));

        // Мокаем успешный вход
        when(() => mockAuthService.signInWithEmail('test@example.com', 'password'))
            .thenAnswer((_) async => UserModel(uid: '123', email: 'test@example.com'));

        // Тригерим регистрацию
        bloc.add(AuthRegister(email: 'test@example.com', password: 'password'));

        // Тригерим вход
        bloc.add(AuthLogin(email: 'test@example.com', password: 'password'));
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthSuccess>(), // Успешная регистрация
        isA<AuthLoading>(),
        isA<AuthSuccess>(), // Успешный вход
      ],
    );

    // Тест TaskBloc
    blocTest<TaskBloc, TaskState>(
      'TaskBloc: Добавление, удаление и обновление задач',
      build: () => taskBloc,
      act: (bloc) {
        // Мокаем список задач
        final tasks = [
          Task(
            title: 'Task 1',
            description: 'Description 1',
            isDone: false,
            index: 1,
            dueDate: DateTime.now(),
          ),
          Task(
            title: 'Task 2',
            description: 'Description 2',
            isDone: true,
            index: 2,
            dueDate: DateTime.now(),
          ),
        ];

        // Настраиваем моки репозитория
        when(() => mockTaskRepository.getTasks()).thenAnswer((_) async => tasks);
        when(() => mockTaskRepository.addTask(any())).thenAnswer((_) async {});
        when(() => mockTaskRepository.deleteTask(any())).thenAnswer((_) async {});
        when(() => mockTaskRepository.updateTask(any())).thenAnswer((_) async {});

        // Тригерим события
        bloc.add(GetTaskList());
        bloc.add(AddNewTask(
          title: 'New Task',
          description: 'New Description',
          dueDate: DateTime.now(),
        ));
        bloc.add(DeleteTask(1));
        bloc.add(UpdateTask(2));
      },
      expect: () => [
        isA<TaskLoading>(),
        isA<TaskSuccessLoad>(), // После GetTaskList


        isA<TaskSuccessLoad>(), // После AddNewTask


        isA<TaskSuccessLoad>(), // После DeleteTask

        isA<TaskSuccessLoad>(), // Финальное состояние
      ],
    );
  });
}