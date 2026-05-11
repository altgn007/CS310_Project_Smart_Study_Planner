// lib/models/course.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// A user-owned course (e.g. "Mathematics") with an upcoming exam.
///
/// Stored at `courses/{id}` in Firestore. Required fields per spec:
///   - `id`         → unique document id
///   - `createdBy`  → uid of the user who owns this course
///   - `createdAt`  → server timestamp
class Course {
  final String id;
  final String name;
  final DateTime examDate;
  final String priority; // 'High' | 'Medium' | 'Low'
  final List<String> topics;
  final double dailyHours;
  final List<String> studyDays;
  final double progress; // 0.0 — 1.0
  final String createdBy;
  final DateTime createdAt;

  const Course({
    required this.id,
    required this.name,
    required this.examDate,
    this.priority = 'Medium',
    required this.topics,
    this.dailyHours = 2.0,
    this.studyDays = const ['Mon', 'Tue', 'Thu', 'Fri'],
    this.progress = 0.0,
    required this.createdBy,
    required this.createdAt,
  });

  // ── Derived display fields used by the UI ────────────────────────────
  String get examDateLabel => DateFormat('MMM d').format(examDate);

  int get daysLeft {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final exam = DateTime(examDate.year, examDate.month, examDate.day);
    final diff = exam.difference(today).inDays;
    return diff < 0 ? 0 : diff;
  }

  bool get urgent => daysLeft <= 5;

  Course copyWith({
    String? id,
    String? name,
    DateTime? examDate,
    String? priority,
    List<String>? topics,
    double? dailyHours,
    List<String>? studyDays,
    double? progress,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      examDate: examDate ?? this.examDate,
      priority: priority ?? this.priority,
      topics: topics ?? this.topics,
      dailyHours: dailyHours ?? this.dailyHours,
      studyDays: studyDays ?? this.studyDays,
      progress: progress ?? this.progress,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ── Firestore (de)serialization ──────────────────────────────────────
  Map<String, dynamic> toFirestore() => {
    'id': id,
    'name': name,
    'examDate': Timestamp.fromDate(examDate),
    'priority': priority,
    'topics': topics,
    'dailyHours': dailyHours,
    'studyDays': studyDays,
    'progress': progress,
    'createdBy': createdBy,
    'createdAt': FieldValue.serverTimestamp(),
  };

  factory Course.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final examTs = data['examDate'];
    final createdTs = data['createdAt'];
    return Course(
      id: doc.id,
      name: data['name'] as String? ?? '',
      examDate: examTs is Timestamp ? examTs.toDate() : DateTime.now(),
      priority: data['priority'] as String? ?? 'Medium',
      topics: List<String>.from(data['topics'] as List? ?? const []),
      dailyHours: (data['dailyHours'] as num?)?.toDouble() ?? 2.0,
      studyDays: List<String>.from(data['studyDays'] as List? ?? const []),
      progress: (data['progress'] as num?)?.toDouble() ?? 0.0,
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: createdTs is Timestamp ? createdTs.toDate() : DateTime.now(),
    );
  }
}
