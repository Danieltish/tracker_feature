import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity.dart';
import '../repositories/activity_repository.dart';

final activityRepositoryProvider = Provider<ActivityRepository>(
  (ref) => ActivityRepository(),
);

final activitiesProvider = FutureProvider<List<Activity>>((ref) async {
  final repo = ref.watch(activityRepositoryProvider);
  return repo.fetchActivities();
});
