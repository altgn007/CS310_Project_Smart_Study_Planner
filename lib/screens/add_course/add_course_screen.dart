// lib/screens/add_course_screen.dart
import 'package:flutter/material.dart';
import '../home/home_dashboard.dart';
import '../../data/mock_data.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
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
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF0D0D0D)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _examDate = picked);
  }

  @override
  Widget build(BuildContext context) {
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
                    const SizedBox(height: 16),
                    const Text(
                      'Add Course',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: Color(0xFF0D0D0D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "We'll build your study plan automatically",
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),

                    _label('Course Name'),
                    _textField(_courseController, 'e.g. Mathematics'),

                    _label('Exam Date'),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _examDate == null
                                    ? 'Select date'
                                    : '${_examDate!.day}/${_examDate!.month}/${_examDate!.year}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _examDate == null ? Colors.grey[400] : const Color(0xFF0D0D0D),
                                ),
                              ),
                            ),
                            const Text('📅', style: TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                    ),

                    _label('Priority Level'),
                    Row(
                      children: ['High', 'Medium', 'Low'].map((p) {
                        final selected = _selectedPriority == p;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPriority = p),
                            child: Container(
                              margin: EdgeInsets.only(
                                right: p == 'Low' ? 0 : 8,
                                bottom: 16,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selected ? const Color(0xFF0D0D0D) : Colors.transparent,
                                border: Border.all(
                                  color: selected ? const Color(0xFF0D0D0D) : const Color(0xFFE0E0E0),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                p,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: selected ? Colors.white : const Color(0xFF0D0D0D),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    _label('Topics / Chapters'),
                    _textField(_topicsController, 'e.g. Chapter 1, Chapter 2...'),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14, top: -8),
                      child: Text(
                        'Separate topics with commas',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),

                    _label('Daily Study Hours Available'),
                    Slider(
                      value: _dailyHours,
                      min: 0.5,
                      max: 6.0,
                      divisions: 11,
                      activeColor: const Color(0xFF0D0D0D),
                      inactiveColor: const Color(0xFFE0E0E0),
                      onChanged: (v) => setState(() => _dailyHours = v),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('0.5h', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          Text(
                            '${_dailyHours.toStringAsFixed(1)}h',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          Text('6h', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),

                    _label('Study Days'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _allDays.map((day) {
                        final selected = _selectedDays.contains(day);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (selected) {
                                _selectedDays.remove(day);
                              } else {
                                _selectedDays.add(day);
                              }
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: selected ? const Color(0xFF0D0D0D) : Colors.transparent,
                              border: Border.all(
                                color: selected ? const Color(0xFF0D0D0D) : const Color(0xFFE0E0E0),
                                width: 1.5,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                day.substring(0, 1),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: selected ? Colors.white : const Color(0xFF0D0D0D),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Save to Firebase
                          // For now navigate back to home
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const HomeDashboard()),
                            (route) => false,
                          );
                        },
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
                          'Generate Study Plan',
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

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.08 * 11,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _textField(TextEditingController controller, String hint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14, color: Color(0xFF0D0D0D)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: const BorderSide(color: Color(0xFF0D0D0D), width: 1.5),
          ),
        ),
      ),
    );
  }
}