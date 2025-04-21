import 'package:flutter/material.dart';
import 'task_model.dart';

class TaskTile extends StatelessWidget {
  final Task task;

  TaskTile({required this.task});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(task.title),
      subtitle: Text(task.dueDate as String),
      trailing: Icon(
        task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
        color: task.isCompleted ? Colors.green : Colors.red,
      ),
    );
  }
}
