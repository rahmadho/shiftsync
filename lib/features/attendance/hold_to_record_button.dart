import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Press-and-hold button: fires [onComplete] after being held for [duration].
class HoldToRecordButton extends StatefulWidget {
  const HoldToRecordButton({
    super.key,
    required this.onComplete,
    this.duration = const Duration(milliseconds: 1500),
    this.label,
    this.recordedLabel,
    this.enabled = true,
    this.onDisabledTap,
  });

  final VoidCallback onComplete;
  final Duration duration;
  final String? label;
  final String? recordedLabel;
  final bool enabled;
  final VoidCallback? onDisabledTap;

  @override
  State<HoldToRecordButton> createState() => _HoldToRecordButtonState();
}

class _HoldToRecordButtonState extends State<HoldToRecordButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  bool _fired = false;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_fired) {
        _fired = true;
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _start() {
    if (!widget.enabled) {
      widget.onDisabledTap?.call();
      return;
    }
    if (_fired) return;
    _controller.forward(from: 0);
  }

  void _cancel() {
    if (!widget.enabled) return;
    if (_fired) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final defaultLabel = widget.label ?? 'Hold to record';
    final doneLabel = widget.recordedLabel ?? 'Recorded';
    final buttonColor = widget.enabled ? AppColors.primary : AppColors.border;
    final iconColor = widget.enabled ? Colors.white : AppColors.textMuted;
    final textColor = widget.enabled ? Colors.white : AppColors.textMuted;

    return GestureDetector(
      onTapDown: (_) => _start(),
      onTapUp: (_) => _cancel(),
      onTapCancel: _cancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 10,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(
                        AppColors.border.withValues(alpha: .5)),
                  ),
                ),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: _controller.value,
                    strokeWidth: 10,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Colors.transparent,
                    valueColor:
                        AlwaysStoppedAnimation(buttonColor),
                  ),
                ),
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: buttonColor,
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fingerprint,
                          color: iconColor, size: 40),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          _fired ? doneLabel : defaultLabel,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
