// lib/screens/session/session_complete_screen.dart
import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../utils/app_theme.dart';
import 'daily_session_screen.dart';

class SessionCompleteScreen extends StatelessWidget {
  final Map<String, dynamic> session;
  final int topicsDone;
  final int totalTopics;
  final int timeSpentSeconds;

  const SessionCompleteScreen({
    super.key,
    required this.session,
    required this.topicsDone,
    required this.totalTopics,
    required this.timeSpentSeconds,
  });

  String get _timeDisplay {
    final m = timeSpentSeconds ~/ 60;
    if (m < 60) return '${m}m';
    final h = m ~/ 60;
    final rem = m % 60;
    return rem == 0 ? '${h}h' : '${h}h ${rem}m';
  }

  Map<String, dynamic>? get _nextSession {
    final idx = mockTodaySessions.indexWhere(
      (s) => s['course'] == session['course'] && s['topic'] == session['topic'],
    );
    if (idx != -1 && idx + 1 < mockTodaySessions.length) return mockTodaySessions[idx + 1];
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextSession;
    final allDone = topicsDone == totalTopics;

    return PhoneCard(
      child: Column(
        children: [
          // Black celebration header
          Container(
            color: AppColors.black,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Column(
              children: [
                // Completion ring
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
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeCap: StrokeCap.round,
                      ),
                      const Icon(Icons.check_rounded, color: Colors.white, size: 28),
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
                  '${session['course']} — ${session['topic']}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Colors.grey[500], fontFamily: 'Sora'),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                // Stats row
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _statCell('TIME', _timeDisplay, true),
                      _statCell('TOPICS', '$topicsDone/$totalTopics', true),
                      _statCell('STREAK', '${mockStreak + 1}🔥', false, color: AppColors.green),
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

                  // Progress update
                  Text('${session['course']} PROGRESS'.toUpperCase(), style: AppTextStyles.sectionLabel),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('40%', style: AppTextStyles.bodySmall),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: const LinearProgressIndicator(
                            value: 0.55,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.black),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '→ 55%',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Sora'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Coach note
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
                          child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 14),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            allDone
                                ? 'Great work! All topics covered. Keep the momentum going.'
                                : "Good progress — $topicsDone/$totalTopics topics done. Remaining topics moved to tomorrow.",
                            style: const TextStyle(fontSize: 11, height: 1.5, color: AppColors.mutedText, fontFamily: 'Sora'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Up next
                  if (next != null) ...[
                    Text('UP NEXT', style: AppTextStyles.sectionLabel),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  next['course'],
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Sora'),
                                ),
                                Text(
                                  '${next['time']} · ${next['duration']}',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => DailySessionScreen(session: next)),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.black,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: const Text(
                                '▶ Start',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: 'Sora'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Buttons
                  if (next != null)
                    _primaryBtn('Start Next Session', () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => DailySessionScreen(session: next)),
                    )),
                  const SizedBox(height: 8),
                  _outlineBtn('Back to Home', () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false)),

                  if (!allDone) ...[
                    const SizedBox(height: 10),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),
                        child: const Text(
                          "I didn't finish everything →",
                          style: TextStyle(fontSize: 11, color: AppColors.mutedText, decoration: TextDecoration.underline, fontFamily: 'Sora'),
                        ),
                      ),
                    ),
                  ],
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
          border: right ? const Border(right: BorderSide(color: Colors.white12)) : null,
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
              style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: Colors.grey[500], fontFamily: 'Sora'),
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
      child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.black, fontFamily: 'Sora')),
    ),
  );
}