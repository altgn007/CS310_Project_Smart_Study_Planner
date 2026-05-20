// lib/providers/session_provider.dart
import 'package:flutter/foundation.dart';

import '../models/study_session.dart';
import '../services/firestore_service.dart';

class SessionProvider extends ChangeNotifier {
  SessionProvider({required FirestoreService firestoreService})
    : _firestore = firestoreService;

  final FirestoreService _firestore;
  String? _userId;

  List<StudySession> _today = [];
  List<StudySession> get todaySessions => List.unmodifiable(_today);

  Stream<List<StudySession>>? get todaySessionsStream =>
      _userId == null ? null : _firestore.todaySessionsStream(_userId!);

  Stream<List<StudySession>>? get upcomingSessionsStream =>
      _userId == null ? null : _firestore.upcomingSessionsStream(_userId!);

  Stream<List<StudySession>>? get allSessionsStream =>
      _userId == null ? null : _firestore.allSessionsStream(_userId!);

  void setUserId(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _today = [];
    notifyListeners();
    if (userId != null) {
      _firestore.todaySessionsStream(userId).listen((list) {
        _today = list;
        notifyListeners();
      });
    }
  }

  Future<StudySession?> addSession({
    required String courseId,
    required String courseName,
    required String topic,
    required String time,
    required String duration,
    required DateTime date,
    bool urgent = false,
    List<SessionTopic> topics = const [],
  }) async {
    final uid = _userId;
    if (uid == null) return null;
    return _firestore.createSession(
      userId: uid,
      courseId: courseId,
      courseName: courseName,
      topic: topic,
      time: time,
      duration: duration,
      urgent: urgent,
      topics: topics,
      date: date,
    );
  }

  Future<void> updateSession(String id, Map<String, dynamic> patch) {
    return _firestore.updateSession(id, patch);
  }

  Future<void> markComplete({
    required String sessionId,
    required String courseId,
    required double newCourseProgress,
  }) {
    return _firestore.markSessionComplete(
      sessionId: sessionId,
      courseId: courseId,
      newCourseProgress: newCourseProgress,
    );
  }

  /// Delete a session and recompute its course's progress in one go.
  /// Use this from UI delete buttons so progress stays consistent.
  Future<void> deleteSession({
    required String sessionId,
    required String courseId,
  }) async {
    final uid = _userId;
    if (uid == null) return;
    await _firestore.deleteSessionAndRecalc(
      sessionId: sessionId,
      courseId: courseId,
      userId: uid,
    );
  }
}
