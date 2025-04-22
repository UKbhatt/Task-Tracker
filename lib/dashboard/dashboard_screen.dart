import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_tracker/Services/supabase_services.dart';
import 'package:task_tracker/auth/auth_services.dart';
import 'package:task_tracker/auth/login_screen.dart';
import 'package:task_tracker/dashboard/task_model.dart';
import 'package:task_tracker/pages/profile_page.dart';
import 'package:task_tracker/theme/colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _supabaseServices = SupabaseServices();
  final _authServices = AuthServices();
  List<Task> _tasks = [];
  int _currentIndex = 0;

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

  Future<void> logout() async {
    await showDialog<bool>(
      context: context,
      builder: (context) => _glassDialog(
        title: 'Logout',
        content: 'Are you sure you want to logout?',
        confirmText: 'Logout',
        cancelText: 'Cancel',
        onConfirm: () async {
          await _authServices.signOut();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
            (route) => false,
          );
        },
      ),
    );
  }

  Future<void> ShowDialog() async {
    final titleController = TextEditingController();
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (context) => _glassDialog(
        title: 'Add New Task',
        contentWidget: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: TextStyle(color: kPrimaryTextColor),
              decoration: const InputDecoration(labelText: 'Task Title', labelStyle: TextStyle(color: Colors.white70)),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                  builder: (context, child) {
                    return Theme(data: ThemeData.dark(), child: child!);
                  },
                );
                if (picked != null) {
                  Navigator.of(context).pop();
                  ShowDialogWithValues(titleController, picked);
                }
              },
              icon: const Icon(Icons.calendar_today),
              label: const Text('Pick Due Date'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kActiveCheckboxColor,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
        confirmText: null,
        cancelText: 'Close',
      ),
    );
  }

  Future<void> ShowDialogWithValues(
      TextEditingController controller, DateTime date) async {
    await showDialog(
      context: context,
      builder: (context) => _glassDialog(
        title: 'Confirm Task',
        contentWidget: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              style: TextStyle(color: kPrimaryTextColor),
              decoration: const InputDecoration(labelText: 'Task Title'),
            ),
            const SizedBox(height: 12),
            Text(
              'Due Date: ${date.toLocal().toString().split(' ')[0]}',
              style:
                  GoogleFonts.poppins(fontSize: 16, color: kPrimaryTextColor),
            ),
          ],
        ),
        confirmText: 'Add Task',
        cancelText: 'Cancel',
        onConfirm: () async {
          if (controller.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Please enter a title',
                      style: TextStyle(color: Colors.white))),
            );
            return;
          }
          await _supabaseServices.addTask(controller.text, date);
          Navigator.of(context).pop();
          fetchTask();
        },
      ),
    );
  }

  Widget _glassDialog({
    required String title,
    String? content,
    Widget? contentWidget,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: kPrimaryTextColor,
                ),
              ),
              const SizedBox(height: 10),
              contentWidget ??
                  Text(
                    content ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: kPrimaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (cancelText != null)
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        cancelText,
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  if (confirmText != null)
                    ElevatedButton(
                      onPressed: () {
                        onConfirm?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kActiveCheckboxColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        elevation: 0,
                      ),
                      child: Text(
                        confirmText,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskTile(Task task) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: kCardColor,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text(
          task.title,
          style: GoogleFonts.poppins(
            fontSize: 17,
            color: kPrimaryTextColor,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          'Due: ${task.dueDate.toLocal().toString().split(' ')[0]}',
          style: GoogleFonts.poppins(fontSize: 14, color: kSecondaryTextColor),
        ),
        trailing: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => toggleTask(task),
          activeColor: kActiveCheckboxColor,
          checkColor: Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingTasks = _tasks.where((t) => !t.isCompleted).toList();
    final completedTasks = _tasks.where((t) => t.isCompleted).toList();

    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kBackgroundGradientStart, kBackgroundGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _tasks.isEmpty
            ? Center(
                child: Text('No tasks yet — add one!',
                    style: GoogleFonts.poppins(
                        fontSize: 16, color: kSecondaryTextColor)))
            : ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  if (pendingTasks.isNotEmpty)
                    Text('Pending Tasks',
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            color: kPendingTitleColor,
                            fontWeight: FontWeight.bold)),
                  ...pendingTasks.map(_buildTaskTile),
                  if (completedTasks.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text('Completed Tasks',
                          style: GoogleFonts.poppins(
                              fontSize: 20, color: kCompletedTitleColor)),
                    ),
                  ...completedTasks.map(_buildTaskTile),
                ],
              ),
      ),
      appBar: AppBar(
        title: Text('Task Dashboard',
            style: GoogleFonts.poppins(color: kPrimaryTextColor)),
        centerTitle: true,
        backgroundColor: Colors.yellow.withOpacity(0.2),
        elevation: 0,
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            backgroundColor: Colors.white.withOpacity(0.1),
            selectedItemColor: kPrimaryTextColor,
            unselectedItemColor: kSecondaryTextColor,
            onTap: (index) {
              if (index == 1) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()));
              } else if (index == 2) {
                ShowDialog();
              } else if (index == 3) {
                logout();
              }
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.list), label: 'Dashboard'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profile'),
              BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add Task'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.logout), label: 'Logout'),
            ],
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }
}
