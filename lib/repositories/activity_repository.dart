import '../models/activity.dart';
import '../services/api_service.dart';

class ActivityRepository {
  Future<List<Activity>> fetchActivities() async {
    final activitiesJson = await ApiService.fetch('activities');
    return activitiesJson.map<Activity>((e) => Activity.fromJson(e)).toList();
  }
}
