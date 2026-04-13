// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/create_account_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_dashboard.dart';
import 'screens/add_course/add_course_screen.dart';
import 'screens/session/daily_session_screen.dart';
import 'screens/coach/coach_screen.dart';
import 'screens/schedule/schedule_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/notifications/notifications_screen.dart';

void main() {
  runApp(const SmartStudyPlannerApp());
}

class SmartStudyPlannerApp extends StatelessWidget {
  const SmartStudyPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Study Planner',
      theme: ThemeData(
        fontFamily: 'Sora',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName:         (context) => const SplashScreen(),
        OnboardingScreen.routeName:     (context) => const OnboardingScreen(),
        CreateAccountScreen.routeName:  (context) => const CreateAccountScreen(),
        LoginScreen.routeName:          (context) => const LoginScreen(),
        HomeDashboard.routeName:        (context) => const HomeDashboard(),
        AddCourseScreen.routeName:      (context) => const AddCourseScreen(),
        CoachScreen.routeName:          (context) => const CoachScreen(),
        ScheduleScreen.routeName:       (context) => const ScheduleScreen(),
        ProfileScreen.routeName:        (context) => const ProfileScreen(),
        NotificationsScreen.routeName:  (context) => const NotificationsScreen(),
      },
    );
  }
}