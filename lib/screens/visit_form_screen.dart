import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../models/activity.dart';
import '../services/api_service.dart';

class VisitFormScreen extends StatefulWidget {
  const VisitFormScreen({Key? key}) : super(key: key);

  @override
  State<VisitFormScreen> createState() => _VisitFormScreenState();
}

class _VisitFormScreenState extends State<VisitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedCustomerId;
  List<int> _selectedActivities = [];
  DateTime? _visitDate;
  String _status = 'Completed';
  String? _location;
  String? _notes;

  List<Customer> _customers = [];
  List<Activity> _activities = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final customersJson = await ApiService.fetch('customers');
    final activitiesJson = await ApiService.fetch('activities');
    setState(() {
      _customers = customersJson.map((e) => Customer.fromJson(e)).toList();
      _activities = activitiesJson.map((e) => Activity.fromJson(e)).toList();
      _loading = false;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _selectedCustomerId == null ||
        _visitDate == null)
      return;
    _formKey.currentState!.save();
    final data = {
      'customer_id': _selectedCustomerId,
      'visit_date': _visitDate!.toIso8601String(),
      'status': _status,
      'location': _location,
      'notes': _notes,
      'activities_done': _selectedActivities,
    };
    await ApiService.post('visits', data);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Visit added!')));
      _formKey.currentState!.reset();
      setState(() {
        _selectedCustomerId = null;
        _selectedActivities = [];
        _visitDate = null;
        _status = 'Completed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      appBar: AppBar(title: const Text('Add Visit')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<int>(
                value: _selectedCustomerId,
                decoration: const InputDecoration(labelText: 'Customer'),
                items: _customers
                    .map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedCustomerId = val),
                validator: (val) => val == null ? 'Select a customer' : null,
              ),
              const SizedBox(height: 16),
              InputDatePickerFormField(
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                initialDate: _visitDate ?? DateTime.now(),
                onDateSaved: (date) => _visitDate = date,
                fieldLabelText: 'Visit Date',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ['Completed', 'Pending', 'Cancelled']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) =>
                    setState(() => _status = val ?? 'Completed'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Location'),
                onSaved: (val) => _location = val,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Notes'),
                onSaved: (val) => _notes = val,
              ),
              const SizedBox(height: 16),
              Text(
                'Activities Completed',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ..._activities.map(
                (activity) => CheckboxListTile(
                  title: Text(activity.description),
                  value: _selectedActivities.contains(activity.id),
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _selectedActivities.add(activity.id);
                      } else {
                        _selectedActivities.remove(activity.id);
                      }
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Add Visit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
