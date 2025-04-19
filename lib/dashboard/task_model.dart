// creating Task model to receive information

import 'package:flutter/foundation.dart';

class Task {
  final String id;
  final String title;
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  factory Task.fromMap(Map<String, dynamic>map)
  {
    return Task(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted']
      );
  }
}
