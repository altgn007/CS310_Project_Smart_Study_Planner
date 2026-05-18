// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_notification.dart';
import '../models/app_user.dart';
import '../models/chat_message.dart';
import '../models/course.dart';
import '../models/study_session.dart';

/// Single repository that mediates ALL Firestore access in the app.
///
/// Every screen / provider goes through this service rather than touching
/// `FirebaseFirestore.instance` directly.
///
/// IMPORTANT (the fix): every read query now uses ONLY a single
/// `where('createdBy', isEqualTo: userId)` filter — which Firestore indexes
/// automatically — and performs all ordering / extra filtering CLIENT-SIDE
/// in Dart. The previous code combined `where(...)` with `orderBy(...)` on a
/// different field, which requires a manually-created composite index;
/// without it Firestore throws and the UI showed "Could not load ...".
/// Sorting in Dart removes that external setup requirement entirely.
class FirestoreService {
  FirestoreService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // ── Collection refs (typed) ─────────────────────────────────────────
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
  // COURSES — full CRUD + real-time stream
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

  /// All courses for `userId`, soonest exam first. Live stream.
  /// Single-field filter only → no composite index required.
  /// Ordering by `examDate` is done client-side.
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

  Future<void> deleteCourse(String courseId) {
    return _courses.doc(courseId).delete();
  }

  // ════════════════════════════════════════════════════════════════════
  // SESSIONS — full CRUD + real-time stream
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

  /// Sessions scheduled for *today* for this user.
  /// Single-field Firestore filter; the day-range filter + sort are done
  /// client-side so no composite index is needed.
  Stream<List<StudySession>> todaySessionsStream(String userId) {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final dayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _sessions.where('createdBy', isEqualTo: userId).snapshots().map((
      snap,
    ) {
      final list = snap.docs
          .map(StudySession.fromFirestore)
          .where((s) => !s.date.isBefore(dayStart) && !s.date.isAfter(dayEnd))
          .toList();
      list.sort((a, b) => a.date.compareTo(b.date));
      return list;
    });
  }

  /// All sessions for a user (used for stats / progress), newest first.
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

  /// Mark a session as completed and bump the parent course's progress.
  /// Wrapped in a transaction so the two updates are atomic.
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

  Future<void> deleteSession(String sessionId) {
    return _sessions.doc(sessionId).delete();
  }

  // ════════════════════════════════════════════════════════════════════
  // NOTIFICATIONS — full CRUD + real-time stream
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

  /// Newest first — sorted client-side, no composite index needed.
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

  /// Bulk-mark every unread notification as read. We query by the single
  /// `createdBy` field and filter `isRead == false` in Dart (two equality
  /// filters would otherwise need a composite index).
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
  // CHATS (AI Coach conversation history)
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

  /// Live chat history, oldest → newest (sorted client-side).
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
