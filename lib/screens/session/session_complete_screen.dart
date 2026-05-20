// lib/screens/session/session_complete_screen.dart
import 'package:flutter/material.dart';

import '../../models/study_session.dart';
import '../../utils/app_theme.dart';

/// Shown after a session is marked complete.
///
/// Takes the REAL [StudySession] (not a `Map`) plus the actual
/// `oldCourseProgress` / `newCourseProgress` that the daily-session
/// screen computed and persisted, so the "X% → Y%" bar is truthful
/// instead of the hard-coded 40%→55% it used to show.
///
/// The "Up next" section was driven by `mockTodaySessions`, which never
/// belonged to this user — removed. Streak is intentionally not shown
/// here yet; it will be wired up in D3.
class SessionCompleteScreen extends StatelessWidget {
  final StudySession session;
  final int topicsDone;
  final int totalTopics;
  final int timeSpentSeconds;
  final double oldCourseProgress;
  final double newCourseProgress;

  const SessionCompleteScreen({
    super.key,
    required this.session,
    required this.topicsDone,
    required this.totalTopics,
    required this.timeSpentSeconds,
    required this.oldCourseProgress,
    required this.newCourseProgress,
  });

  String get _timeDisplay {
    final m = timeSpentSeconds ~/ 60;
    if (m < 60) return '${m}m';
    final h = m ~/ 60;
    final rem = m % 60;
    return rem == 0 ? '${h}h' : '${h}h ${rem}m';
  }

  @override
  Widget build(BuildContext context) {
    final allDone = totalTopics > 0 && topicsDone == totalTopics;
    final oldPct = (oldCourseProgress * 100).round();
    final newPct = (newCourseProgress * 100).round();

    return PhoneCard(
      child: Column(
        children: [
          // Black celebration header
          Container(
            color: AppColors.black,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Column(
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: totalTopics == 0 ? 1 : topicsDone / totalTopics,
                        strokeWidth: 5,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                      const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Session Complete!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFamily: 'Sora',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${session.courseName} — ${session.topic}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontFamily: 'Sora',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _statCell('TIME', _timeDisplay, true),
                      _statCell('TOPICS', '$topicsDone/$totalTopics', true),
                      _statCell(
                        'PROGRESS',
                        '$newPct%',
                        false,
                        color: AppColors.green,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: AppPadding.screen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),

                  Text(
                    '${session.courseName} PROGRESS'.toUpperCase(),
                    style: AppTextStyles.sectionLabel,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('$oldPct%', style: AppTextStyles.bodySmall),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: newCourseProgress,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.black,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '→ $newPct%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Sora',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            allDone
                                ? 'Great work! All topics covered. Keep the momentum going.'
                                : "Good progress — $topicsDone/$totalTopics topics done. Pick up the rest in your next session.",
                            style: const TextStyle(
                              fontSize: 11,
                              height: 1.5,
                              color: AppColors.mutedText,
                              fontFamily: 'Sora',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  _primaryBtn(
                    'Back to Home',
                    () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (r) => false,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _outlineBtn(
                    'Back to Schedule',
                    () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/schedule',
                      (r) => false,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCell(String label, String value, bool right, {Color? color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: right
              ? const Border(right: BorderSide(color: Colors.white12))
              : null,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color ?? Colors.white,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
                fontFamily: 'Sora',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _primaryBtn(String label, VoidCallback onTap) => SizedBox(
    width: double.infinity,
    height: 44,
    child: ElevatedButton(
      onPressed: onTap,
      style: AppDecorations.primaryButton,
      child: Text(label, style: AppTextStyles.button),
    ),
  );

  Widget _outlineBtn(String label, VoidCallback onTap) => SizedBox(
    width: double.infinity,
    height: 44,
    child: OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
          fontFamily: 'Sora',
        ),
      ),
    ),
  );
}
