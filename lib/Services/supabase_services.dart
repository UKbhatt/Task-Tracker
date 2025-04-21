import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_tracker/dashboard/task_model.dart';

class SupabaseServices {
  final _client = Supabase.instance.client;

  Future<List<Task>> fetchTasks() async {
    final res = await _client
        .from('tasks')
        .select()
        .eq('user_id', _client.auth.currentUser!.id)
        .order('created_at', ascending: false);
    return (res as List).map((e) => Task.fromMap(e)).toList();
  }

  Future<void> addTask(String title, DateTime dueDate) async {
    await _client.from('tasks').insert({
      'title': title,
      'user_id': _client.auth.currentUser!.id,
      'due_date': dueDate.toIso8601String().substring(0, 10),
    });
  }

  Future<void> toggleTask(Task task) async {
    await _client.from('tasks').update({
      'is_completed': !task.isCompleted,
    }).eq('id', task.id);
  }

  Future<void> deleteTask(int taskId) async {
    await _client.from('tasks').delete().eq('id', taskId);
  }
}
