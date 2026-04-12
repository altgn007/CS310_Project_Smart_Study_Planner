// lib/mock_data.dart
// Replace these with real Firebase calls later — UI code stays the same

const String mockUserName = 'Alex';
const int mockStreak = 27;
const double mockWeeklyHours = 12.0;

final List<Map<String, dynamic>> mockCourses = [
  {
    'name': 'Mathematics',
    'examDate': 'Apr 2',
    'daysLeft': 3,
    'progress': 0.40,
    'urgent': true,
    'topics': ['Chapter 4 – Derivatives', 'Chapter 5 – Integration', 'Chapter 6 – Applications'],
  },
  {
    'name': 'Physics',
    'examDate': 'Apr 8',
    'daysLeft': 9,
    'progress': 0.65,
    'urgent': false,
    'topics': ['Waves – Frequency & Period', 'Waves – Amplitude', 'Optics – Reflection'],
  },
  {
    'name': 'Chemistry',
    'examDate': 'Apr 15',
    'daysLeft': 16,
    'progress': 0.20,
    'urgent': false,
    'topics': ['Gases – Ideal Gas Law', 'Gases – Real Gas', 'Thermodynamics'],
  },
];

final List<Map<String, dynamic>> mockTodaySessions = [
  {
    'course': 'Mathematics',
    'topic': 'Chapter 5 – Integration',
    'time': '14:00',
    'duration': '2h',
    'urgent': true,
    'done': false,
    'topics': [
      {'title': 'Indefinite Integrals', 'done': true},
      {'title': 'Substitution Rule', 'done': true},
      {'title': 'Definite Integrals', 'done': false},
      {'title': 'Integration by Parts', 'done': false},
      {'title': 'Applications of Integration', 'done': false},
    ],
  },
  {
    'course': 'Physics',
    'topic': 'Waves – Frequency & Period',
    'time': '17:00',
    'duration': '1h 30m',
    'urgent': false,
    'done': false,
    'topics': [
      {'title': 'Wave properties', 'done': false},
      {'title': 'Frequency calculations', 'done': false},
      {'title': 'Period and wavelength', 'done': false},
    ],
  },
  {
    'course': 'Chemistry',
    'topic': 'Gases – Ideal Gas Law',
    'time': '19:00',
    'duration': '2h',
    'urgent': false,
    'done': false,
    'topics': [
      {'title': 'PV = nRT derivation', 'done': false},
      {'title': 'Solving gas problems', 'done': false},
      {'title': 'Molar volume', 'done': false},
    ],
  },
];