// lib/widgets/auth_gate.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/home/home_dashboard.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../services/prefs_service.dart';
import '../utils/app_theme.dart';

/// Top-level routing gate.
///
/// Listens to [FirebaseAuth.authStateChanges] and decides which screen to
/// show:
///   - logged in            → [HomeDashboard]
///   - not logged in, first → [OnboardingScreen]
///   - not logged in, seen  → [LoginScreen]
///
/// This is the heart of "auth-aware navigation". Login and sign-up screens
/// no longer have to push routes themselves — successful auth flips the
/// stream and the gate rebuilds.
class AuthGate extends StatelessWidget {
  static const String routeName = '/auth-gate';

  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        // While we don't yet know the auth state, show a loading screen
        // (the splash already ran, so this should be near-instant).
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const _AuthLoading();
        }

        if (authSnap.hasData) {
          // Logged in.
          return const HomeDashboard();
        }

        // Logged out — decide between Onboarding and Login based on
        // whether the user has already completed onboarding once.
        return FutureBuilder<bool>(
          future: PrefsService().readOnboardingDone(),
          builder: (context, prefsSnap) {
            if (!prefsSnap.hasData) return const _AuthLoading();
            return prefsSnap.data == true
                ? const LoginScreen()
                : const OnboardingScreen();
          },
        );
      },
    );
  }
}

class _AuthLoading extends StatelessWidget {
  const _AuthLoading();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.black),
      ),
    );
  }
}
