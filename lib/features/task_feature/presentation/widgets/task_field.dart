import 'package:flutter/material.dart';

class TaskField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
   TaskField({super.key, required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(hintText:hintText),
    );
  }
}
