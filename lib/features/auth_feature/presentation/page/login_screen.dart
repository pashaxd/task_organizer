import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_field.dart';


class LoginScreen extends StatelessWidget {
  final Function toggle;

  const LoginScreen({super.key, required this.toggle});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Column(
      spacing: 40,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Welcome',
          style: TextStyle(fontSize: 50),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.4,
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30), color: Colors.teal),
          child: Padding(
            padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
            child: Column(
              children: [
                Text(
                  'Login',
                  style: TextStyle(fontSize: 30),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                AuthField(hintText: 'Email', controller: emailController),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                AuthField(hintText: 'Password', controller: passwordController),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                TextButton(
                  onPressed: () {
                    toggle();
                  },
                  child: Text('Dont have an account?',style: TextStyle(fontSize: 15,color: Colors.black),),
                ),
              ],
            ),
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.05,
          width: MediaQuery.of(context).size.width * 0.8,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.greenAccent),
            ),
            onPressed: () {
              context.read<AuthBloc>().add(
                    AuthLogin(emailController.text, passwordController.text),
                  );
            },
            child: Text('Let\'s go'),
          ),
        ),
      ],
    );
  }
}
