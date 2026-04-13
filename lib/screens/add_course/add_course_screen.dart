// lib/screens/add_course/add_course_screen.dart
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class AddCourseScreen extends StatefulWidget {
  static const String routeName = '/add-course';
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _courseController = TextEditingController();
  final _topicsController = TextEditingController();
  String _selectedPriority = 'High';
  double _dailyHours = 2.0;
  DateTime? _examDate;
  final List<String> _selectedDays = ['Mon', 'Tue', 'Thu', 'Fri'];
  final List<String> _allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void dispose() {
    _courseController.dispose();
    _topicsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.black),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _examDate = picked);
  }

  void _submit() {
    // Validate exam date separately
    if (_examDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an exam date.')),
      );
      return;
    }
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one study day.')),
      );
      return;
    }

    // Validate form fields
    if (!_formKey.currentState!.validate()) return;

    // Success — show AlertDialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Course Added!',
          style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w700),
        ),
        content: Text(
          '"${_courseController.text.trim()}" has been added. Your study plan will be generated automatically.',
          style: const TextStyle(fontFamily: 'Sora'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // back to home
            },
            child: const Text(
              'Go to Home',
              style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w700, fontFamily: 'Sora'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PhoneCard(
      child: Column(
        children: [
          const AppStatusBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: AppPadding.screen,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, size: 20, color: AppColors.black),
                    ),
                    const SizedBox(height: 14),
                    const Text('Add Course', style: AppTextStyles.heading),
                    const SizedBox(height: 4),
                    const Text(
                      "We'll build your study plan automatically",
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 20),

                    // Course Name — with validation
                    _label('COURSE NAME'),
                    TextFormField(
                      controller: _courseController,
                      style: const TextStyle(fontSize: 13, fontFamily: 'Sora'),
                      decoration: AppDecorations.inputField(hintText: 'e.g. Mathematics'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please enter a course name.';
                        if (v.trim().length < 2) return 'Course name must be at least 2 characters.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Exam Date
                    _label('EXAM DATE'),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: _examDate == null ? AppColors.border : AppColors.black,
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _examDate == null
                                    ? 'Select date'
                                    : '${_examDate!.day.toString().padLeft(2, '0')}/${_examDate!.month.toString().padLeft(2, '0')}/${_examDate!.year}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Sora',
                                  color: _examDate == null ? AppColors.hint : AppColors.black,
                                ),
                              ),
                            ),
                            const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.labelText),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Priority
                    _label('PRIORITY LEVEL'),
                    Row(
                      children: ['High', 'Medium', 'Low'].map((p) {
                        final selected = _selectedPriority == p;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPriority = p),
                            child: Container(
                              margin: EdgeInsets.only(right: p == 'Low' ? 0 : 8),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selected ? AppColors.black : Colors.transparent,
                                border: Border.all(
                                  color: selected ? AppColors.black : AppColors.border,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                p,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Sora',
                                  color: selected ? Colors.white : AppColors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Topics — with validation
                    _label('TOPICS / CHAPTERS'),
                    TextFormField(
                      controller: _topicsController,
                      style: const TextStyle(fontSize: 13, fontFamily: 'Sora'),
                      decoration: AppDecorations.inputField(hintText: 'e.g. Chapter 1, Chapter 2...'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please enter at least one topic.';
                        return null;
                      },
                    ),
                    const Text(
                      'Separate topics with commas',
                      style: TextStyle(fontSize: 10, color: AppColors.mutedText, fontFamily: 'Sora'),
                    ),
                    const SizedBox(height: 12),

                    // Daily hours slider
                    _label('DAILY STUDY HOURS'),
                    Slider(
                      value: _dailyHours,
                      min: 0.5,
                      max: 6.0,
                      divisions: 11,
                      activeColor: AppColors.black,
                      inactiveColor: AppColors.border,
                      onChanged: (v) => setState(() => _dailyHours = v),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('0.5h', style: TextStyle(fontSize: 10, color: AppColors.mutedText, fontFamily: 'Sora')),
                        Text(
                          '${_dailyHours.toStringAsFixed(1)}h',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Sora'),
                        ),
                        const Text('6h', style: TextStyle(fontSize: 10, color: AppColors.mutedText, fontFamily: 'Sora')),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Study days
                    _label('STUDY DAYS'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _allDays.map((day) {
                        final selected = _selectedDays.contains(day);
                        return GestureDetector(
                          onTap: () => setState(() {
                            selected ? _selectedDays.remove(day) : _selectedDays.add(day);
                          }),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: selected ? AppColors.black : Colors.transparent,
                              border: Border.all(
                                color: selected ? AppColors.black : AppColors.border,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                day[0],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Sora',
                                  color: selected ? Colors.white : AppColors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: AppDecorations.primaryButton,
                        child: const Text('Generate Study Plan', style: AppTextStyles.button),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text, style: AppTextStyles.label),
    );
  }
}