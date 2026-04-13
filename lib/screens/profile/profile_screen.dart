import 'package:flutter/material.dart';
import 'package:smart_study_planner/screens/notifications/notifications_screen.dart';
import '../../data/dummy_users.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const String routeName = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Using first user as the logged-in user for now
  DummyUser get _currentUser => DummyUsersRepository.users.first;

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF7A7A7A)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: const Text('This feature is not available yet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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

                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Page title
                          const Text(
                            'Profile',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Avatar + name + subtitle
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF111111),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _currentUser.fullName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_currentUser.educationLevel} Student · Istanbul',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF8A8A8A),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Stats row
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F7F7),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: const [
                                _StatItem(value: '3', label: 'Courses'),
                                _Divider(),
                                _StatItem(value: '27', label: 'Day Streak'),
                                _Divider(),
                                _StatItem(value: '12h', label: 'This Week'),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ACCOUNT section
                          _SectionLabel(text: 'ACCOUNT'),
                          const SizedBox(height: 8),
                          _SettingsItem(
                            icon: Icons.person_outline,
                            title: 'Edit Profile',
                            subtitle: 'Name, email, photo',
                            onTap: () => _showComingSoon('Edit Profile'),
                          ),
                          _SettingsItem(
                            icon: Icons.notifications_none_outlined,
                            title: 'Notifications',
                            subtitle: 'Reminders, alerts',
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                NotificationsScreen.routeName,
                              );
                            },
                          ),

                          const SizedBox(height: 14),

                          // GENERAL SETTINGS section
                          _SectionLabel(text: 'GENERAL SETTINGS'),
                          const SizedBox(height: 8),
                          _SettingsItem(
                            icon: Icons.contrast_outlined,
                            title: 'Appearance',
                            subtitle: 'Light / Dark mode',
                            onTap: () => _showComingSoon('Appearance'),
                          ),
                          _SettingsItem(
                            icon: Icons.language_outlined,
                            title: 'Language',
                            subtitle: 'English',
                            onTap: () => _showComingSoon('Language'),
                          ),
                          _SettingsItem(
                            icon: Icons.info_outline,
                            title: 'Terms & Conditions',
                            onTap: () => _showComingSoon('Terms & Conditions'),
                          ),
                          _SettingsItem(
                            icon: Icons.lock_outline,
                            title: 'Privacy Policy',
                            onTap: () => _showComingSoon('Privacy Policy'),
                          ),
                          _SettingsItem(
                            icon: Icons.share_outlined,
                            title: 'Share This App',
                            onTap: () => _showComingSoon('Share This App'),
                          ),

                          const SizedBox(height: 18),

                          // Log Out button
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: _handleLogout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFEDED),
                                foregroundColor: Colors.red,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              child: const Text(
                                'Log Out',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),

                  // Bottom nav bar
                  _BottomNavBar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Small reusable widgets ─────────────────────────────

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF8A8A8A)),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 28, color: const Color(0xFFE5E5E5));
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: Color(0xFF7C7C7C),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: Colors.black),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF9A9A9A),
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

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
            selected: false,
            onTap: () => Navigator.pushNamed(context, '/schedule'),
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
            selected: true,
            onTap: () {},
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
