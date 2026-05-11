// lib/providers/notification_provider.dart
import 'package:flutter/foundation.dart';

import '../models/app_notification.dart';
import '../services/firestore_service.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider({required FirestoreService firestoreService})
      : _firestore = firestoreService;

  final FirestoreService _firestore;
  String? _userId;

  List<AppNotification> _items = [];
  List<AppNotification> get items => List.unmodifiable(_items);

  /// Convenience for the bell badge / profile screen.
  int get unreadCount => _items.where((n) => !n.isRead).length;

  Stream<List<AppNotification>>? get notificationsStream =>
      _userId == null ? null : _firestore.notificationsStream(_userId!);

  void setUserId(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _items = [];
    notifyListeners();
    if (userId != null) {
      _firestore.notificationsStream(userId).listen((list) {
        _items = list;
        notifyListeners();
      });
    }
  }

  Future<void> markAsRead(String id) => _firestore.markNotificationRead(id);

  Future<void> markAllAsRead() async {
    final uid = _userId;
    if (uid == null) return;
    await _firestore.markAllNotificationsRead(uid);
  }

  Future<void> create({
    required String emoji,
    required String title,
    required String body,
  }) async {
    final uid = _userId;
    if (uid == null) return;
    await _firestore.createNotification(
      userId: uid,
      emoji: emoji,
      title: title,
      body: body,
    );
  }

  Future<void> delete(String id) => _firestore.deleteNotification(id);
}
