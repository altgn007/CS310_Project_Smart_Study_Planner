// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/course_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/session_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/add_course/add_course_screen.dart';
import 'screens/auth/create_account_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/coach/coach_screen.dart';
import 'screens/home/home_dashboard.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/schedule/schedule_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/ai_service.dart';
import 'services/firestore_service.dart';
import 'services/prefs_service.dart';
import 'utils/app_theme.dart';
import 'widgets/auth_gate.dart';
import 'screens/session/add_session_screen.dart';

Future<void> main() async {
  // Initialize Flutter bindings before touching any plugin code.
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (OpenAI API key etc.) from the bundled .env
  // file. We swallow the error so the app still boots even if the developer
  // hasn't created one yet — the AI Coach will simply show a friendly
  // "API key not configured" message.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // No .env present — AiService.isConfigured will return false.
  }

  // Initialize Firebase ONCE for the whole app.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const SmartStudyPlannerApp());
}

class SmartStudyPlannerApp extends StatelessWidget {
  const SmartStudyPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Singleton service instances live above the provider tree — they hold
    // no state, so it's safe to share them between providers.
    final authService = AuthService();
    final firestoreService = FirestoreService();
    final prefsService = PrefsService();
    final aiService = AiService();

    return MultiProvider(
      providers: [
        // ── Theme (independent — purely local prefs) ───────────────────
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(prefs: prefsService),
        ),

        // ── Auth (the source of truth for "who is logged in") ──────────
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(
            authService: authService,
            firestoreService: firestoreService,
          ),
        ),

        // ── Data providers, scoped to the current user ─────────────────
        // ChangeNotifierProxyProvider lets us rebuild the data providers
        // whenever auth state changes, so they automatically re-bind to
        // the new user's data (or clear out on logout).
        ChangeNotifierProxyProvider<AuthProvider, CourseProvider>(
          create: (_) => CourseProvider(firestoreService: firestoreService),
          update: (_, auth, prev) {
            final p =
                prev ?? CourseProvider(firestoreService: firestoreService);
            p.setUserId(auth.user?.uid);
            return p;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, SessionProvider>(
          create: (_) => SessionProvider(firestoreService: firestoreService),
          update: (_, auth, prev) {
            final p =
                prev ?? SessionProvider(firestoreService: firestoreService);
            p.setUserId(auth.user?.uid);
            return p;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, NotificationProvider>(
          create: (_) =>
              NotificationProvider(firestoreService: firestoreService),
          update: (_, auth, prev) {
            final p =
                prev ??
                NotificationProvider(firestoreService: firestoreService);
            p.setUserId(auth.user?.uid);
            return p;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ChatProvider>(
          create: (_) => ChatProvider(
            firestoreService: firestoreService,
            aiService: aiService,
          ),
          update: (_, auth, prev) {
            final p =
                prev ??
                ChatProvider(
                  firestoreService: firestoreService,
                  aiService: aiService,
                );
            p.setUserId(auth.user?.uid);
            return p;
          },
        ),
      ],
      // Consumer<ThemeProvider> wraps MaterialApp so that toggling theme mode
      // immediately rebuilds the whole app with the new theme.
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Smart Study Planner',
          themeMode: theme.themeMode,
          theme: ThemeData(
            fontFamily: 'Sora',
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
            useMaterial3: true,
            scaffoldBackgroundColor: AppColors.background,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            fontFamily: 'Sora',
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.black,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
          // The splash runs first, then we delegate to the AuthGate which
          // decides Onboarding / Login / Home based on real auth state.
          home: const SplashScreen(),
          routes: {
            SplashScreen.routeName: (_) => const SplashScreen(),
            OnboardingScreen.routeName: (_) => const OnboardingScreen(),
            CreateAccountScreen.routeName: (_) => const CreateAccountScreen(),
            LoginScreen.routeName: (_) => const LoginScreen(),
            AuthGate.routeName: (_) => const AuthGate(),
            HomeDashboard.routeName: (_) => const HomeDashboard(),
            AddCourseScreen.routeName: (_) => const AddCourseScreen(),
            CoachScreen.routeName: (_) => const CoachScreen(),
            ScheduleScreen.routeName: (_) => const ScheduleScreen(),
            ProfileScreen.routeName: (_) => const ProfileScreen(),
            NotificationsScreen.routeName: (_) => const NotificationsScreen(),
            AddSessionScreen.routeName: (_) => const AddSessionScreen(),
          },
        ),
      ),
    );
  }
}
