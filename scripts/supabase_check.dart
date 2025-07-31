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
    final email = 'codex_${DateTime.now().millisecondsSinceEpoch}@example.com';
    final password = 'pass1234';
    final signUp = await client.auth.signUp(email: email, password: password);
    print('SignUp: ${signUp.user != null}');
  } catch (e) {
    print('Auth error: $e');
  }

  try {
    final resp = await client.from('mesas').select().limit(1);
    print('Query result: $resp');
  } catch (e) {
    print('Error executing select: $e');
  }

  try {
    final result = await client.rpc('sp_fechar_venda', params: {
      'p_id_venda': 0,
      'p_data': DateTime.now().toIso8601String(),
    });
    print('RPC result: $result');
  } catch (e) {
    print('RPC error: $e');
  }

  final session = client.auth.currentSession;
  print('Current session: $session');
}
