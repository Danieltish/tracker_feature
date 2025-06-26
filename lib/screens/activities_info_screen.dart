import 'package:flutter/material.dart';
import 'add_customer_screen.dart';

class ActivitiesInfoScreen extends StatelessWidget {
  const ActivitiesInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activities Info')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activities are types of actions that can be completed during a visit.\n'
              'You can only select activities when adding a visit.\n\n'
              'To add new activities, please use the Supabase dashboard or ask your admin.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
