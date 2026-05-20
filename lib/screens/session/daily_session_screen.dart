// lib/screens/session/daily_session_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/course.dart';
import '../../models/study_session.dart';
import '../../providers/course_provider.dart';
import '../../providers/session_provider.dart';
import '../../utils/app_theme.dart';
import 'session_complete_screen.dart';

/// 25-minute Pomodoro focus screen for one [StudySession].
///
/// Changes vs the old version:
///   - takes a real `StudySession` (not a `Map<String, dynamic>`)
///   - "Mark Session Complete" actually persists via
///     `SessionProvider.markComplete` → Firestore transaction that
///     flips `session.done = true` and bumps the parent course's
///     progress to (completedSessions / courseTopicsCount).
class DailySessionScreen extends StatefulWidget {
  static const String routeName = '/session';
  final StudySession session;
  const DailySessionScreen({super.key, required this.session});

  @override
  State<DailySessionScreen> createState() => _DailySessionScreenState();
}

class _DailySessionScreenState extends State<DailySessionScreen> {
  static const int _pomodoroSeconds = 25 * 60;
  int _secondsLeft = _pomodoroSeconds;
  bool _isRunning = false;
  Timer? _timer;
  bool _completing = false;

  /// Local checkbox state for the session's topics. A topic flipped here
  /// is not persisted on its own — it just feeds the visual progress bar
  /// and the "TOPICS x/y" counter on the complete screen.
  late List<SessionTopic> _topics;

  @override
  void initState() {
    super.initState();
    _topics = List<SessionTopic>.from(widget.session.topics);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_secondsLeft > 0) {
          setState(() => _secondsLeft--);
        } else {
          _timer?.cancel();
          setState(() => _isRunning = false);
        }
      });
      setState(() => _isRunning = true);
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _secondsLeft = _pomodoroSeconds;
      _isRunning = false;
    });
  }

  String get _timerDisplay {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  int get _doneTopics => _topics.where((t) => t.done).length;

  /// Compute the parent course's NEW progress as:
  ///   (sessions already done + this one) / total course topics
  /// Falls back to a sensible value if the course/topic counts are
  /// missing.
  double _computeNewCourseProgress({
    required Course? course,
    required List<StudySession> allSessions,
  }) {
    if (course == null) {
      // No course context — bump the session's stored progress a bit.
      return ((widget.session.done ? 1.0 : 0.0)).clamp(0.0, 1.0);
    }
    // How many of THIS course's sessions are already done?
    final doneForCourse = allSessions
        .where(
          (s) => s.courseId == course.id && s.done && s.id != widget.session.id,
        )
        .length;
    // Plus the one we're completing right now.
    final doneAfter = doneForCourse + 1;
    final total = course.topics.isEmpty ? 1 : course.topics.length;
    final p = doneAfter / total;
    return p.clamp(0.0, 1.0);
  }

  Future<void> _markComplete() async {
    if (_completing) return;
    setState(() => _completing = true);
    _timer?.cancel();

    final sessionProvider = context.read<SessionProvider>();
    final courseProvider = context.read<CourseProvider>();

    // Find the parent course in the cached list (so we know its topic count).
    Course? course;
    for (final c in courseProvider.courses) {
      if (c.id == widget.session.courseId) {
        course = c;
        break;
      }
    }

    // Pull a snapshot of all sessions for accurate counting.
    final allSessions = sessionProvider.todaySessions;
    final newCourseProgress = _computeNewCourseProgress(
      course: course,
      allSessions: allSessions,
    );

    final oldProgress = course?.progress ?? 0.0;

    try {
      await sessionProvider.markComplete(
        sessionId: widget.session.id,
        courseId: widget.session.courseId,
        newCourseProgress: newCourseProgress,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _completing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save: $e')));
      return;
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SessionCompleteScreen(
          session: widget.session,
          topicsDone: _doneTopics,
          totalTopics: _topics.length,
          timeSpentSeconds: _pomodoroSeconds - _secondsLeft,
          oldCourseProgress: oldProgress,
          newCourseProgress: newCourseProgress,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _topics.isEmpty ? 0.0 : _doneTopics / _topics.length;
    final s = widget.session;

    return PhoneCard(
      child: Column(
        children: [
          const AppStatusBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: AppPadding.screen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      size: 20,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Timer block
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'FOCUS SESSION',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: Colors.grey[500],
                            fontFamily: 'Sora',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _timerDisplay,
                          style: const TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                            letterSpacing: -2,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${s.courseName} — ${s.topic}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                            fontFamily: 'Sora',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _timerBtn(
                              Icons.stop_rounded,
                              Colors.white24,
                              Colors.white60,
                              _resetTimer,
                            ),
                            const SizedBox(width: 10),
                            _timerBtn(
                              _isRunning
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              Colors.white,
                              AppColors.black,
                              _toggleTimer,
                              large: true,
                            ),
                            const SizedBox(width: 10),
                            _timerBtn(
                              Icons.refresh_rounded,
                              Colors.white24,
                              Colors.white60,
                              _resetTimer,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text('SESSION TOPICS', style: AppTextStyles.sectionLabel),
                  const SizedBox(height: 8),
                  if (_topics.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'No topics added for this session.',
                        style: AppTextStyles.bodySmall,
                      ),
                    )
                  else
                    ..._topics.asMap().entries.map((e) {
                      final t = e.value;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _topics[e.key] = t.copyWith(done: !t.done);
                        }),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: t.done
                                      ? AppColors.black
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: t.done
                                        ? AppColors.black
                                        : AppColors.border,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: t.done
                                    ? const Icon(
                                        Icons.check,
                                        size: 12,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  t.title,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Sora',
                                    color: t.done
                                        ? AppColors.mutedText
                                        : AppColors.black,
                                    decoration: t.done
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 14),
                  Text('PROGRESS', style: AppTextStyles.sectionLabel),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.black,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$_doneTopics/${_topics.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _completing ? null : _markComplete,
                      style: AppDecorations.primaryButton,
                      child: _completing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Mark Session Complete',
                              style: AppTextStyles.button,
                            ),
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

  Widget _timerBtn(
    IconData icon,
    Color bg,
    Color iconColor,
    VoidCallback onTap, {
    bool large = false,
  }) {
    final size = large ? 44.0 : 36.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: large ? 22 : 17),
      ),
    );
  }
}
