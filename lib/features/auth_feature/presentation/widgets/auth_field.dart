import 'package:flutter/material.dart';

class AuthField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  const AuthField({super.key, required this.hintText, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), color: Colors.greenAccent),
        child: TextField(
          decoration:
              InputDecoration(border: InputBorder.none, hintText: hintText,hintStyle: TextStyle(fontWeight: FontWeight.w300)),
          controller: controller,
        ));
  }
}
