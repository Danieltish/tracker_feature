import 'package:flutter/material.dart';
import '../models/visit.dart';
import '../services/api_service.dart';

class VisitStatsScreen extends StatefulWidget {
  const VisitStatsScreen({Key? key}) : super(key: key);

  @override
  State<VisitStatsScreen> createState() => _VisitStatsScreenState();
}

class _VisitStatsScreenState extends State<VisitStatsScreen> {
  int _total = 0;
  int _completed = 0;
  int _pending = 0;
  int _cancelled = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final visitsJson = await ApiService.fetch('visits');
    final visits = visitsJson.map((e) => Visit.fromJson(e)).toList();
    setState(() {
      _total = visits.length;
      _completed = visits.where((v) => v.status == 'Completed').length;
      _pending = visits.where((v) => v.status == 'Pending').length;
      _cancelled = visits.where((v) => v.status == 'Cancelled').length;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      appBar: AppBar(title: const Text('Visit Statistics')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Visits: $_total',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Completed: $_completed',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'Pending: $_pending',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'Cancelled: $_cancelled',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
