import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/visit.dart';
import '../models/customer.dart';
import '../models/activity.dart';
import '../providers/visits_provider.dart';
import '../providers/customers_provider.dart';
import '../providers/activities_provider.dart';

class VisitStatsScreen extends ConsumerWidget {
  const VisitStatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitsAsync = ref.watch(visitsProvider);
    final customersAsync = ref.watch(customersProvider);
    final activitiesAsync = ref.watch(activitiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Visit Statistics')),
      body: visitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (visits) {
          return customersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error: $e')),
            data: (customers) {
              return activitiesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
                data: (activities) {
                  return _VisitStatsBody(
                    visits: visits,
                    customers: customers,
                    activities: activities,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _VisitStatsBody extends StatelessWidget {
  final List<Visit> visits;
  final List<Customer> customers;
  final List<Activity> activities;

  const _VisitStatsBody({
    Key? key,
    required this.visits,
    required this.customers,
    required this.activities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = visits.length;
    final completed = visits.where((v) => v.status == 'Completed').length;
    final pending = visits.where((v) => v.status == 'Pending').length;
    final cancelled = visits.where((v) => v.status == 'Cancelled').length;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(child: _statCard('Total', total, Colors.blue)),
                        const SizedBox(width: 16),
                        Expanded(child: _statCard('Completed', completed, Colors.green)),
                        const SizedBox(width: 16),
                        Expanded(child: _statCard('Pending', pending, Colors.orange)),
                        const SizedBox(width: 16),
                        Expanded(child: _statCard('Cancelled', cancelled, Colors.red)),
                      ],
                    );
                  } else {
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        _statCard('Total', total, Colors.blue),
                        _statCard('Completed', completed, Colors.green),
                        _statCard('Pending', pending, Colors.orange),
                        _statCard('Cancelled', cancelled, Colors.red),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 32),
              Text(
                'Visits by Status',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final chartWidth = constraints.maxWidth < 400
                      ? constraints.maxWidth
                      : (constraints.maxWidth > 600 ? 400.0 : 350.0);
                  return Center(
                    child: SizedBox(
                      width: chartWidth,
                      height: 220,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              color: Colors.green,
                              value: completed.toDouble(),
                              title: 'Completed',
                              radius: 60,
                              titleStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              color: Colors.orange,
                              value: pending.toDouble(),
                              title: 'Pending',
                              radius: 60,
                              titleStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              color: Colors.red,
                              value: cancelled.toDouble(),
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
                  );
                },
              ),
              const SizedBox(height: 32),
              Text(
                'Visits by Hour (24h)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final chartWidth = constraints.maxWidth < 400
                      ? constraints.maxWidth
                      : (constraints.maxWidth > 600 ? 600.0 : 350.0);
                  return Center(
                    child: SizedBox(
                      width: chartWidth,
                      height: 220,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: _maxVisitsByHour(visits) + 1,
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final hour = value.toInt();
                                  if (constraints.maxWidth < 400 &&
                                      hour % 4 != 0 &&
                                      hour != 23) {
                                    return const SizedBox.shrink();
                                  }
                                  return Text(
                                    hour.toString().padLeft(2, '0'),
                                    style: TextStyle(
                                      fontSize: constraints.maxWidth > 600
                                          ? 13
                                          : 10,
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: _visitsByHour(visits),
                        ),
                      ),
                    ));
                },
              ),
            ],
          ),
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

  int _maxVisitsByHour(List<Visit> visits) {
    final counts = List.filled(24, 0);
    for (final v in visits) {
      counts[v.visitDate.hour]++;
    }
    return counts.reduce((a, b) => a > b ? a : b);
  }

  List<BarChartGroupData> _visitsByHour(List<Visit> visits) {
    final counts = List.filled(24, 0);
    for (final v in visits) {
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
