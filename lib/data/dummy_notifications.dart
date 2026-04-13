class DummyNotification {
  final String id;
  final String emoji;
  final String title;
  final String body;
  final String time;
  bool isRead;

  DummyNotification({
    required this.id,
    required this.emoji,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
  });
}

class DummyNotificationsRepository {
  static final List<DummyNotification> notifications = [
    DummyNotification(
      id: '1',
      emoji: '⚠️',
      title: 'Exam in 3 days',
      body:
          'Your Mathematics exam is on Apr 2. You have Chapter 5 remaining. Start your session now.',
      time: 'Just now',
      isRead: false,
    ),
    DummyNotification(
      id: '2',
      emoji: '📅',
      title: 'Plan Rescheduled',
      body:
          "Yesterday's Physics session was missed. Your schedule has been automatically updated.",
      time: '2h ago',
      isRead: false,
    ),
    DummyNotification(
      id: '3',
      emoji: '🔥',
      title: '27-Day Streak!',
      body:
          "Amazing consistency. You've studied every day for 27 days. Keep it up!",
      time: 'Yesterday · 8:00 PM',
      isRead: true,
    ),
    DummyNotification(
      id: '4',
      emoji: '✅',
      title: 'Session Complete',
      body: 'You completed Math Chapter 4 (1h 30m). Great work!',
      time: 'Yesterday · 10:58 AM',
      isRead: true,
    ),
    DummyNotification(
      id: '5',
      emoji: '🕐',
      title: 'Study Reminder',
      body: 'Your 2:00 PM Chemistry session starts in 30 minutes.',
      time: 'Mar 29 · 1:30 PM',
      isRead: true,
    ),
  ];

  static void markAllAsRead() {
    for (final n in notifications) {
      n.isRead = true;
    }
  }

  static void markAsRead(String id) {
    for (final n in notifications) {
      if (n.id == id) {
        n.isRead = true;
        break;
      }
    }
  }

  static int get unreadCount => notifications.where((n) => !n.isRead).length;
}
