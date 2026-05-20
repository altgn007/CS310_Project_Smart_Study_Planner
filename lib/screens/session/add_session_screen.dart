// lib/screens/session/add_session_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/course.dart';
import '../../models/study_session.dart';
import '../../providers/course_provider.dart';
import '../../providers/session_provider.dart';
import '../../utils/app_theme.dart';

/// Add a study session.
///
/// Hierarchy: Course → Unit (course's topic) → Session → Sub-topics.
///
/// Flow:
///   1. pick one of the user's real courses
///   2. pick a unit/topic from that course's `topics`
///   3. (optional) type sub-topics — finer-grained checkboxes shown
///      inside the session. Comma-separated, e.g. "Limits, Derivatives".
///      If left empty, the session falls back to the unit name itself
///      as its single sub-topic so the session screen still has something
///      to tick off.
///   4. pick a study day from that course's `studyDays`
///   5. pick a start time — duration comes from the course's `dailyHours`
class AddSessionScreen extends StatefulWidget {
  static const String routeName = '/add-session';
  const AddSessionScreen({super.key});

  @override
  State<AddSessionScreen> createState() => _AddSessionScreenState();
}

class _AddSessionScreenState extends State<AddSessionScreen> {
  Course? _course;
  String? _topic;
  String? _day;
  TimeOfDay? _startTime;
  bool _saving = false;
  final TextEditingController _subTopicsController = TextEditingController();

  static const _weekdayMap = {
    'Mon': DateTime.monday,
    'Tue': DateTime.tuesday,
    'Wed': DateTime.wednesday,
    'Thu': DateTime.thursday,
    'Fri': DateTime.friday,
    'Sat': DateTime.saturday,
    'Sun': DateTime.sunday,
  };

  @override
  void dispose() {
    _subTopicsController.dispose();
    super.dispose();
  }

  DateTime _nextDateForWeekday(String day) {
    final target = _weekdayMap[day] ?? DateTime.monday;
    final now = DateTime.now();
    var d = DateTime(now.year, now.month, now.day);
    for (int i = 0; i < 7; i++) {
      if (d.weekday == target) return d;
      d = d.add(const Duration(days: 1));
    }
    return d;
  }

