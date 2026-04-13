// lib/screens/session/daily_session_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import 'session_complete_screen.dart';

class DailySessionScreen extends StatefulWidget {
  static const String routeName = '/session';
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
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  int get _doneTopics => _topics.where((t) => t['done'] == true).length;

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

    return PhoneCard(
      child: Column(
        children: [
          const AppStatusBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: AppPadding.screen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 20, color: AppColors.black),
                  ),
                  const SizedBox(height: 12),

                  // Timer block
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'FOCUS SESSION',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: Colors.grey[500],
                            fontFamily: 'Sora',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _timerDisplay,
                          style: const TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                            letterSpacing: -2,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${widget.session['course']} — ${widget.session['topic']}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, color: Colors.grey[500], fontFamily: 'Sora'),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _timerBtn(Icons.stop_rounded, Colors.white24, Colors.white60, _resetTimer),
                            const SizedBox(width: 10),
                            _timerBtn(
                              _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              Colors.white,
                              AppColors.black,
                              _toggleTimer,
                              large: true,
                            ),
                            const SizedBox(width: 10),
                            _timerBtn(Icons.refresh_rounded, Colors.white24, Colors.white60, _resetTimer),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text('SESSION TOPICS', style: AppTextStyles.sectionLabel),
                  const SizedBox(height: 8),
                  ..._topics.asMap().entries.map((e) {
                    final done = e.value['done'] as bool;
                    return GestureDetector(
                      onTap: () => setState(() => _topics[e.key]['done'] = !done),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: done ? AppColors.black : Colors.transparent,
                                border: Border.all(
                                  color: done ? AppColors.black : AppColors.border,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: done
                                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              e.value['title'],
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Sora',
                                color: done ? AppColors.mutedText : AppColors.black,
                                decoration: done ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 14),
                  Text('PROGRESS', style: AppTextStyles.sectionLabel),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.black),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$_doneTopics/${_topics.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _markComplete,
                      style: AppDecorations.primaryButton,
                      child: const Text('Mark Session Complete', style: AppTextStyles.button),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timerBtn(IconData icon, Color bg, Color iconColor, VoidCallback onTap, {bool large = false}) {
    final size = large ? 44.0 : 36.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: large ? 22 : 17),
      ),
    );
  }
}