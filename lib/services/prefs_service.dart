// lib/services/prefs_service.dart
import 'package:shared_preferences/shared_preferences.dart';

/// Tiny wrapper around [SharedPreferences] that owns every key we persist
/// locally. Centralizing the keys here means we never have a typo
/// mismatch between read and write sites.
///
/// Spec requirement: "Persist at least one simple preference using
/// SharedPreferences." We persist:
///   - the theme mode (`light` / `dark` / `system`),
///   - whether the user has completed onboarding.
class PrefsService {
  static const _kThemeMode = 'theme_mode';
  static const _kOnboardingDone = 'onboarding_done';

  // ── Theme mode ──────────────────────────────────────────────────────
  Future<String> readThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kThemeMode) ?? 'system';
  }

  Future<void> writeThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeMode, mode);
  }

  // ── Onboarding seen ─────────────────────────────────────────────────
  Future<bool> readOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboardingDone) ?? false;
  }

  Future<void> writeOnboardingDone(bool done) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingDone, done);
  }
}
