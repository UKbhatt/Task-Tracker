import 'package:supabase_flutter/supabase_flutter.dart';

class AuthServices {
  final _client = Supabase.instance.client;

  User? getCurrentUser() {
    return Supabase.instance.client.auth.currentUser;
  }

  Future<AuthResponse> signUp(String email, String password) {
    return _client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn(String email, String password) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
