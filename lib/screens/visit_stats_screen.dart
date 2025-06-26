import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
  List<Visit> _visits = [];

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final visitsJson = await ApiService.fetch('visits');
    final visits = visitsJson.map((e) => Visit.fromJson(e)).toList();
    setState(() {
      _visits = visits;
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statCard('Total', _total, Colors.blue),
                _statCard('Completed', _completed, Colors.green),
                _statCard('Pending', _pending, Colors.orange),
                _statCard('Cancelled', _cancelled, Colors.red),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Visits by Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: Colors.green,
                      value: _completed.toDouble(),
                      title: 'Completed',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: Colors.orange,
                      value: _pending.toDouble(),
                      title: 'Pending',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: Colors.red,
                      value: _cancelled.toDouble(),
                      title: 'Cancelled',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Visits by Hour (24h)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _maxVisitsByHour().toDouble() + 1,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      axisNameWidget: const Text('Visits'),
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      axisNameWidget: const Text('Hour (0-23)'),
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final hour = value.toInt();
                          return Text(hour.toString().padLeft(2, '0'));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _visitsByHour(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, int value, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }

  int _maxVisitsByHour() {
    final counts = List.filled(24, 0);
    for (final v in _visits) {
      counts[v.visitDate.hour]++;
    }
    return counts.reduce((a, b) => a > b ? a : b);
  }

  List<BarChartGroupData> _visitsByHour() {
    final counts = List.filled(24, 0);
    for (final v in _visits) {
      counts[v.visitDate.hour]++;
    }
    return List.generate(
      24,
      (i) => BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: counts[i].toDouble(),
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(4),
            width: 12,
          ),
        ],
      ),
    );
  }
}
