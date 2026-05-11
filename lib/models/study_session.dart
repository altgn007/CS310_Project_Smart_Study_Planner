// lib/models/study_session.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// A single sub-topic checkbox inside a session ("Indefinite Integrals", done).
class SessionTopic {
  final String title;
  final bool done;

  const SessionTopic({required this.title, this.done = false});

  SessionTopic copyWith({String? title, bool? done}) =>
      SessionTopic(title: title ?? this.title, done: done ?? this.done);

  Map<String, dynamic> toMap() => {'title': title, 'done': done};

  factory SessionTopic.fromMap(Map<String, dynamic> m) =>
      SessionTopic(title: m['title'] as String? ?? '', done: m['done'] as bool? ?? false);
}

/// A scheduled study session belonging to a course (e.g. "Math, Ch.5, 14:00, 2h").
///
/// Stored at `sessions/{id}` in Firestore. Required fields per spec:
///   - `id`, `createdBy`, `createdAt`.
class StudySession {
  final String id;
  final String courseId;
  final String courseName;
  final String topic;
  final String time;        // e.g. "14:00"
  final String duration;    // e.g. "2h"
  final bool urgent;
  final bool done;
  final List<SessionTopic> topics;
  final DateTime date;      // the day this session is scheduled for
  final String createdBy;
  final DateTime createdAt;

  const StudySession({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.topic,
    required this.time,
    required this.duration,
    this.urgent = false,
    this.done = false,
    this.topics = const [],
    required this.date,
    required this.createdBy,
    required this.createdAt,
  });

  StudySession copyWith({
    String? id,
    String? courseId,
    String? courseName,
    String? topic,
    String? time,
    String? duration,
    bool? urgent,
    bool? done,
    List<SessionTopic>? topics,
    DateTime? date,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return StudySession(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      topic: topic ?? this.topic,
      time: time ?? this.time,
      duration: duration ?? this.duration,
      urgent: urgent ?? this.urgent,
      done: done ?? this.done,
      topics: topics ?? this.topics,
      date: date ?? this.date,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'courseId': courseId,
        'courseName': courseName,
        'topic': topic,
        'time': time,
        'duration': duration,
        'urgent': urgent,
        'done': done,
        'topics': topics.map((t) => t.toMap()).toList(),
        'date': Timestamp.fromDate(date),
        'createdBy': createdBy,
        'createdAt': FieldValue.serverTimestamp(),
      };

  factory StudySession.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final dateTs = data['date'];
    final createdTs = data['createdAt'];
    return StudySession(
      id: doc.id,
      courseId: data['courseId'] as String? ?? '',
      courseName: data['courseName'] as String? ?? '',
      topic: data['topic'] as String? ?? '',
      time: data['time'] as String? ?? '',
      duration: data['duration'] as String? ?? '',
      urgent: data['urgent'] as bool? ?? false,
      done: data['done'] as bool? ?? false,
      topics: ((data['topics'] as List?) ?? const [])
          .whereType<Map>()
          .map((m) => SessionTopic.fromMap(Map<String, dynamic>.from(m)))
          .toList(),
      date: dateTs is Timestamp ? dateTs.toDate() : DateTime.now(),
      createdBy: data['createdBy'] as String? ?? '',
      createdAt:
          createdTs is Timestamp ? createdTs.toDate() : DateTime.now(),
    );
  }
}
