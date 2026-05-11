// lib/providers/chat_provider.dart
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import '../models/course.dart';
import '../models/study_session.dart';
import '../services/ai_service.dart';
import '../services/firestore_service.dart';

/// Owns the AI coach conversation: streams the chat history from Firestore,
/// and orchestrates the "send a message → call OpenAI → save reply" flow.
///
/// The provider keeps two pieces of UI-visible state on top of the stream:
///   - [isReplying]   → spinner under the input bar while waiting for AI
///   - [lastErrorMessage] → user-friendly error string if a call failed
class ChatProvider extends ChangeNotifier {
  ChatProvider({
    required FirestoreService firestoreService,
    required AiService aiService,
  }) : _firestore = firestoreService,
       _ai = aiService;

  final FirestoreService _firestore;
  final AiService _ai;

  String? _userId;
  List<ChatMessage> _messages = [];
  StreamSubscription<List<ChatMessage>>? _sub;

  bool _isReplying = false;
  String? _lastErrorMessage;

  // ── Public state ────────────────────────────────────────────────────
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isReplying => _isReplying;
  String? get lastErrorMessage => _lastErrorMessage;
  bool get isAiConfigured => _ai.isConfigured;

  Stream<List<ChatMessage>>? get messagesStream =>
      _userId == null ? null : _firestore.chatMessagesStream(_userId!);

  /// Wire up to a user (called from `main.dart` via ProxyProvider).
  void setUserId(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _messages = [];
    _sub?.cancel();
    _sub = null;

    if (userId != null) {
      _sub = _firestore.chatMessagesStream(userId).listen((list) {
        _messages = list;
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  /// Send a user message. Steps:
  ///   1. Persist the user message to Firestore (the stream picks it up).
  ///   2. Build a system prompt from live user data.
  ///   3. Call OpenAI with the recent history.
  ///   4. Persist the assistant reply (the stream picks that up too).
  Future<void> sendMessage({
    required String userMessage,
    required String userName,
    required List<Course> courses,
    required List<StudySession> todaySessions,
    required List<StudySession> allSessions,
  }) async {
    final uid = _userId;
    if (uid == null) return;
    final trimmed = userMessage.trim();
    if (trimmed.isEmpty) return;

    _lastErrorMessage = null;
    _setReplying(true);

    try {
      // Persist the user message FIRST so it appears in the UI immediately
      // (the Firestore stream listener will pick it up).
      await _firestore.createChatMessage(
        userId: uid,
        role: 'user',
        content: trimmed,
      );

      // Snapshot current history (the user message is included once the
      // stream emits; for the OpenAI call we add it explicitly to avoid a
      // race condition).
      final historyForAi = [
        ..._messages,
        ChatMessage(
          id: 'pending',
          role: 'user',
          content: trimmed,
          createdBy: uid,
          createdAt: DateTime.now(),
        ),
      ];

      final systemPrompt = _ai.buildSystemPrompt(
        userName: userName,
        courses: courses,
        todaySessions: todaySessions,
        allSessions: allSessions,
      );

      final reply = await _ai.chat(
        systemPrompt: systemPrompt,
        history: historyForAi,
      );

      await _firestore.createChatMessage(
        userId: uid,
        role: 'assistant',
        content: reply,
      );
    } on AiException catch (e) {
      _lastErrorMessage = e.message;
      // Surface the error in the chat itself so the user sees it inline.
      await _firestore.createChatMessage(
        userId: uid,
        role: 'assistant',
        content: '⚠️ ${e.message}',
      );
    } catch (e) {
      _lastErrorMessage = 'Something went wrong: $e';
      await _firestore.createChatMessage(
        userId: uid,
        role: 'assistant',
        content: '⚠️ Something went wrong. Please try again.',
      );
    } finally {
      _setReplying(false);
    }
  }

  /// Wipe the conversation. The stream will emit an empty list immediately
  /// after the batch delete commits.
  Future<void> clearHistory() async {
    final uid = _userId;
    if (uid == null) return;
    await _firestore.clearChatHistory(uid);
  }

  void clearError() {
    if (_lastErrorMessage != null) {
      _lastErrorMessage = null;
      notifyListeners();
    }
  }

  void _setReplying(bool v) {
    _isReplying = v;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
