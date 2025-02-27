import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_organizer/features/auth_feature/presentation/page/login_screen.dart';
import 'package:task_organizer/features/auth_feature/presentation/page/register_screen.dart';
import 'package:task_organizer/features/task_feature/presentation/page/task_screen.dart';
import '../widgets/auth_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) =>  TaskScreen()),
              );
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthLoginScreen) {
                return LoginScreen(
                  toggle: () => context.read<AuthBloc>().add(ToggleMode()),
                );
              } else if (state is AuthRegisterScreen) {
                return RegisterScreen(
                  toggle: () => context.read<AuthBloc>().add(ToggleMode()),
                );
              } else if (state is AuthFailure) {

                return LoginScreen(
                  toggle: () => context.read<AuthBloc>().add(ToggleMode()),
                );
              }
              else{
                return CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }
}