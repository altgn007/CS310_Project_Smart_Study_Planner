// lib/screens/schedule/schedule_screen.dart
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../data/mock_data.dart';
import '../session/daily_session_screen.dart';

class ScheduleScreen extends StatefulWidget {
  static const String routeName = '/schedule';
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _tabIndex = 0; // 0 = Schedule, 1 = Progress

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
                    Text('April 2026', style: AppTextStyles.bodySmall),
                  ],
                ),
                const SizedBox(height: 12),
                // Schedule / Progress tab switcher
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
    return SingleChildScrollView(
      padding: AppPadding.screen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text('TODAY', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 8),
          ...mockTodaySessions.map((s) => _sessionBlock(s)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _sessionBlock(Map<String, dynamic> s) {
    final urgent = s['urgent'] as bool;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DailySessionScreen(session: s)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
            topLeft: Radius.zero,
            bottomLeft: Radius.zero,
          ),
          border: Border(
            left: BorderSide(
              color: urgent ? AppColors.urgent : AppColors.black,
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
                  Text(s['course'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Sora')),
                  Text(s['topic'], style: AppTextStyles.bodySmall),
                  Text('${s['time']} · ${s['duration']}', style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(100)),
              child: const Text('▶ Start', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: 'Sora')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: AppPadding.screen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          // Stats
          Row(
            children: [
              _statCard('12h', 'Studied'),
              const SizedBox(width: 8),
              _statCard('27🔥', 'Streak'),
              const SizedBox(width: 8),
              _statCard('74%', 'Done'),
            ],
          ),
          const SizedBox(height: 14),
          Text('BY COURSE', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 8),
          ...mockCourses.map((c) => _courseProgress(c)),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'Sora')),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _courseProgress(Map<String, dynamic> c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(c['name'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Sora')),
              Text('${((c['progress'] as double) * 100).toInt()}%', style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: c['progress'] as double,
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