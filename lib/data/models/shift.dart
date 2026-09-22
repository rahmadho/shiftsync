/// A scheduled work shift.
class Shift {
  const Shift({
    required this.id,
    required this.title,
    required this.startAt,
    required this.endAt,
    required this.locationName,
  });

  final String id;
  final String title; // Morning Shift
  final DateTime startAt;
  final DateTime endAt;
  final String locationName; // Headquarters, Floor 2

  factory Shift.fromJson(Map<String, dynamic> json) => Shift(
        id: json['id'] as String,
        title: json['title'] as String,
        startAt: DateTime.parse(json['start_at'] as String),
        endAt: DateTime.parse(json['end_at'] as String),
        locationName: json['location_name'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'start_at': startAt.toIso8601String(),
        'end_at': endAt.toIso8601String(),
        'location_name': locationName,
      };
}
