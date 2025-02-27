class Task {
  final String title;
  final String description;
  final bool isDone;
  final int index;
  final DateTime dueDate;

  Task({required this.title,
    required this.description,
    this.isDone = false,
    required this.index,

    required this.dueDate});

  Task toggleCompletion() {
    return Task(title: title,
        description: description,
        isDone: !isDone,
        index: index,

        dueDate: dueDate);
  }
}

