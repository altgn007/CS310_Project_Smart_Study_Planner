// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_notification.dart';
import '../models/app_user.dart';
import '../models/chat_message.dart';
import '../models/course.dart';
import '../models/study_session.dart';

/// Single repository that mediates ALL Firestore access in the app.
///
/// Every read query uses ONLY a single `where('createdBy', isEqualTo: uid)`
/// filter — no composite index required. Extra filtering/sorting is done
/// client-side.
class FirestoreService {
  FirestoreService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _courses =>
      _db.collection('courses');
  CollectionReference<Map<String, dynamic>> get _sessions =>
      _db.collection('sessions');
  CollectionReference<Map<String, dynamic>> get _notifications =>
      _db.collection('notifications');
  CollectionReference<Map<String, dynamic>> get _chats =>
      _db.collection('chats');

  // ════════════════════════════════════════════════════════════════════
  // USERS
  // ════════════════════════════════════════════════════════════════════

  Future<void> createUserProfile(AppUser user) async {
    await _users.doc(user.id).set(user.toFirestore());
  }

  Future<AppUser?> fetchUserProfile(String uid) async {
    final snap = await _users.doc(uid).get();
    if (!snap.exists) return null;
    return AppUser.fromFirestore(snap);
  }

  Stream<AppUser?> userProfileStream(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromFirestore(doc);
    });
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> patch) {
    return _users.doc(uid).update(patch);
  }

  // ════════════════════════════════════════════════════════════════════
  // COURSES
  // ════════════════════════════════════════════════════════════════════

  Future<Course> createCourse({
    required String userId,
    required String name,
    required DateTime examDate,
    required String priority,
    required List<String> topics,
    required double dailyHours,
    required List<String> studyDays,
  }) async {
    final docRef = _courses.doc();
    final course = Course(
      id: docRef.id,
      name: name,
      examDate: examDate,
      priority: priority,
      topics: topics,
      dailyHours: dailyHours,
      studyDays: studyDays,
      progress: 0.0,
      createdBy: userId,
      createdAt: DateTime.now(),
    );
    await docRef.set(course.toFirestore());
    return course;
  }

  Stream<List<Course>> coursesStream(String userId) {
    return _courses.where('createdBy', isEqualTo: userId).snapshots().map((
      snap,
    ) {
      final list = snap.docs.map(Course.fromFirestore).toList();
      list.sort((a, b) => a.examDate.compareTo(b.examDate));
      return list;
    });
  }

  Future<void> updateCourse(String courseId, Map<String, dynamic> patch) {
    return _courses.doc(courseId).update(patch);
  }

  /// Delete a course AND every session that belonged to it.
  ///
  /// We use a batched write so all deletes either succeed or fail
  /// together — nothing ends up half-cleaned. Without this, deleting
  /// a course leaves orphan sessions in the Schedule referring to a
  /// course that no longer exists.
  Future<void> deleteCourse(String courseId) async {
    final batch = _db.batch();

    // Collect every session belonging to this course.
    final sessions = await _sessions
        .where('courseId', isEqualTo: courseId)
        .get();
    for (final doc in sessions.docs) {
      batch.delete(doc.reference);
    }

    // Finally delete the course itself.
    batch.delete(_courses.doc(courseId));

    await batch.commit();
  }

  // ════════════════════════════════════════════════════════════════════
  // SESSIONS
  // ════════════════════════════════════════════════════════════════════

  Future<StudySession> createSession({
    required String userId,
    required String courseId,
    required String courseName,
    required String topic,
    required String time,
    required String duration,
    required DateTime date,
    bool urgent = false,
    List<SessionTopic> topics = const [],
  }) async {
    final docRef = _sessions.doc();
    final session = StudySession(
      id: docRef.id,
      courseId: courseId,
      courseName: courseName,
      topic: topic,
      time: time,
      duration: duration,
      urgent: urgent,
      done: false,
      topics: topics,
      date: date,
      createdBy: userId,
      createdAt: DateTime.now(),
    );
    await docRef.set(session.toFirestore());
    return session;
  }

  /// Today's sessions only (00:00 — 23:59:59).
  Stream<List<StudySession>> todaySessionsStream(String userId) {
    return _sessions.where('createdBy', isEqualTo: userId).snapshots().map((
      snap,
    ) {
      final now = DateTime.now();
      final dayStart = DateTime(now.year, now.month, now.day);
      final dayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final list = snap.docs
          .map(StudySession.fromFirestore)
          .where((s) => !s.date.isBefore(dayStart) && !s.date.isAfter(dayEnd))
          .toList();
      list.sort((a, b) => a.date.compareTo(b.date));
      return list;
    });
  }

  /// Today + future sessions, sorted ascending. Used by Schedule screen.
  Stream<List<StudySession>> upcomingSessionsStream(String userId) {
    return _sessions.where('createdBy', isEqualTo: userId).snapshots().map((
      snap,
    ) {
      final now = DateTime.now();
      final dayStart = DateTime(now.year, now.month, now.day);

      final list = snap.docs
          .map(StudySession.fromFirestore)
          .where((s) => !s.date.isBefore(dayStart))
          .toList();
      list.sort((a, b) => a.date.compareTo(b.date));
      return list;
    });
  }

  /// All sessions for the user, newest first.
  Stream<List<StudySession>> allSessionsStream(String userId) {
    return _sessions.where('createdBy', isEqualTo: userId).snapshots().map((
      snap,
    ) {
      final list = snap.docs.map(StudySession.fromFirestore).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  Future<void> updateSession(String sessionId, Map<String, dynamic> patch) {
    return _sessions.doc(sessionId).update(patch);
  }

  Future<void> markSessionComplete({
    required String sessionId,
    required String courseId,
    required double newCourseProgress,
  }) async {
    await _db.runTransaction((tx) async {
      tx.update(_sessions.doc(sessionId), {'done': true});
      tx.update(_courses.doc(courseId), {'progress': newCourseProgress});
    });
  }

  /// Delete a single session AND recompute its course's progress.
  ///
  /// Progress = (remaining done sessions for that course) / (course topics).
  /// We read the parent course's topic count, count the remaining done
  /// sessions for it, then write the new progress in one batched op so
  /// the UI sees a consistent state.
  Future<void> deleteSessionAndRecalc({
    required String sessionId,
    required String courseId,
    required String userId,
  }) async {
    // Look up the parent course (we need its topic count).
    final courseSnap = await _courses.doc(courseId).get();
    final courseTopics = (courseSnap.data()?['topics'] as List?) ?? const [];
    final totalTopics = courseTopics.isEmpty ? 1 : courseTopics.length;

    // Count remaining DONE sessions for this course AFTER deletion.
    final all = await _sessions.where('createdBy', isEqualTo: userId).get();
    final remainingDone = all.docs.where((d) {
      final m = d.data();
      return d.id != sessionId &&
          m['courseId'] == courseId &&
          (m['done'] as bool? ?? false) == true;
    }).length;

    final newProgress = (remainingDone / totalTopics).clamp(0.0, 1.0);

    final batch = _db.batch();
    batch.delete(_sessions.doc(sessionId));
    // Only patch the course if it still exists (avoid resurrecting it
    // if the user deleted both at once).
    if (courseSnap.exists) {
      batch.update(_courses.doc(courseId), {'progress': newProgress});
    }
    await batch.commit();
  }

  /// Plain session delete WITHOUT progress recalc. Kept for callers that
  /// don't need it (none right now, but useful for cascade flows).
  Future<void> deleteSession(String sessionId) {
    return _sessions.doc(sessionId).delete();
  }

  // ════════════════════════════════════════════════════════════════════
  // NOTIFICATIONS
  // ════════════════════════════════════════════════════════════════════

  Future<AppNotification> createNotification({
    required String userId,
    required String emoji,
    required String title,
    required String body,
  }) async {
    final docRef = _notifications.doc();
    final notif = AppNotification(
      id: docRef.id,
      emoji: emoji,
      title: title,
      body: body,
      isRead: false,
      createdBy: userId,
      createdAt: DateTime.now(),
    );
    await docRef.set(notif.toFirestore());
    return notif;
  }

  Stream<List<AppNotification>> notificationsStream(String userId) {
    return _notifications.where('createdBy', isEqualTo: userId).snapshots().map(
      (snap) {
        final list = snap.docs.map(AppNotification.fromFirestore).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      },
    );
  }

  Future<void> markNotificationRead(String notificationId) {
    return _notifications.doc(notificationId).update({'isRead': true});
  }

  Future<void> markAllNotificationsRead(String userId) async {
    final query = await _notifications
        .where('createdBy', isEqualTo: userId)
        .get();
    final unread = query.docs
        .where((d) => (d.data()['isRead'] as bool? ?? false) == false)
        .toList();
    if (unread.isEmpty) return;
    final batch = _db.batch();
    for (final doc in unread) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> deleteNotification(String notificationId) {
    return _notifications.doc(notificationId).delete();
  }

  // ════════════════════════════════════════════════════════════════════
  // CHATS
  // ════════════════════════════════════════════════════════════════════

  Future<ChatMessage> createChatMessage({
    required String userId,
    required String role,
    required String content,
  }) async {
    final docRef = _chats.doc();
    final msg = ChatMessage(
      id: docRef.id,
      role: role,
      content: content,
      createdBy: userId,
      createdAt: DateTime.now(),
    );
    await docRef.set(msg.toFirestore());
    return msg;
  }

  Stream<List<ChatMessage>> chatMessagesStream(String userId) {
    return _chats.where('createdBy', isEqualTo: userId).snapshots().map((snap) {
      final list = snap.docs.map(ChatMessage.fromFirestore).toList();
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    });
  }

  Future<void> clearChatHistory(String userId) async {
    final query = await _chats.where('createdBy', isEqualTo: userId).get();
    if (query.docs.isEmpty) return;
    final batch = _db.batch();
    for (final doc in query.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
