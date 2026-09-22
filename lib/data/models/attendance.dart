/// Attendance status for a work day.
enum AttendanceStatus { onTime, late, absent }

/// A recorded attendance entry (check-in / check-out).
class Attendance {
  const Attendance({
    required this.id,
    required this.date,
    required this.status,
    this.checkInAt,
    this.checkOutAt,
  });

  final String id;
  final DateTime date;
  final AttendanceStatus status;
  final DateTime? checkInAt;
  final DateTime? checkOutAt;

  factory Attendance.fromJson(Map<String, dynamic> json) => Attendance(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        status: AttendanceStatus.values.byName(json['status'] as String),
        checkInAt: json['check_in_at'] == null
            ? null
            : DateTime.parse(json['check_in_at'] as String),
        checkOutAt: json['check_out_at'] == null
            ? null
            : DateTime.parse(json['check_out_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'status': status.name,
        'check_in_at': checkInAt?.toIso8601String(),
        'check_out_at': checkOutAt?.toIso8601String(),
      };
}

/// Monthly attendance aggregate (My Statistics / History summary).
class AttendanceSummary {
  const AttendanceSummary({
    required this.present,
    required this.late,
    required this.absent,
    required this.totalHours,
    required this.overtimeHours,
    required this.ratio,
    this.lateHours = 0,
    this.earlyLeaveHours = 0,
  });

  final int present;
  final int late;
  final int absent;
  final int totalHours;
  final int overtimeHours;
  final double ratio;
  /// Total hours late (sum of lateness durations), not day count.
  final double lateHours;
  /// Total hours of early leave (pulang cepat).
  final double earlyLeaveHours;

  int get totalDays => present + late + absent;

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) =>
      AttendanceSummary(
        present: json['present'] as int,
        late: json['late'] as int,
        absent: json['absent'] as int,
        totalHours: json['total_hours'] as int,
        overtimeHours: json['overtime'] as int,
        ratio: (json['ratio'] as num).toDouble(),
        lateHours: (json['late_hours'] as num?)?.toDouble() ?? 0,
        earlyLeaveHours: (json['early_leave_hours'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'present': present,
        'late': late,
        'absent': absent,
        'total_hours': totalHours,
        'overtime': overtimeHours,
        'ratio': ratio,
        'late_hours': lateHours,
        'early_leave_hours': earlyLeaveHours,
      };
}
