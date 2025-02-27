
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:task_organizer/features/auth_feature/presentation/page/auth_screen.dart';
import 'features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'features/task_feature/data/models/task_model/task_model.dart';
import 'features/task_feature/presentation/bloc/task_bloc.dart';
import 'features/task_feature/presentation/page/task_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  Hive.registerAdapter(TaskModelAdapter());
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc() ),
        BlocProvider(create: (context) => TaskBloc() ),
      ],
      child:  MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;
            return user != null ? TaskScreen() : AuthScreen();
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}