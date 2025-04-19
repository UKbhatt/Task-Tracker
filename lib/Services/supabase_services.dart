import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseServices {
  static final client = Supabase.instance.client;

  static void init() async{
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? 'default_supabase_url',
      anonKey: dotenv.env['ANON_KEY'] ?? 'default_ANON_url'
      );
  }
}
