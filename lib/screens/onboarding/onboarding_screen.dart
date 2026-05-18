import 'package:flutter/material.dart';
import 'package:smart_study_planner/services/prefs_service.dart';
import 'package:smart_study_planner/screens/auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const String routeName = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Plan Smarter,\nStudy Better',
      'description':
          "Add your courses and exam dates. We'll automatically build a personalised study schedule that adapts when life gets in the way.",
      'icon': 'schedule',
    },
    {
      'title': 'Track Tasks,\nStay Focused',
      'description':
          'Keep your study sessions, assignments, and deadlines in one place so you always know what to do next.',
      'icon': 'check',
    },
    {
      'title': 'Build Better\nStudy Habits',
      'description':
          'Get a clearer overview of your progress and create a more consistent daily routine for your academic goals.',
      'icon': 'insights',
    },
  ];

  Future<void> _goToLogin() async {
    await PrefsService().writeOnboardingDone(true);
    if (!mounted) return;
    // Onboarding → Login (per requirement). From Login the user can tap
    // "Create account" to register.
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  void _nextPage() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildTopIllustration(String iconType) {
    IconData iconData;
    switch (iconType) {
      case 'check':
        iconData = Icons.task_alt_rounded;
        break;
      case 'insights':
        iconData = Icons.auto_graph_rounded;
        break;
      case 'schedule':
      default:
        iconData = Icons.schedule_rounded;
        break;
    }

    return Container(
      width: double.infinity,
      height: 175,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD9D9D9), width: 1.2),
          ),
          child: Icon(iconData, size: 38, color: const Color(0xFF222222)),
        ),
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentIndex == index ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: _currentIndex == index
                ? Colors.black
                : const Color(0xFFD6D6D6),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showBack = _currentIndex > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Center(
          child: Container(
            width: 290,
            height: 590,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top row: a real Back button (left) appears from page 2.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 60,
                      child: showBack
                          ? GestureDetector(
                              onTap: _previousPage,
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.arrow_back,
                                    size: 16,
                                    color: Colors.black,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Back',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const Text(
                              '9:41',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                    ),
                    const Icon(Icons.more_horiz, size: 18, color: Colors.black),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    // Default physics already allows swiping left AND
                    // right between pages.
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTopIllustration(page['icon']!),
                          const SizedBox(height: 22),
                          Text(
                            page['title']!,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            page['description']!,
                            style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.5,
                              color: Color(0xFF707070),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                _buildDots(),
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (showBack) ...[
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: _previousPage,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFD6D6D6)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Text(
                              'Back',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(
                            _currentIndex == _pages.length - 1
                                ? 'Get Started'
                                : 'Next',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _goToLogin,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7A7A7A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
