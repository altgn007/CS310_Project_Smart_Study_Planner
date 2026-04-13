// lib/screens/home_dashboard.dart
import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../add_course/add_course_screen.dart';
import '../session/daily_session_screen.dart';
import '../profile/profile_screen.dart';

class HomeDashboard extends StatelessWidget {
  static const String routeName = '/home';
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildHeader(context),
                    const SizedBox(height: 20),
                    _buildTodayGoalsCard(context),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Upcoming Exams'),
                    const SizedBox(height: 12),
                    ...mockCourses.map((c) => _buildExamRow(c)),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Quick Actions'),
                    const SizedBox(height: 12),
                    _buildQuickActions(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 0),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning ☀️',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                mockUserName,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: Color(0xFF0D0D0D),
                ),
              ),
              Text(
                '${mockTodaySessions.length} sessions scheduled today',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.person_outline, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTodayGoalsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TODAY'S GOALS",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.08 * 11,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 12),
          ...mockTodaySessions.asMap().entries.map((entry) {
            final session = entry.value;
            final colors = [
              const Color(0xFF5BE878),
              const Color(0xFFF5C842),
              const Color(0xFFF58C42),
            ];
            final dotColor = colors[entry.key % colors.length];
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DailySessionScreen(session: session),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 10, top: 1),
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${session['course']} · ${session['topic']} · ${session['duration']}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.play_arrow,
                      color: Colors.white54,
                      size: 16,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.06 * 11,
        color: Colors.grey[600],
        textBaseline: TextBaseline.alphabetic,
      ),
    );
  }

  Widget _buildExamRow(Map<String, dynamic> course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D0D0D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  course['examDate'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: course['urgent']
                  ? const Color(0xFFFFF0F0)
                  : const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${course['daysLeft']} days',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: course['urgent']
                    ? const Color(0xFFCC2222)
                    : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        _actionChip(
          label: '+ Add Course',
          filled: true,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCourseScreen()),
          ),
        ),
        _actionChip(label: 'View Plan', filled: false, onTap: () {}),
        _actionChip(label: 'AI Coach', filled: false, onTap: () {}),
      ],
    );
  }

  Widget _actionChip({
    required String label,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: filled ? const Color(0xFF0D0D0D) : Colors.transparent,
          border: filled
              ? null
              : Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: filled ? Colors.white : const Color(0xFF0D0D0D),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, int currentIndex) {
    return Container(
      height: 82,
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            icon: Icons.home_rounded,
            label: 'Home',
            active: currentIndex == 0,
            onTap: () {},
          ),
          _navItem(
            icon: Icons.calendar_today_outlined,
            label: 'Schedule',
            active: currentIndex == 1,
            onTap: () => Navigator.pushNamed(context, '/schedule'),
          ),
          _navItem(
            icon: Icons.chat_bubble_outline,
            label: 'Coach',
            active: currentIndex == 2,
            onTap: () => Navigator.pushNamed(context, '/coach'),
          ),
          _navItem(
            icon: Icons.person_outline,
            label: 'Profile',
            active: currentIndex == 3,
            onTap: () => Navigator.pushNamed(context, ProfileScreen.routeName),
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0D0D0D) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: active ? Colors.white : Colors.grey),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: active ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
