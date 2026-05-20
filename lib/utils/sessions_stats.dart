// lib/utils/session_stats.dart
import '../models/study_session.dart';

/// Pure-function helpers that turn a list of [StudySession]s into the
/// stats shown on Home and Profile.
///
/// Kept here so the same logic can be reused (and unit-tested later for
/// the assignment's testing requirement).
class SessionStats {
  /// How many consecutive days, ending today, contain at least one
  /// completed (`done == true`) session. If today has none, the streak
  /// is 0 — we don't carry yesterday's streak forward through a missed
  /// day.
  static int currentStreak(List<StudySession> sessions) {
    final doneDays = <DateTime>{};
    for (final s in sessions) {
      if (!s.done) continue;
      doneDays.add(DateTime(s.date.year, s.date.month, s.date.day));
    }
    if (doneDays.isEmpty) return 0;

    final now = DateTime.now();
    var day = DateTime(now.year, now.month, now.day);

    // If today has no completed session, streak is 0.
    if (!doneDays.contains(day)) return 0;

    int streak = 0;
    while (doneDays.contains(day)) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Sum of duration strings of completed sessions in the current week
  /// (Monday → Sunday containing today), as a human label like "12h 30m".
  static String thisWeekStudied(List<StudySession> sessions) {
    final now = DateTime.now();
    // Start of week (Monday 00:00).
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    // End of week (Sunday 23:59:59).
    final weekEnd = weekStart.add(const Duration(days: 7));

    int totalMinutes = 0;
    for (final s in sessions) {
      if (!s.done) continue;
      if (s.date.isBefore(weekStart) || !s.date.isBefore(weekEnd)) {
        continue;
      }
      totalMinutes += _parseDurationMinutes(s.duration);
    }
    if (totalMinutes == 0) return '0h';
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  /// Parse strings like "2h", "1h 30m", "45m", "0.5h" → minutes.
  static int _parseDurationMinutes(String raw) {
    final s = raw.trim().toLowerCase();
    if (s.isEmpty) return 0;

    int minutes = 0;
    // Match `<number>h` and `<number>m` parts (allow decimals on h).
    final hMatch = RegExp(r'(\d+(?:\.\d+)?)\s*h').firstMatch(s);
    if (hMatch != null) {
      final h = double.tryParse(hMatch.group(1) ?? '0') ?? 0;
      minutes += (h * 60).round();
    }
    final mMatch = RegExp(r'(\d+)\s*m').firstMatch(s);
    if (mMatch != null) {
      minutes += int.tryParse(mMatch.group(1) ?? '0') ?? 0;
    }
    return minutes;
  }

  /// Filter the list to only sessions scheduled for today (regardless of
  /// `done` status).
  static List<StudySession> todaysSessions(List<StudySession> sessions) {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final dayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final list = sessions
        .where((s) => !s.date.isBefore(dayStart) && !s.date.isAfter(dayEnd))
        .toList();
    list.sort((a, b) => a.time.compareTo(b.time));
    return list;
  }
}
