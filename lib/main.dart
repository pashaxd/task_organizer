import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:task_organizer/features/auth_feature/data/service/auth_service.dart';
import 'package:task_organizer/features/auth_feature/presentation/page/auth_screen.dart';
import 'package:task_organizer/features/task_feature/data/repo_impl/task_repository.dart';
import 'package:task_organizer/features/task_feature/data/services/noti_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'features/task_feature/presentation/bloc/task_bloc.dart';
import 'features/task_feature/presentation/page/task_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

///Точка входа приложения
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform, // Используйте сгенерированные параметры
  );
  // Инициализация временных зон
  tz.initializeTimeZones();
// Инициализация уведомлений
  await NotiService().initNotification();

  runApp(MyApp());
}

/// Основной класс приложения, который управляет состоянием и отображением.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Провайдер для блока аутентификации
        BlocProvider(create: (context) => AuthBloc(authService: AuthService())),
        // Провайдер для блока задач
        BlocProvider(
          create: (context) =>
              TaskBloc(
                taskRepository: TaskRepository(
                  firestore: FirebaseFirestore.instance,
                  auth: FirebaseAuth.instance,
                  notiService: NotiService(),
                ),
              ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          // Стрим для отслеживания изменений состояния аутентификации
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              User? user = snapshot.data; // Получаем текущего пользователя
              // Возвращаем экран задач или экран аутентификации в зависимости от состояния пользователя
              return user != null ? TaskScreen() : AuthScreen();
            }
            return const Center(
                child: CircularProgressIndicator()); // Индикатор загрузки
          },
        ),
      ),
    );
  }}