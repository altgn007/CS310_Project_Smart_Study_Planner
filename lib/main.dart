import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/create_account_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/home/home_dashboard.dart';
import 'screens/coach/coach_screen.dart';
import 'screens/schedule/schedule_screen.dart';

void main() {
  runApp(const SmartStudyPlannerApp());
}

class SmartStudyPlannerApp extends StatelessWidget {
  const SmartStudyPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        OnboardingScreen.routeName: (context) => const OnboardingScreen(),
        CreateAccountScreen.routeName: (context) => const CreateAccountScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        ProfileScreen.routeName: (context) => const ProfileScreen(),
        NotificationsScreen.routeName: (context) => const NotificationsScreen(),
        HomeDashboard.routeName: (context) => const HomeDashboard(),
        CoachScreen.routeName: (context) => const CoachScreen(),
        ScheduleScreen.routeName: (context) => const ScheduleScreen(),
      },
      builder: (context, child) {
        if (MediaQuery.of(context).size.width <= 500) return child!;
        return Scaffold(
          backgroundColor: const Color(0xFF1A1A1A),
          body: Center(
            child: Container(
              width: 390,
              height: 844,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 60,
                    spreadRadius: 10,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
