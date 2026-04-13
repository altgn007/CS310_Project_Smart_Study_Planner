import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../session/daily_session_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  static const String routeName = '/schedule';

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _selectedTab = 0; // 0: Schedule, 1: Progress
  int _selectedDayIndex = 2; // Wednesday selected by default

  final List<Map<String, dynamic>> _weekDays = [
    {'day': 'MON', 'date': 28},
    {'day': 'TUE', 'date': 29},
    {'day': 'WED', 'date': 30},
    {'day': 'THU', 'date': 31},
    {'day': 'FRI', 'date': 1},
    {'day': 'SAT', 'date': 2},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Center(
          child: Container(
            width: 290,
            height: 590,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(34),
              child: Column(
                children: [
                  // Status bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          '9:41',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Icon(Icons.more_horiz, size: 18, color: Colors.black),
                      ],
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Schedule',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Row(
                            children: const [
                              Text(
                                'March 2026',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              Icon(Icons.keyboard_arrow_down, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tab switcher
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Container(
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          _tabButton('Schedule', 0),
                          _tabButton('Progress', 1),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Content
                  Expanded(
                    child: _selectedTab == 0
                        ? _buildScheduleTab()
                        : _buildProgressTab(),
                  ),

                  _buildBottomNav(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final selected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: selected ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Week day selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _weekDays.asMap().entries.map((entry) {
              final i = entry.key;
              final d = entry.value;
              final selected = _selectedDayIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedDayIndex = i),
                child: Container(
                  width: 36,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? Colors.black : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        d['day'],
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : const Color(0xFFAAAAAA),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${d['date']}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 14),

          const Text(
            'WEDNESDAY, MARCH 30',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: Color(0xFF8A8A8A),
            ),
          ),

          const SizedBox(height: 10),

          // Session list
          ...mockTodaySessions.asMap().entries.map((entry) {
            final i = entry.key;
            final session = entry.value;
            final isDone = i == 0;
            return _SessionRow(
              session: session,
              isDone: isDone,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DailySessionScreen(session: session),
                ),
              ),
            );
          }),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats row
          Row(
            children: [
              _statBox(value: '12h', label: 'Hours\nStudied'),
              const SizedBox(width: 8),
              _statBox(value: '27', label: 'Day\nStreak', emoji: '🔥'),
              const SizedBox(width: 8),
              _statBox(value: '74%', label: 'Completion'),
            ],
          ),

          const SizedBox(height: 14),

          // Goal tracker
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D0D),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GOAL TRACKER',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: Color(0xFF8A8A8A),
                  ),
                ),
                const SizedBox(height: 10),
                _goalRow('Daily Goal', 0.68),
                const SizedBox(height: 8),
                _goalRow('Weekly Goal', 0.75),
              ],
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'BY COURSE',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: Color(0xFF8A8A8A),
            ),
          ),
          const SizedBox(height: 10),
          _courseProgress('M', 'Mathematics', 0.40),
          const SizedBox(height: 8),
          _courseProgress('P', 'Physics', 0.65),
          const SizedBox(height: 8),
          _courseProgress('C', 'Chemistry', 0.20),

          const SizedBox(height: 14),

          const Text(
            'ACTIVITY HEATMAP',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: Color(0xFF8A8A8A),
            ),
          ),
          const SizedBox(height: 8),
          _buildHeatmap(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _statBox({
    required String value,
    required String label,
    String? emoji,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                if (emoji != null) ...[
                  const SizedBox(width: 2),
                  Text(emoji, style: const TextStyle(fontSize: 14)),
                ],
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF8A8A8A),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _goalRow(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 5,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _courseProgress(String initial, String name, double value) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D0D),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 4,
                  backgroundColor: const Color(0xFFE0E0E0),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF0D0D0D),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(value * 100).toInt()}%',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildHeatmap() {
    final List<List<double>> data = [
      [0.8, 0.4, 0.9, 0.2, 0.6, 0.7, 0.3],
      [0.5, 0.9, 0.7, 0.8, 0.4, 0.2, 0.6],
      [0.3, 0.6, 0.8, 0.5, 0.9, 0.4, 0.7],
      [0.7, 0.3, 0.5, 0.9, 0.2, 0.8, 0.4],
      [0.4, 0.7, 0.3, 0.6, 0.8, 0.5, 0.9],
    ];

    return Column(
      children: [
        ...data.map(
          (row) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: row.map((v) {
                return Container(
                  width: 28,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      const Color(0xFFE8F0FE),
                      const Color(0xFF1A56DB),
                      v,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: const [
            Text(
              'Less',
              style: TextStyle(fontSize: 9, color: Color(0xFF8A8A8A)),
            ),
            SizedBox(width: 4),
            _HeatmapLegend(opacity: 0.1),
            SizedBox(width: 2),
            _HeatmapLegend(opacity: 0.3),
            SizedBox(width: 2),
            _HeatmapLegend(opacity: 0.6),
            SizedBox(width: 2),
            _HeatmapLegend(opacity: 1.0),
            SizedBox(width: 4),
            Text(
              'More',
              style: TextStyle(fontSize: 9, color: Color(0xFF8A8A8A)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 52,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_outlined,
            label: 'Home',
            selected: false,
            onTap: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            ),
          ),
          _NavItem(
            icon: Icons.calendar_today_outlined,
            label: 'Schedule',
            selected: true,
            onTap: () {},
          ),
          _NavItem(
            icon: Icons.chat_bubble_outline,
            label: 'Coach',
            selected: false,
            onTap: () => Navigator.pushNamed(context, '/coach'),
          ),
          _NavItem(
            icon: Icons.person_outline,
            label: 'Profile',
            selected: false,
            onTap: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  final Map<String, dynamic> session;
  final bool isDone;
  final VoidCallback onTap;

  const _SessionRow({
    required this.session,
    required this.isDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDone ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDone ? const Color(0xFFF7F7F7) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDone ? const Color(0xFFF0F0F0) : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session['course'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDone ? const Color(0xFFAAAAAA) : Colors.black,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    session['topic'],
                    style: TextStyle(
                      fontSize: 10,
                      color: isDone
                          ? const Color(0xFFBBBBBB)
                          : const Color(0xFF6A6A6A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    session['time'] != null
                        ? '${session['time']} · ${session['duration']}'
                        : session['duration'],
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFFAAAAAA),
                    ),
                  ),
                ],
              ),
            ),
            if (isDone)
              const Icon(Icons.check_circle, size: 18, color: Color(0xFFCCCCCC))
            else
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0D0D),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text(
                    '▶ Start',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeatmapLegend extends StatelessWidget {
  final double opacity;
  const _HeatmapLegend({required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: Color.lerp(
          const Color(0xFFE8F0FE),
          const Color(0xFF1A56DB),
          opacity,
        ),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: selected ? Colors.black : const Color(0xFFB0B0B0),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected ? Colors.black : const Color(0xFFB0B0B0),
            ),
          ),
        ],
      ),
    );
  }
}
