import 'package:flutter/material.dart';
import '../models/visit.dart';
import '../models/customer.dart';
import '../models/activity.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class VisitListScreen extends StatefulWidget {
  const VisitListScreen({Key? key}) : super(key: key);

  @override
  State<VisitListScreen> createState() => _VisitListScreenState();
}

class _VisitListScreenState extends State<VisitListScreen> {
  List<Visit> _visits = [];
  List<Customer> _customers = [];
  List<Activity> _activities = [];
  bool _loading = true;
  String _search = '';
  String? _statusFilter;
  String? _sortBy = 'recent';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final visitsJson = await ApiService.fetch('visits');
    final customersJson = await ApiService.fetch('customers');
    final activitiesJson = await ApiService.fetch('activities');
    setState(() {
      _visits = visitsJson.map((e) => Visit.fromJson(e)).toList();
      _customers = customersJson.map((e) => Customer.fromJson(e)).toList();
      _activities = activitiesJson.map((e) => Activity.fromJson(e)).toList();
      _loading = false;
    });
  }

  List<Visit> get _filteredVisits {
    var visits = List<Visit>.from(_visits);
    // Sort
    switch (_sortBy) {
      case 'recent':
        visits.sort((a, b) => b.visitDate.compareTo(a.visitDate));
        break;
      case 'oldest':
        visits.sort((a, b) => a.visitDate.compareTo(b.visitDate));
        break;
      case 'name':
        visits.sort(
          (a, b) => _customerName(
            a.customerId,
          ).compareTo(_customerName(b.customerId)),
        );
        break;
      case 'city':
        visits.sort((a, b) => (a.location ?? '').compareTo(b.location ?? ''));
        break;
    }
    // Filter by status
    if (_statusFilter != null) {
      visits = visits.where((v) => v.status == _statusFilter).toList();
    }
    // Search by customer name
    if (_search.isNotEmpty) {
      visits = visits.where((v) {
        final customer = _customers.firstWhere(
          (c) => c.id == v.customerId,
          orElse: () => Customer(id: 0, name: '', createdAt: DateTime.now()),
        );
        return customer.name.toLowerCase().contains(_search.toLowerCase());
      }).toList();
    }
    return visits;
  }

  String _customerName(int id) => _customers
      .firstWhere(
        (c) => c.id == id,
        orElse: () => Customer(id: 0, name: '', createdAt: DateTime.now()),
      )
      .name;

  List<String> _activityDescriptions(List<int> ids) => _activities
      .where((a) => ids.contains(a.id))
      .map((a) => a.description)
      .toList();

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      appBar: AppBar(title: const Text('Visits List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by customer name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => setState(() => _search = val),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _sortBy,
                    hint: const Text('Sort by'),
                    items: const [
                      DropdownMenuItem(
                        value: 'recent',
                        child: Text('Most Recent'),
                      ),
                      DropdownMenuItem(value: 'oldest', child: Text('Oldest')),
                      DropdownMenuItem(
                        value: 'name',
                        child: Text('Name (A-Z)'),
                      ),
                      DropdownMenuItem(
                        value: 'city',
                        child: Text('City (A-Z)'),
                      ),
                    ],
                    onChanged: (val) => setState(() => _sortBy = val),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: _statusFilter,
                    hint: const Text('Filter by status'),
                    items: ['Completed', 'Pending', 'Cancelled']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => setState(() => _statusFilter = val),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredVisits.isEmpty
                ? const Center(child: Text('No visits found.'))
                : ListView.builder(
                    itemCount: _filteredVisits.length,
                    itemBuilder: (context, i) {
                      final visit = _filteredVisits[i];
                      final customer = _customerName(visit.customerId);
                      final activities = _activityDescriptions(
                        visit.activitiesDone,
                      );
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    customer,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusColor(
                                        visit.status,
                                      ).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      visit.status,
                                      style: TextStyle(
                                        color: _statusColor(visit.status),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    DateFormat(
                                      'yyyy-MM-dd – HH:mm',
                                    ).format(visit.visitDate.toLocal()),
                                  ),
                                ],
                              ),
                              if (visit.location != null &&
                                  visit.location!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 18),
                                    const SizedBox(width: 6),
                                    Expanded(child: Text(visit.location!)),
                                  ],
                                ),
                              ],
                              if (visit.notes != null &&
                                  visit.notes!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.notes, size: 18),
                                    const SizedBox(width: 6),
                                    Expanded(child: Text(visit.notes!)),
                                  ],
                                ),
                              ],
                              if (activities.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.check_circle, size: 18),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Wrap(
                                        spacing: 6,
                                        runSpacing: 2,
                                        children: activities
                                            .map(
                                              (desc) => Chip(
                                                label: Text(desc),
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .secondary
                                                        .withOpacity(0.15),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
