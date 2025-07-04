import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: 'https://npnzujqsmlowrvpnnpef.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5wbnp1anFzbWxvd3J2cG5ucGVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA3NTU4MDEsImV4cCI6MjA2NjMzMTgwMX0.tSW3I6mI2XNjRxKp-f29g1yXs5T9f_pZ_XhzfWT4kKU',
  );
}

Future<void> testSupabaseConnection() async {
  try {
    final response = await Supabase.instance.client
        .from('visits')
        .select()
        .limit(1);
    if (response.isNotEmpty) {
      print('Supabase connection successful!');
    } else {
      print('Supabase connection failed or table missing.');
    }
  } catch (e) {
    print('Supabase connection error:  ${e.toString()}');
  }
}
