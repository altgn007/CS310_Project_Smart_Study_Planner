// lib/models/course.dart

class Course {
  final String name;
  final String examDate;
  final int daysLeft;
  final double progress;
  final bool urgent;
  final String priority;
  final List<String> topics;
  final double dailyHours;
  final List<String> studyDays;

  const Course({
    required this.name,
    required this.examDate,
    required this.daysLeft,
    required this.progress,
    required this.urgent,
    this.priority = 'Medium',
    required this.topics,
    this.dailyHours = 2.0,
    this.studyDays = const ['Mon', 'Tue', 'Thu', 'Fri'],
  });

  Course copyWith({
    String? name,
    String? examDate,
    int? daysLeft,
    double? progress,
    bool? urgent,
    String? priority,
    List<String>? topics,
    double? dailyHours,
    List<String>? studyDays,
  }) {
    return Course(
      name: name ?? this.name,
      examDate: examDate ?? this.examDate,
      daysLeft: daysLeft ?? this.daysLeft,
      progress: progress ?? this.progress,
      urgent: urgent ?? this.urgent,
      priority: priority ?? this.priority,
      topics: topics ?? this.topics,
      dailyHours: dailyHours ?? this.dailyHours,
      studyDays: studyDays ?? this.studyDays,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'examDate': examDate,
    'daysLeft': daysLeft,
    'progress': progress,
    'urgent': urgent,
    'priority': priority,
    'topics': topics,
    'dailyHours': dailyHours,
    'studyDays': studyDays,
  };

  factory Course.fromMap(Map<String, dynamic> map) => Course(
    name: map['name'] ?? '',
    examDate: map['examDate'] ?? '',
    daysLeft: map['daysLeft'] ?? 0,
    progress: (map['progress'] ?? 0.0).toDouble(),
    urgent: map['urgent'] ?? false,
    priority: map['priority'] ?? 'Medium',
    topics: List<String>.from(map['topics'] ?? []),
    dailyHours: (map['dailyHours'] ?? 2.0).toDouble(),
    studyDays: List<String>.from(map['studyDays'] ?? []),
  );
}