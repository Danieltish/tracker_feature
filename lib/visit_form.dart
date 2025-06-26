import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/customer.dart';
import 'models/activity.dart';
import 'services/api_service.dart';
import 'screens/visit_list_screen.dart'; // Corrected import path for VisitListScreen

class VisitForm extends StatefulWidget {
  final List<Customer> customers;
  final List<Activity> activities;
  const VisitForm({Key? key, required this.customers, required this.activities})
    : super(key: key);

  @override
  State<VisitForm> createState() => _VisitFormState();
}

class _VisitFormState extends State<VisitForm> {
  final _formKey = GlobalKey<FormState>();
  int? selectedCustomerId;
  DateTime? visitDate;
  String? location;
  String? status;
  String? notes;
  List<int> selectedActivities = [];
  bool isLoading = false;

  Future<void> addVisit() async {
    setState(() => isLoading = true);
    try {
      final body = {
        'customer_id': selectedCustomerId,
        'visit_date': visitDate?.toUtc().toIso8601String(),
        'status': status,
        'location': location,
        'notes': notes,
        'activities_done': selectedActivities,
      };
      await ApiService.post('visits', body);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Visit added!')));
        _formKey.currentState?.reset();
        setState(() {
          selectedCustomerId = null;
          visitDate = null;
          location = null;
          status = null;
          notes = null;
          selectedActivities = [];
        });
        // Navigate to VisitListScreen after adding a visit
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const VisitListScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF8FAFF), Color(0xFFE3E8F0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Add New Visit',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Customer Dropdown
                    DropdownButtonFormField<int>(
                      value: selectedCustomerId,
                      decoration: const InputDecoration(
                        labelText: 'Customer',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      items: widget.customers
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => selectedCustomerId = val),
                      validator: (val) => val == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 18),
                    // Visit Date & Time Picker
                    GestureDetector(
                      onTap: () async {
                        final now = DateTime.now();
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: now,
                          firstDate: DateTime(now.year - 1),
                          lastDate: DateTime(now.year + 2),
                        );
                        if (pickedDate != null) {
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(now),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              visitDate = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                            });
                          }
                        }
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Visit Date & Time',
                            prefixIcon: Icon(Icons.calendar_today_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (_) =>
                              visitDate == null ? 'Required' : null,
                          controller: TextEditingController(
                            text: visitDate == null
                                ? ''
                                : DateFormat(
                                    'yyyy-MM-dd HH:mm',
                                  ).format(visitDate!.toLocal()),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Location
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        hintText:
                            'Enter city and country (e.g. Nairobi, Kenya)',
                        prefixIcon: Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(),
                        helperText:
                            'Please provide the city and country for the visit',
                      ),
                      onSaved: (val) => location = val,
                    ),
                    const SizedBox(height: 18),
                    // Status Dropdown
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.flag_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Completed',
                          child: Text('Completed'),
                        ),
                        DropdownMenuItem(
                          value: 'Pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'Cancelled',
                          child: Text('Cancelled'),
                        ),
                      ],
                      onChanged: (val) => setState(() => status = val),
                      validator: (val) => val == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 18),
                    // Notes
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Additional details about the visit',
                        prefixIcon: Icon(Icons.note_alt_outlined),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      onSaved: (val) => notes = val,
                    ),
                    const SizedBox(height: 18),
                    // Activities Done (Multi-select)
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Activities Done',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.checklist_outlined),
                      ),
                      child: Column(
                        children: widget.activities
                            .map(
                              (activity) => CheckboxListTile(
                                value: selectedActivities.contains(activity.id),
                                title: Text(activity.description),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                activeColor: Colors.deepPurple,
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      selectedActivities.add(activity.id);
                                    } else {
                                      selectedActivities.remove(activity.id);
                                    }
                                  });
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  _formKey.currentState?.save();
                                  addVisit();
                                }
                              },
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'ADD VISIT',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