  String _durationLabel(double hours) {
    if (hours == hours.roundToDouble()) return '${hours.toInt()}h';
    return '${hours}h';
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 14, minute: 0),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.black),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  /// Parse the comma-separated sub-topics field into a list of
  /// [SessionTopic]s. If the user leaves the field empty, fall back to
  /// the selected unit name so the daily-session screen still has at
  /// least one checkbox.
  List<SessionTopic> _buildSessionTopics() {
    final raw = _subTopicsController.text.trim();
    if (raw.isEmpty) {
      return [SessionTopic(title: _topic ?? 'Study')];
    }
    return raw
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .map((t) => SessionTopic(title: t))
        .toList();
  }

  Future<void> _submit() async {
    final course = _course;
    if (course == null) {
      _snack('Please select a course.');
      return;
    }
    if (_topic == null) {
      _snack('Please select a unit/topic.');
      return;
    }
    if (_day == null) {
      _snack('Please select a study day.');
      return;
    }
    if (_startTime == null) {
      _snack('Please select a start time.');
      return;
    }

    final timeStr =
        '${_startTime!.hour.toString().padLeft(2, '0')}:'
        '${_startTime!.minute.toString().padLeft(2, '0')}';
    final durationStr = _durationLabel(course.dailyHours);
    final date = _nextDateForWeekday(_day!);
    final subTopics = _buildSessionTopics();

    setState(() => _saving = true);
    try {
      final created = await context.read<SessionProvider>().addSession(
        courseId: course.id,
        courseName: course.name,
        topic: _topic!,
        time: timeStr,
        duration: durationStr,
        date: date,
        urgent: course.urgent,
        topics: subTopics,
      );

      if (!mounted) return;

      if (created == null) {
        setState(() => _saving = false);
        _snack('You must be signed in to add a session.');
        return;
      }

      setState(() => _saving = false);
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Session Added!',
            style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w700),
          ),
          content: Text(
            '${course.name} · $_topic\n$_day at $timeStr · $durationStr'
            '${subTopics.length > 1 ? '\n${subTopics.length} sub-topics' : ''}',
            style: const TextStyle(fontFamily: 'Sora'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Done',
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Sora',
                ),
              ),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack('Could not add session: $e');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final coursesStream = context.watch<CourseProvider>().coursesStream;

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
                    child: const Icon(
                      Icons.arrow_back,
                      size: 20,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Add Session', style: AppTextStyles.heading),
                  const SizedBox(height: 4),
                  const Text(
                    'Schedule a study session for one of your courses',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 20),

                  if (coursesStream == null)
                    _hint('Sign in to add a session.')
                  else
                    StreamBuilder<List<Course>>(
                      stream: coursesStream,
                      builder: (context, snap) {
                        final courses = snap.data ?? const <Course>[];
                        if (snap.connectionState == ConnectionState.waiting &&
                            !snap.hasData) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.black,
                              ),
                            ),
                          );
                        }
                        if (courses.isEmpty) {
                          return _hint(
                            'You have no courses yet. Add a course '
                            'first, then schedule sessions for it.',
                          );
                        }
                        if (_course != null &&
                            !courses.any((c) => c.id == _course!.id)) {
                          _course = null;
                          _topic = null;
                          _day = null;
                        }
                        return _buildForm(courses);
                      },
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

  Widget _buildForm(List<Course> courses) {
    final course = _course;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('COURSE'),
        _dropdownBox(
          child: DropdownButton<String>(
            value: course?.id,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            hint: const Text(
              'Select a course',
              style: TextStyle(fontSize: 13, fontFamily: 'Sora'),
            ),
            items: courses
                .map(
                  (c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(
                      c.name,
                      style: const TextStyle(fontSize: 13, fontFamily: 'Sora'),
                    ),
                  ),
                )
                .toList(),
            onChanged: (id) {
              setState(() {
                _course = courses.firstWhere((c) => c.id == id);
                _topic = null;
                _day = null;
              });
            },
          ),
        ),
        const SizedBox(height: 12),

        if (course != null) ...[
          _label('UNIT / TOPIC'),
          if (course.topics.isEmpty)
            _hint('This course has no topics defined.')
          else
            _dropdownBox(
              child: DropdownButton<String>(
                value: _topic,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                hint: const Text(
                  'Select a unit',
                  style: TextStyle(fontSize: 13, fontFamily: 'Sora'),
                ),
                items: course.topics
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(
                          t,
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'Sora',
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _topic = v),
              ),
            ),
          const SizedBox(height: 12),

          _label('SUB-TOPICS (OPTIONAL)'),
          TextField(
            controller: _subTopicsController,
            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'Sora',
              color: AppColors.black,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. Limits, Derivatives, Integrals',
              hintStyle: const TextStyle(
                color: Color(0xFFA0A0A0),
                fontSize: 13,
                fontFamily: 'Sora',
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: AppColors.black),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 4, top: 4),
            child: Text(
              'Separate with commas. Leave empty to use the unit name.',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.mutedText,
                fontFamily: 'Sora',
              ),
            ),
          ),
          const SizedBox(height: 12),

          _label('STUDY DAY'),
          if (course.studyDays.isEmpty)
            _hint('This course has no study days defined.')
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: course.studyDays.map((d) {
                final selected = _day == d;
                return GestureDetector(
                  onTap: () => setState(() => _day = d),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.black : Colors.transparent,
                      border: Border.all(
                        color: selected ? AppColors.black : AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      d,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Sora',
                        color: selected ? Colors.white : AppColors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 12),

          _label('START TIME'),
          GestureDetector(
            onTap: _pickStartTime,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: _startTime == null
                      ? AppColors.border
                      : AppColors.black,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _startTime == null
                          ? 'Select start time'
                          : _startTime!.format(context),
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Sora',
                        color: _startTime == null
                            ? AppColors.hint
                            : AppColors.black,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.labelText,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Duration: ${_durationLabel(course.dailyHours)} '
            '(from this course\'s daily study hours)',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.mutedText,
              fontFamily: 'Sora',
            ),
          ),
          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _saving ? null : _submit,
              style: AppDecorations.primaryButton,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Add Session', style: AppTextStyles.button),
            ),
          ),
        ],
      ],
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(text, style: AppTextStyles.label),
  );

  Widget _dropdownBox({required Widget child}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(28),
    ),
    child: child,
  );

  Widget _hint(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(text, style: AppTextStyles.bodySmall),
  );
}
