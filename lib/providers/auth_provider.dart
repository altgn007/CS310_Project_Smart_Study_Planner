// lib/providers/auth_provider.dart
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required AuthService authService,
    required FirestoreService firestoreService,
  }) : _auth = authService,
       _firestore = firestoreService {
    _authSub = _auth.authStateChanges().listen(_onAuthChanged);
  }

  final AuthService _auth;
  final FirestoreService _firestore;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<AppUser?>? _profileSub;

  User? _user;
  AppUser? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  AppUser? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get errorMessage => _errorMessage;

  String get displayName {
    if (_profile != null && _profile!.fullName.trim().isNotEmpty) {
      return _profile!.fullName;
    }
    final email = _user?.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    return 'there';
  }

  void _onAuthChanged(User? user) {
    _user = user;
    _profileSub?.cancel();
    _profileSub = null;
    _profile = null;

    if (user != null) {
      _profileSub = _firestore.userProfileStream(user.uid).listen((p) {
        _profile = p;
        notifyListeners();
      });
    }

    notifyListeners();
  }

  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _auth.signIn(email: email, password: password);
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String educationLevel,
    String? dateOfBirth,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = await _auth.signUp(email: email, password: password);
      final appUser = AppUser(
        id: user.uid,
        email: email.trim(),
        fullName: fullName.trim(),
        dateOfBirth: dateOfBirth,
        educationLevel: educationLevel,
        createdAt: DateTime.now(),
      );
      await _firestore.createUserProfile(appUser);
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Could not create your account. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email);
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    }
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}
