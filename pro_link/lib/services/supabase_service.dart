import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  const SupabaseConfig._();

  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}

Future<void> initializeSupabase() async {
  if (!SupabaseConfig.isConfigured) return;

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
    authOptions: const FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce),
  );
}

final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  if (!SupabaseConfig.isConfigured) return null;

  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
});
