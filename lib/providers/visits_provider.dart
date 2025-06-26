import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/visit.dart';
import '../repositories/visit_repository.dart';

final visitRepositoryProvider = Provider<VisitRepository>(
  (ref) => VisitRepository(),
);

final visitsProvider = FutureProvider<List<Visit>>((ref) async {
  final repo = ref.watch(visitRepositoryProvider);
  return repo.fetchVisits();
});
