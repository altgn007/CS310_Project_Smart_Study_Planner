// lib/screens/session_complete_screen.dart
import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../home/home_dashboard.dart';
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
    final minutes = timeSpentSeconds ~/ 60;
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  // Find the next session after the current one
  Map<String, dynamic>? get _nextSession {
    final currentIndex = mockTodaySessions.indexWhere(
      (s) => s['course'] == session['course'] && s['topic'] == session['topic'],
    );
    if (currentIndex != -1 && currentIndex + 1 < mockTodaySessions.length) {
      return mockTodaySessions[currentIndex + 1];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextSession;
    final allDone = topicsDone == totalTopics;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // Black celebration header
          Container(
            width: double.infinity,
            color: const Color(0xFF0D0D0D),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 32,
              left: 28,
              right: 28,
              bottom: 32,
            ),
            child: Column(
              children: [
                // Completion ring
                Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: totalTopics == 0 ? 1 : topicsDone / totalTopics,
                          strokeWidth: 6,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      const Icon(Icons.check_rounded, color: Colors.white, size: 36),
                    ],
                  ),
                ),
                const Text(
                  'Session Complete!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${session['course']} — ${session['topic']}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
                const SizedBox(height: 24),

                // Stats row
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white12, width: 1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _statCell(label: 'TIME', value: _timeDisplay, right: true),
                      _statCell(label: 'TOPICS', value: '$topicsDone/$totalTopics', right: true),
                      _statCell(
                        label: 'STREAK',
                        value: '${mockStreak + 1}🔥',
                        color: const Color(0xFF5BE878),
                        right: false,
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Progress update
                  _sectionTitle('${session['course']} Progress'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('40%', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: const LinearProgressIndicator(
                            value: 0.55,
                            backgroundColor: Color(0xFFE0E0E0),
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D0D0D)),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '→ 55%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0D0D0D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Coach note
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D0D0D),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.person_outline, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Coach',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0D0D0D),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                allDone
                                    ? 'Great work! All topics covered. Your ${session['course']} exam prep is on track.'
                                    : "Good progress. You covered $topicsDone of $totalTopics topics. The remaining ones have been added to tomorrow's plan.",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Up next
                  if (next != null) ...[
                    _sectionTitle('Up Next'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  next['course'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0D0D0D),
                                  ),
                                ),
                                Text(
                                  '${next['time']} · ${next['duration']}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DailySessionScreen(session: next),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D0D0D),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: const Text(
                                '▶ Start',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Action buttons
                  if (next != null)
                    _primaryBtn(
                      label: 'Start Next Session',
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DailySessionScreen(session: next),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  _outlineBtn(
                    label: 'Back to Home',
                    onTap: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeDashboard()),
                      (route) => false,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Partial completion link
                  if (!allDone)
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Navigate to AdaptiveRescheduleScreen
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const HomeDashboard()),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          "I didn't finish everything →",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF666666),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCell({
    required String label,
    required String value,
    required bool right,
    Color? color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: right ? const Border(right: BorderSide(color: Colors.white12)) : null,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color ?? Colors.white,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.08 * 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.08 * 11,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _primaryBtn({required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D0D0D),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _outlineBtn({required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF0D0D0D),
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }
}