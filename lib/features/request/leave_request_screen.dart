import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/localization/app_strings.dart';
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
  String? _attachmentName;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.isNotEmpty) {
        if (!mounted) return;
        setState(() => _attachmentName = result.files.single.name);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.tr('filePickFailed'))),
      );
    }
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
        SnackBar(content: Text(ref.tr('selectDateRangePrompt'))),
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
      _attachmentName = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ref.tr('requestSubmitted'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requests = ref.watch(leaveRequestsProvider);
    final lang = ref.watch(localeProvider);
    final duration = (_start != null && _end != null)
        ? AppDateFormatter.inclusiveDays(_start!, _end!)
        : 0;

    return Scaffold(
      appBar: AppBar(title: Text(ref.tr('leaveRequest'))),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSizes.screenPadding, 8, AppSizes.screenPadding, 24),
          children: [
            Text(ref.tr('leaveType'), style: AppTextStyles.label),
            const SizedBox(height: 8),
            DropdownButtonFormField<LeaveType>(
              value: _type,
              decoration: const InputDecoration(),
              items: [
                DropdownMenuItem(
                    value: LeaveType.sick, child: Text(ref.tr('sickLeave'))),
                DropdownMenuItem(
                    value: LeaveType.annual, child: Text(ref.tr('annualLeave'))),
                DropdownMenuItem(
                    value: LeaveType.personal, child: Text(ref.tr('personalLeave'))),
                DropdownMenuItem(
                    value: LeaveType.unexcused, child: Text(ref.tr('unexcusedLeave'))),
              ],
              onChanged: (v) => setState(() => _type = v ?? LeaveType.sick),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Text(ref.tr('duration'), style: AppTextStyles.label),
                const Spacer(),
                Text(
                  duration > 0 ? '$duration ${ref.tr('days')}' : ref.tr('selectRange'),
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
                          Text(ref.tr('from'), style: AppTextStyles.caption),
                          const SizedBox(height: 2),
                          Text(AppDateFormatter.shortDate(_start!, lang),
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
                          Text(ref.tr('to'), style: AppTextStyles.caption),
                          const SizedBox(height: 2),
                          Text(AppDateFormatter.shortDate(_end!, lang),
                              style: AppTextStyles.label),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),

            AppCard(
              color: Colors.white,
              padding: const EdgeInsets.all(8),
              child: SizedBox(
                height: 320,
                child: SfDateRangePicker(
                  backgroundColor: Colors.white,
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
                    backgroundColor: Colors.white,
                    textStyle: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  monthCellStyle: const DateRangePickerMonthCellStyle(
                    textStyle: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      color: AppColors.textPrimary,
                    ),
                    todayTextStyle: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(ref.tr('attachment'), style: AppTextStyles.label),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.attach_file,
                      size: 20, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _attachmentName ?? ref.tr('attachmentHint'),
                      style: AppTextStyles.bodySm.copyWith(
                        color: _attachmentName != null
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _pickAttachment,
                    child: Text(
                      _attachmentName != null ? ref.tr('changeFile') : ref.tr('chooseFile'),
                      style: const TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text(ref.tr('reason'), style: AppTextStyles.label),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: ref.tr('reasonHint'),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submit,
              child: Text(ref.tr('submitRequest')),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(ref.tr('recentRequests'), style: AppTextStyles.h2),
                TextButton(
                  onPressed: () {},
                  child: Text(ref.tr('viewAll'),
                      style: const TextStyle(color: AppColors.primary)),
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

class _RequestTile extends ConsumerWidget {
  const _RequestTile({required this.request});

  final LeaveRequest request;

  BadgeStatus get _badge => switch (request.status) {
        LeaveStatus.pending => BadgeStatus.pending,
        LeaveStatus.approved => BadgeStatus.approved,
        LeaveStatus.rejected => BadgeStatus.rejected,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider);
    final sameDay = request.startDate == request.endDate;
    final range = sameDay
        ? AppDateFormatter.shortDate(request.startDate, lang)
        : '${AppDateFormatter.shortDate(request.startDate, lang)} - '
            '${AppDateFormatter.shortDate(request.endDate, lang)}';

    final label = switch (request.type) {
      LeaveType.sick => ref.tr('sickLeave'),
      LeaveType.annual => ref.tr('annualLeave'),
      LeaveType.personal => ref.tr('personalLeave'),
      LeaveType.unexcused => ref.tr('unexcusedLeave'),
    };

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(label, style: AppTextStyles.label),
      subtitle: Text(range, style: AppTextStyles.caption),
      trailing: StatusBadge(status: _badge),
    );
  }
}
