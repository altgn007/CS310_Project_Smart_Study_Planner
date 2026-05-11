// lib/screens/home/home_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course.dart';
import '../../models/study_session.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/session_provider.dart';
import '../../utils/app_theme.dart';
import '../add_course/add_course_screen.dart';
import '../session/daily_session_screen.dart';

class HomeDashboard extends StatelessWidget {
  static const String routeName = '/home';
  const HomeDashboard({super.key});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤';
    return 'Good Evening 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final displayName = context.watch<AuthProvider>().displayName;

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
                  const SizedBox(height: 8),
                  _buildHeader(context, displayName),
                  const SizedBox(height: 16),
                  _buildNetworkBanner(),
                  const SizedBox(height: 16),
                  _buildTodayGoalsCard(context),
                  const SizedBox(height: 16),
                  _buildSectionTitle('My Courses'),
                  const SizedBox(height: 10),
                  _buildCourseList(context),
                  const SizedBox(height: 16),
                  _buildQuickActions(context),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          AppBottomNav(currentIndex: 0),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    return StreamBuilder<List<StudySession>>(
      stream: context.read<SessionProvider>().todaySessionsStream,
      builder: (context, snap) {
        final count = snap.data?.length ?? 0;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_greeting, style: AppTextStyles.bodySmall),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                      fontFamily: 'Sora',
                    ),
                  ),
                  Text(
                    '$count session${count == 1 ? '' : 's'} today',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/avatar_placeholder.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_outline, color: Colors.grey, size: 20),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNetworkBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=600&q=80',
        height: 80,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black),
            ),
          );
        },
        errorBuilder: (_, __, ___) => Container(
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(child: Icon(Icons.menu_book_outlined, color: Colors.grey)),
        ),
      ),
    );
  }

  Widget _buildTodayGoalsCard(BuildContext context) {
    return StreamBuilder<List<StudySession>>(
      stream: context.read<SessionProvider>().todaySessionsStream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.all(16),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            ),
          );
        }

        final sessions = snap.data ?? [];

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "TODAY'S GOALS",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: Colors.grey[500],
                  fontFamily: 'Sora',
                ),
              ),
              const SizedBox(height: 10),
              if (sessions.isEmpty)
                Text(
                  'No sessions scheduled for today.',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500], fontFamily: 'Sora'),
                )
              else
                ...sessions.asMap().entries.map((entry) {
                  final session = entry.value;
                  final colors = [AppColors.green, AppColors.yellow, AppColors.orange];
                  final dotColor = colors[entry.key % colors.length];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DailySessionScreen(session: session.toSessionMap()),
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                          ),
                          Expanded(
                            child: Text(
                              '${session.courseName} · ${session.topic} · ${session.duration}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontFamily: 'Sora',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.play_arrow, color: Colors.white54, size: 14),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title.toUpperCase(), style: AppTextStyles.sectionLabel);
  }

  Widget _buildCourseList(BuildContext context) {
    return StreamBuilder<List<Course>>(
      stream: context.read<CourseProvider>().coursesStream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black),
            ),
          );
        }

        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text('Error loading courses.', style: AppTextStyles.bodySmall),
          );
        }

        final courses = snap.data ?? [];

        if (courses.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('No courses yet. Add one below!', style: AppTextStyles.bodySmall),
            ),
          );
        }

        return Column(
          children: courses
              .map((course) => _buildCourseCard(context, course))
              .toList(),
        );
      },
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                      fontFamily: 'Sora',
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Exam: ${_formatDate(course.examDate)}',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: course.progress,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.black),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(course.progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Sora',
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: course.urgent ? AppColors.urgentBg : AppColors.border,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${course.daysLeft}d',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: course.urgent ? AppColors.urgent : AppColors.mutedText,
                  fontFamily: 'Sora',
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _showRemoveDialog(context, course),
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

  void _showRemoveDialog(BuildContext context, Course course) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Remove Course',
          style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Remove "${course.name}" from your courses?',
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
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CourseProvider>().deleteCourse(course.id);
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red, fontFamily: 'Sora'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, AddCourseScreen.routeName),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Center(
                child: Text(
                  '+ Add Course',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Sora',
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/coach'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border, width: 1.5),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Center(
                child: Text(
                  'AI Coach',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    fontFamily: 'Sora',
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
