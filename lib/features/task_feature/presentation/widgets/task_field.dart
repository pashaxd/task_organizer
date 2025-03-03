import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce/hive.dart';

/// Виджет для текстового поля задачи.

class TaskField extends StatelessWidget {
  final TextEditingController controller; // Контроллер для управления текстом в поле
  final String hintText; // Текст-подсказка для текстового поля

  /// Конструктор для создания экземпляра TaskField.
  ///
  /// [controller] - контроллер для управления текстом в поле.
  /// [hintText] - текст-подсказка, отображаемый в текстовом поле.
  TaskField({super.key, required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height*0.06, // Фиксированная высота текстового поля
       // Фиксированная ширина текстового поля
      decoration: BoxDecoration(
        color: Colors.white, // Цвет фона текстового поля
        borderRadius: BorderRadius.circular(20), // Закругленные углы
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 15, top: 20), // Отступы внутри контейнера
        child: TextField(
          maxLength: 20, // Максимальное количество символов
          controller: controller, // Контроллер для текстового поля
          decoration: InputDecoration(
            hintText: hintText, // Текст-подсказка
            border: InputBorder.none, // Без границы
          ),
        ),
      ),
    );
  }
}
