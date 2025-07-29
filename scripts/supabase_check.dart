import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  final url = Platform.environment['SUPABASE_URL'];
  final key = Platform.environment['SUPABASE_ANON_KEY'];
  if (url == null || key == null) {
    print('Missing environment variables');
    return;
  }
  final client = SupabaseClient(url, key);
  print('Connected to $url');

  try {
    final resp = await client.from('fornecedores').select().limit(1);
    print('Query result: $resp');
  } catch (e) {
    print('Error executing test query: $e');
  }

  final session = client.auth.currentSession;
  print('Current session: $session');
}
