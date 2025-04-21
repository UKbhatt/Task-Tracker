import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_tracker/Services/supabase_services.dart';
import 'package:task_tracker/auth/auth_services.dart';
import 'package:task_tracker/auth/login_screen.dart';
import 'package:task_tracker/dashboard/task_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _supabaseServices = SupabaseServices();
  List<Task> _tasks = [];

  Future<void> fetchTask() async {
    final tasks = await _supabaseServices.fetchTasks();
    setState(() => _tasks = tasks);
  }

  Future<void> toggleTask(Task task) async {
    await _supabaseServices.toggleTask(task);
    fetchTask();
  }

  @override
  void initState() {
    super.initState();
    fetchTask();
  }

  Future<void> ShowDialog() async {
    final titleController = TextEditingController();
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add New Task',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Task Title'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => selectedDate = picked);
                  Navigator.of(context).pop();
              ShowDialogWithValues(titleController, picked);
                }
              },
              icon: const Icon(Icons.calendar_today),
              label: const Text('Pick Due Date'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Are you sure you want to logout?',
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      var authServices = AuthServices();
      await authServices.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> ShowDialogWithValues(
      TextEditingController titleController, DateTime selectedDate) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirm Task',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Task Title'),
            ),
            const SizedBox(height: 12),
            Text(
              'Due Date: ${selectedDate.toLocal().toString().split(' ')[0]}',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a title')));
                return;
              }
              await _supabaseServices.addTask(
                  titleController.text, selectedDate);
              Navigator.of(context).pop();
              fetchTask();
            },
            child: const Text('Add Task'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingTasks = _tasks.where((t) => !t.isCompleted).toList();
    final completedTasks = _tasks.where((t) => t.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Dashboard',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: logout,
          )
        ],
      ),
      body: _tasks.isEmpty
          ? Center(
              child: Text(
                'No tasks yet — add one!',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(8),
              children: [
                if (pendingTasks.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      'Pending Tasks',
                      style: GoogleFonts.poppins(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ...pendingTasks.map((task) => _buildTaskTile(task)),
                if (completedTasks.isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    child: Text(
                      'Completed Tasks',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                ...completedTasks.map((task) => _buildTaskTile(task)),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: ShowDialog
    ,
        label: const Text('Add Task'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskTile(Task task) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(
          task.title,
          style: GoogleFonts.poppins(
            fontSize: 17,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          'Due: ${task.dueDate.toLocal().toString().split(' ')[0]}',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        trailing: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => toggleTask(task),
        ),
      ),
    );
  }
}
