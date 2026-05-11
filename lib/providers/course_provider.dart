// lib/providers/course_provider.dart
import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../services/firestore_service.dart';

/// Bridges the [FirestoreService.coursesStream] to the UI.
///
/// Screens can either:
///   - watch [coursesStream] directly with a `StreamBuilder` (the spec
///     requires us to demonstrate this), or
///   - watch this provider (`context.watch<CourseProvider>()`) for the
///     latest snapshot via [courses].
///
/// We expose a simple [setUserId] hook so the provider can be created at
/// app start and then "switched on" once the user logs in.
class CourseProvider extends ChangeNotifier {
  CourseProvider({required FirestoreService firestoreService})
      : _firestore = firestoreService;

  final FirestoreService _firestore;
  String? _userId;

  /// The cached latest snapshot of courses. Updated whenever the stream
  /// emits. May be empty if no user is signed in.
  List<Course> _courses = [];
  List<Course> get courses => List.unmodifiable(_courses);

  /// The raw Firestore stream — perfect for `StreamBuilder`s that want to
  /// show explicit loading / error states.
  Stream<List<Course>>? get coursesStream =>
      _userId == null ? null : _firestore.coursesStream(_userId!);

  /// Re-bind the provider to a new user id (called by the AuthProvider
  /// hookup in `main.dart` whenever auth state changes).
  void setUserId(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _courses = [];
    notifyListeners();
    // Subscribe to the stream so [courses] stays warm even when nobody
    // is using the StreamBuilder version.
    if (userId != null) {
      _firestore.coursesStream(userId).listen((list) {
        _courses = list;
        notifyListeners();
      });
    }
  }

  // ── CRUD ────────────────────────────────────────────────────────────
  Future<Course?> addCourse({
    required String name,
    required DateTime examDate,
    required String priority,
    required List<String> topics,
    required double dailyHours,
    required List<String> studyDays,
  }) async {
    final uid = _userId;
    if (uid == null) return null;
    return _firestore.createCourse(
      userId: uid,
      name: name,
      examDate: examDate,
      priority: priority,
      topics: topics,
      dailyHours: dailyHours,
      studyDays: studyDays,
    );
  }

  Future<void> updateCourse(String id, Map<String, dynamic> patch) {
    return _firestore.updateCourse(id, patch);
  }

  Future<void> deleteCourse(String id) => _firestore.deleteCourse(id);
}
