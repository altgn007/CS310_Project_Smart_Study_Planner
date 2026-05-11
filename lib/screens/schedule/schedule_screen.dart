// lib/screens/schedule/schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course.dart';
import '../../models/study_session.dart';
import '../../providers/course_provider.dart';
import '../../providers/session_provider.dart';
import '../../utils/app_theme.dart';
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
                    Text(
                      _monthYear(DateTime.now()),
                      style: AppTextStyles.bodySmall,
                    ),
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
                    children: [
                      _tab('Schedule', 0),
                      _tab('Progress', 1),
                    ],
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

  Widget _buildScheduleTab() {
    return StreamBuilder<List<StudySession>>(
      stream: context.read<SessionProvider>().todaySessionsStream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black),
          );
        }

        final sessions = snap.data ?? [];

        return SingleChildScrollView(
          padding: AppPadding.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text('TODAY', style: AppTextStyles.sectionLabel),
              const SizedBox(height: 8),
              if (sessions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'No sessions scheduled for today.',
                    style: AppTextStyles.bodySmall,
                  ),
                )
              else
                ...sessions.map((s) => _sessionBlock(s)),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _sessionBlock(StudySession s) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DailySessionScreen(session: s.toSessionMap()),
        ),
      ),
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
              color: s.urgent ? AppColors.urgent : AppColors.black,
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
                  Text('${s.time} · ${s.duration}', style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text(
                '▶ Start',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Sora',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTab() {
    return StreamBuilder<List<Course>>(
      stream: context.read<CourseProvider>().coursesStream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black),
          );
        }

        final courses = snap.data ?? [];

        return SingleChildScrollView(
          padding: AppPadding.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Row(
                children: [
                  _statCard('${courses.length}', 'Courses'),
                  const SizedBox(width: 8),
                  _statCard(
                    courses.isEmpty
                        ? '0%'
                        : '${((courses.map((c) => c.progress).reduce((a, b) => a + b) / courses.length) * 100).toInt()}%',
                    'Avg Done',
                  ),
                  const SizedBox(width: 8),
                  _statCard(
                    courses.where((c) => c.urgent).length.toString(),
                    'Urgent',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text('BY COURSE', style: AppTextStyles.sectionLabel),
              const SizedBox(height: 8),
              if (courses.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text('No courses yet.', style: AppTextStyles.bodySmall),
                )
              else
                ...courses.map((c) => _courseProgress(c)),
            ],
          ),
        );
      },
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
              Text('${(c.progress * 100).toInt()}%', style: AppTextStyles.bodySmall),
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

  String _monthYear(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }
}
