import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock/mock_data.dart';
import '../data/models/attendance.dart';
import '../data/models/flag.dart';
import '../data/models/leave_request.dart';
import '../data/models/shift.dart';
import '../data/models/user.dart';

final currentUserProvider = Provider<User>((ref) => MockData.user);

final attendanceSummaryProvider =
    Provider<AttendanceSummary>((ref) => MockData.summaryOctober);

final attendanceHistoryProvider =
    Provider<List<Attendance>>((ref) => MockData.history());

final upcomingShiftProvider = Provider<Shift>((ref) => MockData.upcoming);

final flagsProvider = Provider<List<Flag>>((ref) => MockData.flags());

final leaveRequestsProvider =
    StateNotifierProvider<LeaveRequestsNotifier, List<LeaveRequest>>(
  (ref) => LeaveRequestsNotifier(),
);

class LeaveRequestsNotifier extends StateNotifier<List<LeaveRequest>> {
  LeaveRequestsNotifier() : super(MockData.leaveRequests());

  void add(LeaveRequest request) => state = [request, ...state];
}
