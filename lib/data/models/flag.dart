/// A recent flag shown on the Statistics screen.
class Flag {
  const Flag({
    required this.id,
    required this.title,
    required this.description,
    required this.occurredAt,
    required this.deltaLabel, // "15m", "1d"
  });

  final String id;
  final String title; // Late Arrival
  final String description; // Logged in at 09:15 AM
  final DateTime occurredAt;
  final String deltaLabel;

  factory Flag.fromJson(Map<String, dynamic> json) => Flag(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        occurredAt: DateTime.parse(json['occurred_at'] as String),
        deltaLabel: json['delta_label'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'occurred_at': occurredAt.toIso8601String(),
        'delta_label': deltaLabel,
      };
}
