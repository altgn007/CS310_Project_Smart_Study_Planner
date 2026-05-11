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
/// `FirebaseFirestore.instance` directly. That gives us one place to:
///   - shape collection paths (so we can move them later),
///   - convert between domain models and Firestore docs,
///   - apply security-rule-friendly defaults (`createdBy`, `createdAt`).
///
/// All read methods return [Stream]s so the UI can `StreamBuilder` over
/// them and update in real time when Firestore data changes.
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

  /// Create the user-profile document right after Firebase Auth sign-up.
  /// The doc id is the auth uid so security rules can match by it.
  Future<void> createUserProfile(AppUser user) async {
    await _users.doc(user.id).set(user.toFirestore());
  }

  /// One-shot read of a user profile.
  Future<AppUser?> fetchUserProfile(String uid) async {
    final snap = await _users.doc(uid).get();
    if (!snap.exists) return null;
    return AppUser.fromFirestore(snap);
  }

  /// Real-time stream of the user-profile document.
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

  /// Create a new course document. The `id` field on the doc is set to
  /// the auto-generated doc id so we have it client-side too (and so
  /// the spec's "unique id" requirement is satisfied inside the data).
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

  /// All courses for `userId`, freshest exam first. Live stream.
  Stream<List<Course>> coursesStream(String userId) {
    return _courses
        .where('createdBy', isEqualTo: userId)
        .orderBy('examDate')
        .snapshots()
        .map((snap) => snap.docs.map(Course.fromFirestore).toList());
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

  /// Sessions scheduled for *today* (00:00 — 23:59:59) for this user.
  /// Used by the "Today's Goals" card and Schedule screen.
  Stream<List<StudySession>> todaySessionsStream(String userId) {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final dayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _sessions
        .where('createdBy', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(dayEnd))
        .orderBy('date')
        .snapshots()
        .map((snap) => snap.docs.map(StudySession.fromFirestore).toList());
  }

  /// All sessions for a user (used for stats / progress tab).
  Stream<List<StudySession>> allSessionsStream(String userId) {
    return _sessions
        .where('createdBy', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(StudySession.fromFirestore).toList());
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

  Stream<List<AppNotification>> notificationsStream(String userId) {
    return _notifications
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(AppNotification.fromFirestore).toList());
  }

  Future<void> markNotificationRead(String notificationId) {
    return _notifications.doc(notificationId).update({'isRead': true});
  }

  /// Bulk-mark every unread notification of [userId] as read, in one batch
  /// write so we don't fire dozens of individual updates.
  Future<void> markAllNotificationsRead(String userId) async {
    final query = await _notifications
        .where('createdBy', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    if (query.docs.isEmpty) return;
    final batch = _db.batch();
    for (final doc in query.docs) {
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

  /// Append a new chat message (user or assistant) and return the persisted
  /// model. The doc id is the auto-generated reference id.
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

  /// Live stream of the user's chat history, oldest → newest.
  Stream<List<ChatMessage>> chatMessagesStream(String userId) {
    return _chats
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs.map(ChatMessage.fromFirestore).toList());
  }

  /// Delete every chat message owned by `userId` — used by the "Clear chat"
  /// action on the coach screen.
  Future<void> clearChatHistory(String userId) async {
    final query =
        await _chats.where('createdBy', isEqualTo: userId).get();
    if (query.docs.isEmpty) return;
    final batch = _db.batch();
    for (final doc in query.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
