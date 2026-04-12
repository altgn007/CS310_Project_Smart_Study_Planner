// lib/screens/daily_session_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../session/session_complete_screen.dart';

class DailySessionScreen extends StatefulWidget {
  final Map<String, dynamic> session;
  const DailySessionScreen({super.key, required this.session});

  @override
  State<DailySessionScreen> createState() => _DailySessionScreenState();
}

class _DailySessionScreenState extends State<DailySessionScreen> {
  static const int _pomodoroSeconds = 25 * 60;
  int _secondsLeft = _pomodoroSeconds;
  bool _isRunning = false;
  Timer? _timer;
  late List<Map<String, dynamic>> _topics;

  @override
  void initState() {
    super.initState();
    _topics = List<Map<String, dynamic>>.from(
      (widget.session['topics'] as List).map((t) => Map<String, dynamic>.from(t)),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_secondsLeft > 0) {
          setState(() => _secondsLeft--);
        } else {
          _timer?.cancel();
          setState(() => _isRunning = false);
        }
      });
      setState(() => _isRunning = true);
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _secondsLeft = _pomodoroSeconds;
      _isRunning = false;
    });
  }

  String get _timerDisplay {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  int get _doneTopics => _topics.where((t) => t['done'] == true).length;

  void _toggleTopic(int index) {
    setState(() => _topics[index]['done'] = !(_topics[index]['done'] as bool));
  }

  void _markComplete() {
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SessionCompleteScreen(
          session: widget.session,
          topicsDone: _doneTopics,
          totalTopics: _topics.length,
          timeSpentSeconds: _pomodoroSeconds - _secondsLeft,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _topics.isEmpty ? 0.0 : _doneTopics / _topics.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text('←', style: TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(height: 8),

                    // Timer block
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D0D0D),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Text(
                            'FOCUS SESSION',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1 * 11,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _timerDisplay,
                            style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                              letterSpacing: -2,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${widget.session['course']} — ${widget.session['topic']}',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _timerBtn(
                                icon: Icons.stop_rounded,
                                color: Colors.white24,
                                iconColor: Colors.white60,
                                onTap: _resetTimer,
                              ),
                              const SizedBox(width: 12),
                              _timerBtn(
                                icon: _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.white,
                                iconColor: const Color(0xFF0D0D0D),
                                onTap: _toggleTimer,
                                large: true,
                              ),
                              const SizedBox(width: 12),
                              _timerBtn(
                                icon: Icons.refresh_rounded,
                                color: Colors.white24,
                                iconColor: Colors.white60,
                                onTap: _resetTimer,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _sectionTitle('Session Topics'),
                    const SizedBox(height: 8),
                    ..._topics.asMap().entries.map((entry) {
                      final i = entry.key;
                      final topic = entry.value;
                      final done = topic['done'] as bool;
                      return GestureDetector(
                        onTap: () => _toggleTopic(i),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: done ? const Color(0xFF0D0D0D) : Colors.transparent,
                                  border: Border.all(
                                    color: done ? const Color(0xFF0D0D0D) : const Color(0xFFE0E0E0),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: done
                                    ? const Icon(Icons.check, size: 13, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                topic['title'],
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: done ? Colors.grey[400] : const Color(0xFF0D0D0D),
                                  decoration: done ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),
                    _sectionTitle('Session Progress'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: const Color(0xFFE0E0E0),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D0D0D)),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$_doneTopics/${_topics.length}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _markComplete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D0D0D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Mark Session Complete',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.08 * 11,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _timerBtn({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
    bool large = false,
  }) {
    final size = large ? 52.0 : 44.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: large ? 26 : 20),
      ),
    );
  }
}