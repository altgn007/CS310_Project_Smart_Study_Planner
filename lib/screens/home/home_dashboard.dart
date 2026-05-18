// lib/screens/home/home_dashboard.dart
//
// GROUP A — final clean version.
// "My Courses" reads real Firestore data via CourseProvider (StreamBuilder).
// Mock data fully removed. Header avatar is aligned with the name and has a
// notification bell next to it.
//
// NOTE: "Today's Goals" intentionally shows an empty state here. Wiring it
// to real study sessions (plus streak / this-week stats and the Schedule
// screen) is GROUP D work and will be done on the fix/group-d-schedule
// branch.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/course.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../utils/app_theme.dart';
import '../add_course/add_course_screen.dart';
import '../notifications/notifications_screen.dart';

class HomeDashboard extends StatelessWidget {
  static const String routeName = '/home';
  const HomeDashboard({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤';
    return 'Good Evening 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<AuthProvider>().displayName;
    final coursesStream = context.watch<CourseProvider>().coursesStream;

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
                  _Header(greeting: _greeting(), name: userName),
                  const SizedBox(height: 16),
                  const _NetworkBanner(),
                  const SizedBox(height: 16),
                  const _TodayGoalsCard(),
                  const SizedBox(height: 16),
                  Text('MY COURSES', style: AppTextStyles.sectionLabel),
                  const SizedBox(height: 10),
                  if (coursesStream == null)
                    const _EmptyCourses()
                  else
                    StreamBuilder<List<Course>>(
                      stream: coursesStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData) {
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
                        if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'Could not load courses.',
                              style: AppTextStyles.bodySmall,
                            ),
                          );
                        }
                        final courses = snapshot.data ?? const <Course>[];
                        if (courses.isEmpty) {
                          return const _EmptyCourses();
                        }
                        return Column(
                          children: [
                            for (final c in courses) _CourseCard(course: c),
                          ],
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                  const _QuickActions(),
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
}

class _Header extends StatelessWidget {
  const _Header({required this.greeting, required this.name});

  final String greeting;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(greeting, style: AppTextStyles.bodySmall),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                  fontFamily: 'Sora',
                ),
              ),
            ),
            const _NotificationBell(hasUnread: false),
            const SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/avatar_placeholder.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.hasUnread});

  final bool hasUnread;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, NotificationsScreen.routeName),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              size: 20,
              color: AppColors.black,
            ),
            if (hasUnread)
              Positioned(
                top: 9,
                right: 9,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NetworkBanner extends StatelessWidget {
  const _NetworkBanner();

  @override
  Widget build(BuildContext context) {
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
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.black,
              ),
            ),
          );
        },
        errorBuilder: (_, _, _) => Container(
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
            child: Icon(Icons.menu_book_outlined, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}

class _TodayGoalsCard extends StatelessWidget {
  const _TodayGoalsCard();

  @override
  Widget build(BuildContext context) {
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
          Text(
            'No study sessions scheduled for today.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
              fontFamily: 'Sora',
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
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
                    'Exam: ${course.examDateLabel}',
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
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.black,
                            ),
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
              onTap: () => _confirmRemove(context),
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

  void _confirmRemove(BuildContext context) {
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
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<CourseProvider>().deleteCourse(course.id);
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
}

class _EmptyCourses extends StatelessWidget {
  const _EmptyCourses();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'No courses yet. Add one below!',
          style: AppTextStyles.bodySmall,
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, AddCourseScreen.routeName),
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
}
