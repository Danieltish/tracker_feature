class Visit {
  final int id;
  final int customerId;
  final DateTime visitDate;
  final String status;
  final String? location;
  final String? notes;
  final List<int> activitiesDone;
  final DateTime createdAt;

  Visit({
    required this.id,
    required this.customerId,
    required this.visitDate,
    required this.status,
    this.location,
    this.notes,
    required this.activitiesDone,
    required this.createdAt,
  });

  factory Visit.fromJson(Map<String, dynamic> json) => Visit(
    id: json['id'],
    customerId: json['customer_id'],
    visitDate: DateTime.parse(json['visit_date']),
    status: json['status'],
    location: json['location'],
    notes: json['notes'],
    activitiesDone: (json['activities_done'] as List<dynamic>)
        .map((e) => int.parse(e.toString()))
        .toList(),
    createdAt: DateTime.parse(json['created_at']),
  );
}
