class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime dueDate;

  Task(
      {required this.id,
      required this.title,
      required this.isCompleted,
      required this.dueDate});

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      isCompleted: map['is_completed'],
      dueDate: DateTime.parse(map['due_date']),
    );
  }
}
