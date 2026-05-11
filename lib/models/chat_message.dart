// lib/models/chat_message.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// A single chat bubble in the AI coach conversation.
///
/// Stored at `chats/{id}` in Firestore. Required fields per spec:
///   - `id`, `createdBy`, `createdAt`.
///
/// `role` mirrors OpenAI's chat-completions API: 'user' or 'assistant'.
/// We keep them as Strings (not an enum) so the model can be sent
/// straight to the OpenAI API without a translation step.
class ChatMessage {
  final String id;
  final String role; // 'user' | 'assistant'
  final String content;
  final String createdBy;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdBy,
    required this.createdAt,
  });

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'role': role,
        'content': content,
        'createdBy': createdBy,
        'createdAt': FieldValue.serverTimestamp(),
      };

  factory ChatMessage.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final ts = data['createdAt'];
    return ChatMessage(
      id: doc.id,
      role: data['role'] as String? ?? 'assistant',
      content: data['content'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }

  /// Shape needed by OpenAI Chat Completions: `{role, content}`.
  Map<String, String> toOpenAIMessage() => {
        'role': role,
        'content': content,
      };
}
