import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_organizer/features/auth_feature/data/service/auth_service.dart';
import 'package:task_organizer/features/auth_feature/domain/entity/user.dart';
import 'package:task_organizer/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:task_organizer/features/auth_feature/presentation/bloc/auth_event.dart';
import 'package:task_organizer/features/auth_feature/presentation/bloc/auth_state.dart';
import 'package:task_organizer/features/task_feature/data/repo_impl/task_repository.dart';
import 'package:task_organizer/features/task_feature/domain/models/task.dart';
import 'package:task_organizer/features/task_feature/presentation/bloc/task_bloc.dart';

// Моки для TaskRepository и AuthService
class MockTaskRepository extends Mock implements TaskRepository {}

class MockAuthService extends Mock implements AuthService {}

// Регистрация фиктивных значений для mocktail
void registerFallbackValues() {
  registerFallbackValue(Task(
    title: 'Fallback Task',
    description: 'Fallback Description',
    isDone: false,
    index: 0,
    dueDate: DateTime.now(),
  ));
  registerFallbackValue(AuthLogin(email: 'test@example.com', password: 'password'));
}

void main() {
  registerFallbackValues();

  late TaskBloc taskBloc;
  late MockTaskRepository mockTaskRepository;

  late AuthBloc authBloc;
  late MockAuthService mockAuthService;

  setUp(() {
    // Инициализация моков и блоков
    mockTaskRepository = MockTaskRepository();
    taskBloc = TaskBloc(taskRepository: mockTaskRepository);

    mockAuthService = MockAuthService();
    authBloc = AuthBloc(authService: mockAuthService);
  });

  tearDown(() {
    taskBloc.close();
    authBloc.close();
  });

  group('TaskBloc', () {
    // Проверка начального состояния блока задач
    test('initial state is TaskInitial', () {
      expect(taskBloc.state, isA<TaskInitial>());
    });

    // Тест для получения списка задач
    blocTest<TaskBloc, TaskState>(
      'emits [ TaskSuccessLoad] when GetTaskList is added',
      build: () {
        when(() => mockTaskRepository.getTasks()).thenAnswer((_) async => []);
        return taskBloc;
      },
      act: (bloc) => bloc.add(GetTaskList()),
      expect: () => [
        isA<TaskLoading>(),
        isA<TaskSuccessLoad>(),
      ],
      verify: (_) {
        verify(() => mockTaskRepository.getTasks()).called(1);
      },
    );

    // Тест для добавления новой задачи
    blocTest<TaskBloc, TaskState>(
      'emits [ TaskSuccessLoad] when AddNewTask is added',
      build: () {
        when(() => mockTaskRepository.addTask(any())).thenAnswer((_) async {});
        when(() => mockTaskRepository.getTasks()).thenAnswer((_) async => []);
        return taskBloc;
      },
      act: (bloc) {
        bloc.add(AddNewTask(
          title: 'New Task',
          description: 'New Task Description',
          dueDate: DateTime.now(),
        ));
      },
      expect: () => [

        isA<TaskSuccessLoad>(),
      ],
      verify: (_) {
        verify(() => mockTaskRepository.addTask(any())).called(1);
        verify(() => mockTaskRepository.getTasks()).called(1);
      },
    );

    // Тест для удаления задачи
    blocTest<TaskBloc, TaskState>(
      'emits [ TaskSuccessLoad] when DeleteTask is added',
      build: () {
        when(() => mockTaskRepository.deleteTask(any())).thenAnswer((_) async {});
        when(() => mockTaskRepository.getTasks()).thenAnswer((_) async => []);
        return taskBloc;
      },
      act: (bloc) {
        bloc.add(DeleteTask(0));
      },
      expect: () => [

        isA<TaskSuccessLoad>(),
      ],
      verify: (_) {
        verify(() => mockTaskRepository.deleteTask(any())).called(1);
        verify(() => mockTaskRepository.getTasks()).called(1);
      },
    );

    // Тест для обновления задачи
    blocTest<TaskBloc, TaskState>(
      'emits [ TaskSuccessLoad] when UpdateTask is added',
      build: () {
        when(() => mockTaskRepository.updateTask(any())).thenAnswer((_) async {});
        when(() => mockTaskRepository.getTasks()).thenAnswer((_) async => []);
        return taskBloc;
      },
      act: (bloc) {
        bloc.add(UpdateTask(0));
      },
      expect: () => [

        isA<TaskSuccessLoad>(),
      ],
      verify: (_) {
        verify(() => mockTaskRepository.updateTask(any())).called(1);
        verify(() => mockTaskRepository.getTasks()).called(1);
      },
    );

    // Тест для фильтрации задач
    blocTest<TaskBloc, TaskState>(
      'emits [ TaskSuccessLoad] when FilterTasks is added',
      build: () {
        when(() => mockTaskRepository.getTasks()).thenAnswer((_) async => []);
        return taskBloc;
      },
      act: (bloc) {
        bloc.add(FilterTasks('Completed'));
      },
      expect: () => [

        isA<TaskSuccessLoad>(),
      ],
      verify: (_) {
        verify(() => mockTaskRepository.getTasks()).called(1);
      },
    );

    // Тест для сортировки задач
    blocTest<TaskBloc, TaskState>(
      'emits [ TaskSuccessLoad] when SortTasks is added',
      build: () {
        when(() => mockTaskRepository.getTasks()).thenAnswer((_) async => []);
        return taskBloc;
      },
      act: (bloc) {
        bloc.add(SortTasks(true));
      },
      expect: () => [

        isA<TaskSuccessLoad>(),
      ],
      verify: (_) {
        verify(() => mockTaskRepository.getTasks()).called(1);
      },
    );
  });

  group('AuthBloc', () {
    // Проверка начального состояния блока аутентификации
    test('initial state is AuthLoginScreen', () {
      expect(authBloc.state, isA<AuthLoginScreen>());
    });

    // Тест для успешного входа
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when AuthLogin is added and login is successful',
      build: () {
        when(() => mockAuthService.signInWithEmail(any(), any())).thenAnswer(
              (_) async => UserModel(uid: '123', email: 'test@example.com'),
        );
        return authBloc;
      },
      act: (bloc) {
        bloc.add(AuthLogin(email: 'test@example.com', password: 'password'));
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthSuccess>(),
      ],
      verify: (_) {
        verify(() => mockAuthService.signInWithEmail(any(), any())).called(1);
      },
    );

    // Тест для неудачного входа
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when AuthLogin is added and login fails',
      build: () {
        when(() => mockAuthService.signInWithEmail(any(), any())).thenAnswer((_) async => null);
        return authBloc;
      },
      act: (bloc) {
        bloc.add(AuthLogin(email: 'wrong@example.com', password: 'wrongpassword'));
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>(),
      ],
      verify: (_) {
        verify(() => mockAuthService.signInWithEmail(any(), any())).called(1);
      },
    );

    // Тест для успешной регистрации
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when AuthRegister is added and registration is successful',
      build: () {
        when(() => mockAuthService.registerWithEmail(any(), any())).thenAnswer(
              (_) async => UserModel(uid: '123', email: 'newuser@example.com'),
        );
        return authBloc;
      },
      act: (bloc) {
        bloc.add(AuthRegister(email: 'newuser@example.com', password: 'password'));
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthSuccess>(),
      ],
      verify: (_) {
        verify(() => mockAuthService.registerWithEmail(any(), any())).called(1);
      },
    );

    // Тест для неудачной регистрации
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when AuthRegister is added and registration fails',
      build: () {
        when(() => mockAuthService.registerWithEmail(any(), any())).thenAnswer((_) async => null);
        return authBloc;
      },
      act: (bloc) {
        bloc.add(AuthRegister(email: 'existing@example.com', password: 'password'));
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>(),
      ],
      verify: (_) {
        verify(() => mockAuthService.registerWithEmail(any(), any())).called(1);
      },
    );

    // Тест для переключения между экранами входа и регистрации
    blocTest<AuthBloc, AuthState>(
      'toggles between AuthLoginScreen and AuthRegisterScreen when ToggleMode is added',
      build: () => authBloc,
      act: (bloc) {
        bloc.add(ToggleMode()); // Переключение на AuthRegisterScreen
        bloc.add(ToggleMode()); // Переключение обратно на AuthLoginScreen
      },
      expect: () => [
        isA<AuthRegisterScreen>(), // После первого переключения
        isA<AuthLoginScreen>(),    // После второго переключения
      ],
    );
  });
}