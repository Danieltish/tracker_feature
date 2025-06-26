import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../visit_form.dart';
import '../providers/customers_provider.dart';
import '../providers/activities_provider.dart';

class VisitFormScreen extends ConsumerWidget {
  const VisitFormScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersProvider);
    final activitiesAsync = ref.watch(activitiesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('New Visit'), centerTitle: true),
      body: customersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading customers: $e')),
        data: (customers) {
          return activitiesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) =>
                Center(child: Text('Error loading activities: $e')),
            data: (activities) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: VisitForm(customers: customers, activities: activities),
              );
            },
          );
        },
      ),
    );
  }
}
