// lib/models/app_notification.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// In-app notification stored at `notifications/{id}`.
///
/// Required fields per spec: `id`, `createdBy`, `createdAt`.
class AppNotification {
  final String id;
  final String emoji;
  final String title;
  final String body;
  final bool isRead;
  final String createdBy;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.emoji,
    required this.title,
    required this.body,
    this.isRead = false,
    required this.createdBy,
    required this.createdAt,
  });

  /// Human-readable relative time, e.g. "Just now", "2h ago", "Yesterday · 8:00 PM".
  String get displayTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    final yest = DateTime(now.year, now.month, now.day - 1);
    final created = DateTime(createdAt.year, createdAt.month, createdAt.day);
    if (created == yest) {
      return 'Yesterday · ${DateFormat('h:mm a').format(createdAt)}';
    }
    return DateFormat('MMM d · h:mm a').format(createdAt);
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      emoji: emoji,
      title: title,
      body: body,
      isRead: isRead ?? this.isRead,
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'emoji': emoji,
        'title': title,
        'body': body,
        'isRead': isRead,
        'createdBy': createdBy,
        'createdAt': FieldValue.serverTimestamp(),
      };

  factory AppNotification.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final createdTs = data['createdAt'];
    return AppNotification(
      id: doc.id,
      emoji: data['emoji'] as String? ?? '🔔',
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      isRead: data['isRead'] as bool? ?? false,
      createdBy: data['createdBy'] as String? ?? '',
      createdAt:
          createdTs is Timestamp ? createdTs.toDate() : DateTime.now(),
    );
  }
}
