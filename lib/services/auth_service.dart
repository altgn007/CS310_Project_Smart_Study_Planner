// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around [FirebaseAuth] that exposes a small, opinionated API.
///
/// The rest of the app should NEVER touch [FirebaseAuth] directly. Going
/// through this service:
///   - keeps a single place to translate raw Firebase errors into messages
///     that are safe and friendly to show in the UI;
///   - lets us swap the implementation in tests without rewriting providers.
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  /// Currently signed-in user, or `null` if signed out.
  User? get currentUser => _auth.currentUser;

  /// Real-time stream of auth state changes — emits the new [User] (or null)
  /// whenever someone signs in/out, or the token is refreshed.
  ///
  /// This is what powers the auth-aware routing in [AuthGate].
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // ── Sign Up ─────────────────────────────────────────────────────────
  Future<User> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('Could not create your account. Please try again.');
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    } catch (_) {
      throw const AuthException('Network error. Please check your connection.');
    }
  }

  // ── Sign In ─────────────────────────────────────────────────────────
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('Could not sign you in. Please try again.');
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    } catch (_) {
      throw const AuthException('Network error. Please check your connection.');
    }
  }

  // ── Sign Out ────────────────────────────────────────────────────────
  Future<void> signOut() => _auth.signOut();

  // ── Password reset (used by "Forgot password?") ─────────────────────
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    }
  }

  /// Translate a [FirebaseAuthException] code into a user-friendly message.
  String _messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled in Firebase.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}

/// Exception type carrying a UI-safe message. The auth screens catch this
/// (and only this) to display dialogs / snackbars.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
