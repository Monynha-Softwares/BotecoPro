import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final url = dotenv.env['SUPABASE_URL'];
  final key = dotenv.env['SUPABASE_ANON_KEY'];
  if (url == null || key == null) {
    print('Missing env vars');
    return;
  }

  await Supabase.initialize(url: url, anonKey: key);
  final client = Supabase.instance.client;
  print('Connected to $url');

  final email = 'codex_${DateTime.now().millisecondsSinceEpoch}@example.com';
  const password = 'pass1234';

  try {
    final signUpRes = await client.auth.signUp(email: email, password: password);
    print('Signup success: ${signUpRes.user != null}');
  } catch (e) {
    print('Auth error: $e');
  }

  try {
    final rows = await client.from('mesas').select().limit(1);
    print('Select result: $rows');
  } catch (e) {
    print('Select error: $e');
  }

  try {
    final result = await client.rpc('sp_fechar_venda', params: {
      'p_id_venda': 0,
      'p_data': DateTime.now().toIso8601String()
    });
    print('RPC result: $result');
  } catch (e) {
    print('RPC error: $e');
  }
}
