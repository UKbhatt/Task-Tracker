import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_tracker/Services/supabase_services.dart';
import 'package:task_tracker/auth/auth_services.dart';
import 'package:task_tracker/auth/login_screen.dart';
import '../theme/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabaseServices = SupabaseServices();
  final authServices = AuthServices();
  int totalTasks = 0;
  int completedTasks = 0;
  int pendingTasks = 0;
  String userEmail = '';
  bool isLoading = true;

  Future<void> fetchProfileData() async {
    try {
      final tasks = await _supabaseServices.fetchTasks();
      setState(() {
        totalTasks = tasks.length;
        completedTasks = tasks.where((t) => t.isCompleted).length;
        pendingTasks = tasks.where((t) => !t.isCompleted).length;
        userEmail = authServices.getCurrentUser()?.email ?? 'Unknown';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error loading profile data: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> logout() async {
    await authServices.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text('Your Profile',
            style: GoogleFonts.poppins(color: kPrimaryTextColor)),
        centerTitle: true,
        backgroundColor: Colors.amber.withOpacity(0.9),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kBackgroundGradientStart, kBackgroundGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: kActiveCheckboxColor.withOpacity(0.8),
                      child: Icon(Icons.person,
                          size: 50, color: kPrimaryTextColor),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      userEmail,
                      style: GoogleFonts.poppins(
                          fontSize: 18, color: kPrimaryTextColor),
                    ),
                    const SizedBox(height: 30),
                    _buildStatTile('Total Tasks', totalTasks),
                    _buildStatTile('Completed Tasks', completedTasks),
                    _buildStatTile('Pending Tasks', pendingTasks),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kActiveCheckboxColor,
                        foregroundColor: kPrimaryTextColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStatTile(String title, int value) {
    return Card(
      color: kCardColor,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 16, color: kPrimaryTextColor),
        ),
        trailing: Text(
          value.toString(),
          style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: kPrimaryTextColor),
        ),
      ),
    );
  }
}
