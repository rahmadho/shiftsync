import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/leave_request.dart';
import '../../providers/data_providers.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';

/// S7 — Leave Request (tab "Request").
class LeaveRequestScreen extends ConsumerStatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  ConsumerState<LeaveRequestScreen> createState() =>
      _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends ConsumerState<LeaveRequestScreen> {
  LeaveType _type = LeaveType.sick;
  DateTime? _start;
  DateTime? _end;
  final _reasonCtrl = TextEditingController();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    final v = args.value;
    if (v is PickerDateRange) {
      setState(() {
        _start = v.startDate;
        _end = v.endDate ?? v.startDate;
      });
    } else if (v is DateTime) {
      setState(() {
        _start = v;
        _end = v;
      });
    }
  }

  void _submit() {
    if (_start == null || _end == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date range')),
      );
      return;
    }
    final req = LeaveRequest(
      id: 'l${DateTime.now().millisecondsSinceEpoch}',
      type: _type,
      startDate: _start!,
      endDate: _end!,
      status: LeaveStatus.pending,
      reason: _reasonCtrl.text,
    );
    ref.read(leaveRequestsProvider.notifier).add(req);
    setState(() {
      _start = null;
      _end = null;
      _reasonCtrl.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Leave request submitted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requests = ref.watch(leaveRequestsProvider);
    final duration = (_start != null && _end != null)
        ? AppDateFormatter.inclusiveDays(_start!, _end!)
        : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Leave Request')),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const Text('Leave Type', style: AppTextStyles.label),
            const SizedBox(height: 8),
            DropdownButtonFormField<LeaveType>(
              value: _type,
              decoration: const InputDecoration(),
              items: const [
                DropdownMenuItem(
                    value: LeaveType.sick, child: Text('Sick Leave')),
                DropdownMenuItem(
                    value: LeaveType.annual, child: Text('Annual Leave')),
                DropdownMenuItem(
                    value: LeaveType.personal, child: Text('Personal')),
                DropdownMenuItem(
                    value: LeaveType.unexcused, child: Text('Unexcused')),
              ],
              onChanged: (v) => setState(() => _type = v ?? LeaveType.sick),
            ),
            const SizedBox(height: 16),

            // Duration summary
            Row(
              children: [
                const Text('Duration', style: AppTextStyles.label),
                const Spacer(),
                Text(
                  duration > 0 ? '$duration Days' : 'Select a range',
                  style: AppTextStyles.bodySm
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_start != null && _end != null)
              Row(
                children: [
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('From', style: AppTextStyles.caption),
                          const SizedBox(height: 2),
                          Text(AppDateFormatter.shortDate(_start!),
                              style: AppTextStyles.label),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('To', style: AppTextStyles.caption),
                          const SizedBox(height: 2),
                          Text(AppDateFormatter.shortDate(_end!),
                              style: AppTextStyles.label),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),

            // Date range picker calendar
            AppCard(
              padding: const EdgeInsets.all(8),
              child: SizedBox(
                height: 320,
                child: SfDateRangePicker(
                  selectionMode: DateRangePickerSelectionMode.range,
                  onSelectionChanged: _onSelectionChanged,
                  initialDisplayDate: DateTime(2023, 10, 1),
                  minDate: DateTime(2023, 1, 1),
                  maxDate: DateTime(2024, 12, 31),
                  showNavigationArrow: true,
                  selectionColor: AppColors.primary,
                  startRangeSelectionColor: AppColors.primary,
                  endRangeSelectionColor: AppColors.primary,
                  rangeSelectionColor: AppColors.onTimeBg,
                  todayHighlightColor: AppColors.primary,
                  headerStyle: const DateRangePickerHeaderStyle(
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Reason', style: AppTextStyles.label),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Please describe the reason for your leave...',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submit,
              child: const Text('Submit Request'),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Requests', style: AppTextStyles.h2),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All',
                      style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  for (var i = 0; i < requests.length; i++) ...[
                    _RequestTile(request: requests[i]),
                    if (i != requests.length - 1)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({required this.request});

  final LeaveRequest request;

  BadgeStatus get _badge => switch (request.status) {
        LeaveStatus.pending => BadgeStatus.pending,
        LeaveStatus.approved => BadgeStatus.approved,
        LeaveStatus.rejected => BadgeStatus.rejected,
      };

  @override
  Widget build(BuildContext context) {
    final sameDay = request.startDate == request.endDate;
    final range = sameDay
        ? AppDateFormatter.shortDate(request.startDate)
        : '${AppDateFormatter.shortDate(request.startDate)} - '
            '${AppDateFormatter.shortDate(request.endDate)}';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(request.typeLabel, style: AppTextStyles.label),
      subtitle: Text(range, style: AppTextStyles.caption),
      trailing: StatusBadge(status: _badge),
    );
  }
}
