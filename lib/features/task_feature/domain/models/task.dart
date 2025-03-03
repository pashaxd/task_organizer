/// Модель для представления задачи.
///
/// Этот класс описывает структуру задачи, включая её заголовок,
/// описание, статус выполнения и дату выполнения.
class Task {
  final String title;        // Заголовок задачи
  final String description;  // Описание задачи
  final bool isDone;        // Статус выполнения задачи (выполнена/не выполнена)
  final int index;          // Индекс задачи в списке
  final DateTime dueDate;   // Дата выполнения задачи

  /// Конструктор для создания экземпляра Task.
  Task({
    required this.title,
    required this.description,
    required this.isDone,
    required this.index,
    required this.dueDate,
  });

  /// Метод для переключения статуса выполнения задачи.
  ///
  /// Возвращает новый экземпляр Task с изменённым статусом isDone.
  Task toggleCompletion() {
    return Task(
      title: title,
      description: description,
      isDone: !isDone,        // Переключение статуса выполнения
      index: index,
      dueDate: dueDate,
    );
  }
}
