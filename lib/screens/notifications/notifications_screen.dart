import 'package:flutter/material.dart';
import '../../data/dummy_notifications.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  static const String routeName = '/notifications';

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<DummyNotification> get _notifications =>
      DummyNotificationsRepository.notifications;

  void _markAllRead() {
    setState(() {
      DummyNotificationsRepository.markAllAsRead();
    });
  }

  void _markOneRead(String id) {
    setState(() {
      DummyNotificationsRepository.markAsRead(id);
    });
  }

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
                      vertical: 16,
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
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                        const Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: _markAllRead,
                          child: const Text(
                            'Mark all read',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7A7A7A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Notification list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final n = _notifications[index];
                        return _NotificationTile(
                          notification: n,
                          onTap: () => _markOneRead(n.id),
                        );
                      },
                    ),
                  ),

                  // Bottom nav bar
                  _BottomNavBar(currentIndex: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final DummyNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread dot
            Padding(
              padding: const EdgeInsets.only(top: 5, right: 8),
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: notification.isRead
                      ? Colors.transparent
                      : Colors.black,
                ),
              ),
            ),

            // Emoji
            Text(notification.emoji, style: const TextStyle(fontSize: 16)),

            const SizedBox(width: 8),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: notification.isRead
                          ? FontWeight.w600
                          : FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.body,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.4,
                      color: Color(0xFF6A6A6A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.time,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFFAAAAAA),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const _BottomNavBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.home_outlined, label: 'Home', selected: false),
          _NavItem(
            icon: Icons.calendar_today_outlined,
            label: 'Schedule',
            selected: false,
          ),
          _NavItem(
            icon: Icons.chat_bubble_outline,
            label: 'Coach',
            selected: false,
          ),
          _NavItem(
            icon: Icons.person_outline,
            label: 'Profile',
            selected: true,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}
