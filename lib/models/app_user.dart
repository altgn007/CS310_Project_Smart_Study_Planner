// lib/models/app_user.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user profile document in `users/{uid}`.
///
/// Includes the requirement-mandated fields:
///   - `id`     → the document id (matches the Firebase Auth uid)
///   - `createdAt` → server timestamp set on first write
///
/// Note: for a user document, `createdBy` and `id` are the same (the user
/// creates their own profile), so we don't duplicate it.
class AppUser {
  final String id; // == Firebase Auth uid
  final String email;
  final String fullName;
  final String? dateOfBirth; // dd/MM/yyyy as string for simple round-tripping
  final String educationLevel;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.dateOfBirth,
    required this.educationLevel,
    required this.createdAt,
  });

  AppUser copyWith({
    String? email,
    String? fullName,
    String? dateOfBirth,
    String? educationLevel,
  }) {
    return AppUser(
      id: id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      educationLevel: educationLevel ?? this.educationLevel,
      createdAt: createdAt,
    );
  }

  /// Convert to a map suitable for `set()` / `update()` on Firestore.
  /// `createdAt` is encoded as a server timestamp on first write so that
  /// the value reflects the server's clock, not the client's.
  Map<String, dynamic> toFirestore() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        'dateOfBirth': dateOfBirth,
        'educationLevel': educationLevel,
        'createdAt': FieldValue.serverTimestamp(),
      };

  /// Build an [AppUser] from a Firestore document snapshot.
  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final ts = data['createdAt'];
    return AppUser(
      id: doc.id,
      email: data['email'] as String? ?? '',
      fullName: data['fullName'] as String? ?? '',
      dateOfBirth: data['dateOfBirth'] as String?,
      educationLevel: data['educationLevel'] as String? ?? 'University',
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }
}
