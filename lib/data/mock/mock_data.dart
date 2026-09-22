import '../models/attendance.dart';
import '../models/flag.dart';
import '../models/leave_request.dart';
import '../models/shift.dart';
import '../models/user.dart';

/// Mock data mirroring the design PDF. Swap for a real repository later.
abstract final class MockData {
  MockData._();

  /// Home greeting name (design: "Hello, Alex K").
  static const String homeUserName = 'Alex K';

  static const User user = User(
    id: 'u1',
    name: 'Sarah Jenkins',
    employeeCode: '#EMP-2024-89',
    department: 'Marketing',
    email: 'sarah.jenkins@shiftsync.com',
    shiftLabel: 'Mon-Fri Shift',
  );

  static Shift get upcoming => Shift(
        id: 's1',
        title: 'Morning Shift',
        startAt: DateTime(2023, 10, 24, 8, 0),
        endAt: DateTime(2023, 10, 24, 16, 0),
        locationName: 'Headquarters, Floor 2',
      );

  /// Attendance summary — October 2023.
  static const AttendanceSummary summaryOctober = AttendanceSummary(
    present: 20,
    late: 2,
    absent: 0,
    totalHours: 160,
    overtimeHours: 4,
    ratio: 0.95,
    lateHours: 1.5,
    earlyLeaveHours: 2.0,
  );

  /// Monthly summaries keyed by "yyyy-MM". Falls back to none if missing.
  static const Map<String, AttendanceSummary> summariesByMonth = {
    '2023-10': summaryOctober,
    '2023-09': AttendanceSummary(
      present: 18,
      late: 3,
      absent: 1,
      totalHours: 152,
      overtimeHours: 2,
      ratio: 0.82,
      lateHours: 3.0,
      earlyLeaveHours: 4.5,
    ),
    '2023-08': AttendanceSummary(
      present: 21,
      late: 1,
      absent: 0,
      totalHours: 168,
      overtimeHours: 6,
      ratio: 0.96,
      lateHours: 0.5,
      earlyLeaveHours: 1.0,
    ),
  };

  /// Look up a summary for a given month, defaulting to an empty one.
  static AttendanceSummary summaryFor(DateTime month) {
    final key =
        '${month.year}-${month.month.toString().padLeft(2, '0')}';
    return summariesByMonth[key] ??
        const AttendanceSummary(
          present: 0,
          late: 0,
          absent: 0,
          totalHours: 0,
          overtimeHours: 0,
          ratio: 0,
        );
  }

  /// History entries (newest first). Grouped by week in the UI.
  static List<Attendance> history() => [
        // ---------- OCTOBER 2023 ----------
        // WEEK OF OCT 23 - 29
        Attendance(
          id: 'a24',
          date: DateTime(2023, 10, 24),
          status: AttendanceStatus.onTime,
          checkInAt: DateTime(2023, 10, 24, 8, 55),
          checkOutAt: DateTime(2023, 10, 24, 17, 5),
        ),
        Attendance(
          id: 'a25',
          date: DateTime(2023, 10, 25),
          status: AttendanceStatus.late,
          checkInAt: DateTime(2023, 10, 25, 9, 15),
          checkOutAt: DateTime(2023, 10, 25, 17, 0),
        ),
        Attendance(
          id: 'a26',
          date: DateTime(2023, 10, 26),
          status: AttendanceStatus.onTime,
          checkInAt: DateTime(2023, 10, 26, 8, 50),
          checkOutAt: DateTime(2023, 10, 26, 17, 10),
        ),
        // WEEK OF OCT 16 - 22
        Attendance(
          id: 'a20',
          date: DateTime(2023, 10, 20),
          status: AttendanceStatus.absent,
        ),
        Attendance(
          id: 'a19',
          date: DateTime(2023, 10, 19),
          status: AttendanceStatus.onTime,
          checkInAt: DateTime(2023, 10, 19, 8, 45),
          checkOutAt: DateTime(2023, 10, 19, 17, 15),
        ),
        // WEEK OF OCT 2 - 8
        Attendance(
          id: 'a3',
          date: DateTime(2023, 10, 3),
          status: AttendanceStatus.late,
          checkInAt: DateTime(2023, 10, 3, 9, 30),
          checkOutAt: DateTime(2023, 10, 3, 17, 0),
        ),

        // ---------- SEPTEMBER 2023 ----------
        Attendance(
          id: 's28',
          date: DateTime(2023, 9, 28),
          status: AttendanceStatus.absent,
        ),
        Attendance(
          id: 's27',
          date: DateTime(2023, 9, 27),
          status: AttendanceStatus.onTime,
          checkInAt: DateTime(2023, 9, 27, 8, 50),
          checkOutAt: DateTime(2023, 9, 27, 17, 5),
        ),
        Attendance(
          id: 's26',
          date: DateTime(2023, 9, 26),
          status: AttendanceStatus.onTime,
          checkInAt: DateTime(2023, 9, 26, 8, 55),
          checkOutAt: DateTime(2023, 9, 26, 17, 0),
        ),

        // ---------- AUGUST 2023 ----------
        Attendance(
          id: 'g01',
          date: DateTime(2023, 8, 1),
          status: AttendanceStatus.onTime,
          checkInAt: DateTime(2023, 8, 1, 8, 58),
          checkOutAt: DateTime(2023, 8, 1, 17, 2),
        ),
        Attendance(
          id: 'g02',
          date: DateTime(2023, 8, 2),
          status: AttendanceStatus.late,
          checkInAt: DateTime(2023, 8, 2, 9, 20),
          checkOutAt: DateTime(2023, 8, 2, 16, 30),
        ),
      ];

  static List<Flag> flags() => [
        Flag(
          id: 'f1',
          title: 'Late Arrival',
          description: 'Logged in at 09:15 AM',
          occurredAt: DateTime(2023, 10, 12),
          deltaLabel: '15m',
        ),
        Flag(
          id: 'f2',
          title: 'Sick Leave',
          description: 'Approved by HR',
          occurredAt: DateTime(2023, 10, 3),
          deltaLabel: '1d',
        ),
        Flag(
          id: 'f3',
          title: 'Unexcused Absence',
          description: 'No check-in record',
          occurredAt: DateTime(2023, 9, 28),
          deltaLabel: '1d',
        ),
      ];

  static List<LeaveRequest> leaveRequests() => [
        LeaveRequest(
          id: 'l1',
          type: LeaveType.sick,
          startDate: DateTime(2023, 10, 24),
          endDate: DateTime(2023, 10, 25),
          status: LeaveStatus.pending,
        ),
        LeaveRequest(
          id: 'l2',
          type: LeaveType.annual,
          startDate: DateTime(2023, 9, 10),
          endDate: DateTime(2023, 9, 15),
          status: LeaveStatus.approved,
        ),
        LeaveRequest(
          id: 'l3',
          type: LeaveType.personal,
          startDate: DateTime(2023, 8, 1),
          endDate: DateTime(2023, 8, 1),
          status: LeaveStatus.rejected,
        ),
      ];
}
