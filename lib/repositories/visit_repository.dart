import '../models/visit.dart';
import '../services/api_service.dart';

class VisitRepository {
  Future<List<Visit>> fetchVisits() async {
    final visitsJson = await ApiService.fetch('visits');
    return visitsJson.map<Visit>((e) => Visit.fromJson(e)).toList();
  }
}
