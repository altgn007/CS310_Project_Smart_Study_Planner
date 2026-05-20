// lib/screens/schedule/schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/course.dart';
import '../../models/study_session.dart';
import '../../providers/course_provider.dart';
import '../../providers/session_provider.dart';
import '../../utils/app_theme.dart';
import '../session/add_session_screen.dart';
import '../session/daily_session_screen.dart';

class ScheduleScreen extends StatefulWidget {
  static const String routeName = '/schedule';
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy').format(DateTime.now());

    return PhoneCard(
      child: Column(
        children: [
          const AppStatusBar(),
          Padding(
            padding: AppPadding.screen,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Schedule', style: AppTextStyles.screenTitle),
                    Text(monthLabel, style: AppTextStyles.bodySmall),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Row(
                    children: [_tab('Schedule', 0), _tab('Progress', 1)],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _tabIndex == 0 ? _buildScheduleTab() : _buildProgressTab(),
          ),
          AppBottomNav(currentIndex: 1),
        ],
      ),
    );
  }

  Widget _tab(String label, int index) {
    final selected = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Sora',
              color: selected ? Colors.white : AppColors.mutedText,
            ),
          ),
        ),
      ),
    );
  }

  // ── SCHEDULE TAB ────────────────────────────────────────────────────
  Widget _buildScheduleTab() {
    final upcomingStream = context
        .watch<SessionProvider>()
        .upcomingSessionsStream;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: AppPadding.screen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                if (upcomingStream == null)
                  _emptyHint('Sign in to see your sessions.')
                else
                  StreamBuilder<List<StudySession>>(
                    stream: upcomingStream,
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting &&
                          !snap.hasData) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.black,
                            ),
                          ),
                        );
                      }
                      if (snap.hasError) {
                        return _emptyHint('Could not load sessions.');
                      }
                      final all = snap.data ?? const <StudySession>[];
                      return _buildGroupedSessions(all);
                    },
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AddSessionScreen.routeName),
              style: AppDecorations.primaryButton,
              child: const Text('+ Add Session', style: AppTextStyles.button),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupedSessions(List<StudySession> all) {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final dayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final today = all
        .where((s) => !s.date.isBefore(dayStart) && !s.date.isAfter(dayEnd))
        .toList();
    final upcoming = all.where((s) => s.date.isAfter(dayEnd)).toList();

    final Map<String, List<StudySession>> upcomingByDate = {};
    for (final s in upcoming) {
      final key = DateFormat('EEEE, MMM d').format(s.date);
      upcomingByDate.putIfAbsent(key, () => []).add(s);
    }

    if (today.isEmpty && upcoming.isEmpty) {
      return _emptyHint('No sessions yet. Add one below!');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TODAY', style: AppTextStyles.sectionLabel),
        const SizedBox(height: 8),
        if (today.isEmpty)
          _emptyHint('No sessions scheduled for today.')
        else
          for (final s in today) _sessionBlock(s),
        if (upcoming.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('UPCOMING', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 8),
          for (final entry in upcomingByDate.entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 6),
              child: Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mutedText,
                  fontFamily: 'Sora',
                ),
              ),
            ),
            for (final s in entry.value) _sessionBlock(s),
          ],
        ],
      ],
    );
  }

  Widget _emptyHint(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(text, style: AppTextStyles.bodySmall),
      ),
    );
  }

  Widget _sessionBlock(StudySession s) {
    return GestureDetector(
      onTap: () {
        if (s.done) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DailySessionScreen(session: s)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          border: Border(
            left: BorderSide(
              color: s.done
                  ? AppColors.mutedText
                  : (s.urgent ? AppColors.urgent : AppColors.black),
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.courseName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Sora',
                    ),
                  ),
                  Text(s.topic, style: AppTextStyles.bodySmall),
                  Text(
                    '${s.time} · ${s.duration}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: s.done ? AppColors.mutedText : AppColors.black,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                s.done ? '✓ Done' : '▶ Start',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Sora',
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _confirmDeleteSession(s),
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteSession(StudySession s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Delete Session',
          style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Delete this ${s.courseName} session (${s.topic})? '
          'Your course progress will be recalculated.',
          style: const TextStyle(fontFamily: 'Sora'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.mutedText, fontFamily: 'Sora'),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<SessionProvider>().deleteSession(
                sessionId: s.id,
                courseId: s.courseId,
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontFamily: 'Sora'),
            ),
          ),
        ],
      ),
    );
  }

  // ── PROGRESS TAB ────────────────────────────────────────────────────
  Widget _buildProgressTab() {
    final coursesStream = context.watch<CourseProvider>().coursesStream;

    return SingleChildScrollView(
      padding: AppPadding.screen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          if (coursesStream == null)
            _emptyHint('Sign in to see your progress.')
          else
            StreamBuilder<List<Course>>(
              stream: coursesStream,
              builder: (context, snap) {
                final courses = snap.data ?? const <Course>[];
                final count = courses.length;
                final avg = courses.isEmpty
                    ? 0
                    : (courses.map((c) => c.progress).reduce((a, b) => a + b) /
                              courses.length *
                              100)
                          .round();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _statCard('$count', 'Courses'),
                        const SizedBox(width: 8),
                        _statCard('$avg%', 'Avg Done'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text('BY COURSE', style: AppTextStyles.sectionLabel),
                    const SizedBox(height: 8),
                    if (courses.isEmpty)
                      _emptyHint('No courses yet.')
                    else
                      for (final c in courses) _courseProgress(c),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                fontFamily: 'Sora',
              ),
            ),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _courseProgress(Course c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                c.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Sora',
                ),
              ),
              Text(
                '${(c.progress * 100).toInt()}%',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: c.progress,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.black),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}
