/// Leave request type.
enum LeaveType { sick, annual, personal, unexcused }

/// Leave request review status.
enum LeaveStatus { pending, approved, rejected }

/// A leave / absence request submitted by the user.
class LeaveRequest {
  const LeaveRequest({
    required this.id,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.reason,
  });

  final String id;
  final LeaveType type;
  final DateTime startDate;
  final DateTime endDate;
  final LeaveStatus status;
  final String? reason;

  int get durationDays => endDate.difference(startDate).inDays + 1;

  String get typeLabel => switch (type) {
        LeaveType.sick => 'Sick Leave',
        LeaveType.annual => 'Annual Leave',
        LeaveType.personal => 'Personal',
        LeaveType.unexcused => 'Unexcused',
      };

  factory LeaveRequest.fromJson(Map<String, dynamic> json) => LeaveRequest(
        id: json['id'] as String,
        type: LeaveType.values.byName(json['type'] as String),
        startDate: DateTime.parse(json['start_date'] as String),
        endDate: DateTime.parse(json['end_date'] as String),
        status: LeaveStatus.values.byName(json['status'] as String),
        reason: json['reason'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'status': status.name,
        'reason': reason,
      };
}
