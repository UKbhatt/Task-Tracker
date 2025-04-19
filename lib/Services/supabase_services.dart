import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:task_tracker/dashboard/task_model.dart';

class SupabaseServices {
  static final client = Supabase.instance.client;

  static void init() async {
    await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL'] ?? 'default_supabase_url',
        anonKey: dotenv.env['ANON_KEY'] ?? 'default_ANON_url');
  }

  static bool get isLoggedIn => client.auth.currentUser != null;

  // adding Task
  static Future<List<Task>> getTask() async {
    final response = await client.from('Task').select();
    return (response as List).map((e) => Task.fromMap(e)).toList();
  }

  // update Task
  static Future<void> UpdateTask(bool isCompleted , String id) async {
    await client.from('Task').update({'isCompleted' : isCompleted}).eq('id', id); 
  }

  //Delete Task
  static Future<void> DeleteTask(String id) async {
    await client.from('Task').delete().eq('id', id); 
  }
}
