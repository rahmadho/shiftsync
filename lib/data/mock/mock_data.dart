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
  );

  /// History entries (newest first). Grouped by week in the UI.
  static List<Attendance> history() => [
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
