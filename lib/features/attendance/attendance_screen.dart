import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/location_utils.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/data_providers.dart';
import '../../widgets/app_card.dart';
import 'hold_to_record_button.dart';

enum AttendanceMode { office, remote }

/// S4 — Attendance (active check-in with Office & Remote modes).
class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  AttendanceMode _mode = AttendanceMode.office;
  bool _simulateInside = true;
  final _picker = ImagePicker();
  Uint8List? _selfieBytes;
  final _notesCtrl = TextEditingController();

  static const _insideLat = -0.9373786051614612 + 0.00027; // ~30 m
  static const _insideLng = 100.36028655141162;
  static const _outsideLat = -0.9373786051614612 + 0.00225; // ~250 m
  static const _outsideLng = 100.36028655141162;

  double get _curLat => _simulateInside ? _insideLat : _outsideLat;
  double get _curLng => _simulateInside ? _insideLng : _outsideLng;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _takeSelfie() async {
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        if (!mounted) return;
        setState(() => _selfieBytes = bytes);
      }
    } catch (_) {
      // Fallback for environment without native camera (e.g. web/gallery)
      try {
        final photo = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 800,
          maxHeight: 800,
        );
        if (photo != null) {
          final bytes = await photo.readAsBytes();
          if (!mounted) return;
          setState(() => _selfieBytes = bytes);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _onRecorded() {
    final now = DateTime.now();
    final notifier = ref.read(todayAttendanceProvider.notifier);
    final today = ref.read(todayAttendanceProvider);

    // Office mode validation
    if (_mode == AttendanceMode.office) {
      final geo = LocationUtils.check(_curLat, _curLng);
      if (!geo.isInside) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.absentFg,
            content: Text(
              '${ref.tr('geoFailMsg')} (${LocationUtils.formatDistance(geo.distanceMeters)}, '
              'max ${LocationUtils.radiusMeters.round()} m).',
            ),
          ),
        );
        return;
      }
    } else {
      // Remote mode validation: must have selfie
      if (_selfieBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.absentFg,
            content: Text(ref.tr('selfieRequiredMsg')),
          ),
        );
        return;
      }
    }

    if (!today.hasCheckedIn) {
      notifier.checkIn(now);
    } else if (!today.hasCheckedOut) {
      notifier.checkOut(now);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.approvedFg,
        content: Text(
          _mode == AttendanceMode.office
              ? '${ref.tr('geoSuccessMsg')} (${LocationUtils.formatDistance(LocationUtils.check(_curLat, _curLng).distanceMeters)}).'
              : ref.tr('remoteSuccessMsg'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shift = ref.watch(upcomingShiftProvider);
    final today = ref.watch(todayAttendanceProvider);
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final geo = LocationUtils.check(_curLat, _curLng);
    final lang = ref.watch(localeProvider);

    final isRemote = _mode == AttendanceMode.remote;
    final canRecord = !isRemote || _selfieBytes != null;

    final holdLabel = today.hasCheckedOut
        ? ref.tr('attendanceDoneToday')
        : today.hasCheckedIn
            ? ref.tr('holdToCheckOut')
            : ref.tr('holdToCheckIn');

    return Scaffold(
      appBar: AppBar(
        title: Text(ref.tr('attendance')),
        actions: [
          if (!isRemote)
            Row(
              children: [
                Text(_simulateInside ? 'In' : 'Out',
                    style: AppTextStyles.caption),
                Switch(
                  value: _simulateInside,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _simulateInside = v),
                ),
              ],
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.screenPadding),
          child: Column(
            children: [
              // Segmented Control: In Office vs Outside Office
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<AttendanceMode>(
                  segments: [
                    ButtonSegment(
                      value: AttendanceMode.office,
                      label: Text(ref.tr('modeOffice')),
                      icon: const Icon(Icons.business, size: 18),
                    ),
                    ButtonSegment(
                      value: AttendanceMode.remote,
                      label: Text(ref.tr('modeRemote')),
                      icon: const Icon(Icons.pin_drop_outlined, size: 18),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (s) => setState(() {
                    _mode = s.first;
                  }),
                  style: ButtonStyle(
                    visualDensity: VisualDensity.comfortable,
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusButton),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Icon(isRemote ? Icons.home_work_outlined : Icons.location_on,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    isRemote ? 'Remote / Field Location' : 'Headquarters',
                    style: AppTextStyles.bodySm,
                  ),
                  const Spacer(),
                  Text(AppDateFormatter.dayMonth(now, lang),
                      style: AppTextStyles.bodySm),
                ],
              ),
              const SizedBox(height: 16),

              Text(AppDateFormatter.hhmmAmPm(now),
                  style: AppTextStyles.display.copyWith(fontSize: 44)),
              const SizedBox(height: 6),
              Text(
                isRemote
                    ? 'Outside Office (Selfie required)'
                    : 'Headquarters - Bldg A',
                style: AppTextStyles.bodySm,
              ),
              const SizedBox(height: 8),

              // Status indicator depending on mode
              if (!isRemote)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: geo.isInside
                        ? AppColors.approvedBg
                        : AppColors.absentBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        geo.isInside
                            ? Icons.check_circle
                            : Icons.error_outline,
                        size: 14,
                        color: geo.isInside
                            ? AppColors.approvedFg
                            : AppColors.absentFg,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        geo.isInside
                            ? ref.tr('withinGeofence')
                            : ref.tr('outsideGeofence'),
                        style: AppTextStyles.caption.copyWith(
                          color: geo.isInside
                              ? AppColors.approvedFg
                              : AppColors.absentFg,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${LocationUtils.formatDistance(geo.distanceMeters)} '
                        '/ ${LocationUtils.radiusMeters.round()} m',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.lateBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.camera_alt_outlined,
                          size: 16, color: AppColors.lateFg),
                      const SizedBox(width: 6),
                      Text(
                        ref.tr('remoteModeActive'),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.lateFg,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // Remote Mode: Selfie Preview Box & Notes
              if (isRemote) ...[
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_selfieBytes != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.memory(
                                _selfieBytes!,
                                width: 88,
                                height: 88,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: AppColors.border,
                                    style: BorderStyle.solid),
                              ),
                              child: const Icon(
                                Icons.face_retouching_natural,
                                size: 40,
                                color: AppColors.textMuted,
                              ),
                            ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selfieBytes != null
                                      ? 'Selfie captured'
                                      : 'Selfie Photo *',
                                  style: AppTextStyles.label,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selfieBytes != null
                                      ? 'Ready to record attendance'
                                      : ref.tr('selfieRequiredMsg'),
                                  style: AppTextStyles.caption,
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: _takeSelfie,
                                  icon: const Icon(Icons.camera_alt, size: 16),
                                  label: Text(
                                    _selfieBytes != null
                                        ? ref.tr('retakeSelfie')
                                        : ref.tr('takeSelfie'),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _notesCtrl,
                        decoration: InputDecoration(
                          hintText: ref.tr('notesOptional'),
                          prefixIcon:
                              const Icon(Icons.edit_note, size: 20),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              HoldToRecordButton(
                onComplete: _onRecorded,
                enabled: canRecord,
                label: ref.tr('holdToRecord'),
                recordedLabel: ref.tr('recorded'),
                onDisabledTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.absentFg,
                      content: Text(ref.tr('selfieRequiredMsg')),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Text(
                holdLabel,
                style: AppTextStyles.bodySm,
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _TimeCard(
                      label: ref.tr('labelCheckIn'),
                      icon: Icons.login,
                      time: today.checkInAt,
                      color: AppColors.primary,
                      emptyLabel: ref.tr('notCheckedInYet'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimeCard(
                      label: ref.tr('labelCheckOut'),
                      icon: Icons.logout,
                      time: today.checkOutAt,
                      color: AppColors.lateFg,
                      emptyLabel: ref.tr('notCheckedInYet'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              AppCard(
                child: Row(
                  children: [
                    const Icon(Icons.schedule, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ref.tr('shift'),
                              style: AppTextStyles.caption
                                  .copyWith(letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text(
                            '${AppDateFormatter.hhmm(shift.startAt)} - '
                            '${AppDateFormatter.hhmm(shift.endAt)}  ·  '
                            '${ref.tr('standardShift')}',
                            style: AppTextStyles.label,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({
    required this.label,
    required this.icon,
    required this.time,
    required this.color,
    required this.emptyLabel,
  });

  final String label;
  final IconData icon;
  final DateTime? time;
  final Color color;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(label,
                  style: AppTextStyles.caption.copyWith(letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            time != null ? AppDateFormatter.hhmm(time!) : '-- : --',
            style: AppTextStyles.h1.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 2),
          Text(time != null ? AppDateFormatter.hhmmAmPm(time!) : emptyLabel,
              style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
