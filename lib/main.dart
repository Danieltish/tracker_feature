import 'package:flutter/material.dart';
import 'supabase_client.dart';
import 'screens/visit_form_screen.dart';
import 'screens/visit_list_screen.dart';
import 'screens/visit_stats_screen.dart';
import 'screens/add_customer_screen.dart';
import 'screens/add_activity_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visits Tracker')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Add Visit'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VisitFormScreen()),
              ),
            ),
            ElevatedButton(
              child: const Text('View Visits'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VisitListScreen()),
              ),
            ),
            ElevatedButton(
              child: const Text('View Statistics'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VisitStatsScreen()),
              ),
            ),
            ElevatedButton(
              child: const Text('Add Customer'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
              ),
            ),
            ElevatedButton(
              child: const Text('Add Activity'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddActivityScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
