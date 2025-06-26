import 'package:flutter/material.dart';
import '../models/visit.dart';
import '../models/customer.dart';
import '../services/api_service.dart';

class VisitListScreen extends StatefulWidget {
  const VisitListScreen({Key? key}) : super(key: key);

  @override
  State<VisitListScreen> createState() => _VisitListScreenState();
}

class _VisitListScreenState extends State<VisitListScreen> {
  List<Visit> _visits = [];
  List<Customer> _customers = [];
  bool _loading = true;
  String _search = '';
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final visitsJson = await ApiService.fetch('visits');
    final customersJson = await ApiService.fetch('customers');
    setState(() {
      _visits = visitsJson.map((e) => Visit.fromJson(e)).toList();
      _customers = customersJson.map((e) => Customer.fromJson(e)).toList();
      _loading = false;
    });
  }

  List<Visit> get _filteredVisits {
    var visits = _visits;
    if (_search.isNotEmpty) {
      visits = visits.where((v) {
        final customer = _customers.firstWhere(
          (c) => c.id == v.customerId,
          orElse: () => Customer(id: 0, name: '', createdAt: DateTime.now()),
        );
        return customer.name.toLowerCase().contains(_search.toLowerCase());
      }).toList();
    }
    if (_statusFilter != null) {
      visits = visits.where((v) => v.status == _statusFilter).toList();
    }
    return visits;
  }

  String _customerName(int id) => _customers
      .firstWhere(
        (c) => c.id == id,
        orElse: () => Customer(id: 0, name: '', createdAt: DateTime.now()),
      )
      .name;

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
                labelText: 'Search by customer',
              ),
              onChanged: (val) => setState(() => _search = val),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              value: _statusFilter,
              hint: const Text('Filter by status'),
              items: [
                'Completed',
                'Pending',
                'Cancelled',
              ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _statusFilter = val),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredVisits.length,
              itemBuilder: (context, i) {
                final visit = _filteredVisits[i];
                return ListTile(
                  title: Text(_customerName(visit.customerId)),
                  subtitle: Text(
                    '${visit.status} on ${visit.visitDate.toLocal().toString().split(' ')[0]}',
                  ),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // Could navigate to details or edit
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
