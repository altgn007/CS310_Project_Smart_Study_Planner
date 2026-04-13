import 'package:flutter/material.dart';
import '../../data/dummy_users.dart';

class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  static const String routeName = '/coach';

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late List<Map<String, dynamic>> _messages;

  final List<String> _quickReplies = [
    'What should I focus on today?',
    'Am I on track?',
    'Reschedule today',
    'Quiz me',
  ];

  final Map<String, String> _dummyReplies = {
    'What should I focus on today?':
        'Based on your schedule:\n\nPriority 1: Math Ch.5 – Integration (2h)\nPriority 2: Physics – Waves (1h 30m)\n\nSkip Chemistry today — your exam is 16 days away. Math is critical right now.',
    'Am I on track?':
        "You're doing well! You've completed 2 out of 3 sessions this week. Your Math progress is at 55% — keep going and you'll be ready before the exam.",
    'Reschedule today':
        "Got it! I've moved today's Chemistry session to tomorrow and added 30 extra minutes to your Math session. Your updated plan is ready.",
    'Quiz me':
        'Sure! Here\'s a quick question:\n\n∫(2x + 3)dx = ?\n\na) x² + 3x + C\nb) x² + 3 + C\nc) 2x² + 3x + C\n\nReply with a, b, or c!',
  };

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'text': text.trim()});
    });
    _inputController.clear();
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 800), () {
      final reply =
          _dummyReplies[text.trim()] ??
          "That's a great question! I'm still learning to answer that. For now, focus on your highest priority subject — Math Chapter 5.";
      setState(() {
        _messages.add({'role': 'coach', 'text': reply});
      });
      _scrollToBottom();
    });
  }

  @override
  void initState() {
    super.initState();
    final name = DummyUsersRepository.users.isNotEmpty
        ? DummyUsersRepository.users.first.fullName.split(' ').first
        : 'there';
    _messages = [
      {
        'role': 'coach',
        'text':
            "Hey $name! Your Math exam is in 3 days. You still have Chapter 5 (Integration) left. I'd suggest focusing on that today for at least 2 hours. Want me to break it down into topics?",
      },
    ];
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Center(
          child: Container(
            width: 290,
            height: 590,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(34),
              child: Column(
                children: [
                  _buildHeader(),
                  _buildStatsBar(),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        return msg['role'] == 'coach'
                            ? _CoachBubble(text: msg['text'])
                            : _UserBubble(text: msg['text']);
                      },
                    ),
                  ),
                  _buildQuickReplies(),
                  _buildInputBar(),
                  _buildBottomNav(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D0D),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Study Coach',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0D0D0D),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Color(0xFF5BE878),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF5BE878),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.more_horiz, color: Colors.black, size: 18),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      color: const Color(0xFFF7F7F7),
      child: Row(
        children: [
          _statChip(label: 'NEXT EXAM', value: 'Math · Apr 2'),
          const SizedBox(width: 14),
          _statChip(label: 'TODAY', value: '3 sessions'),
          const SizedBox(width: 14),
          _statChip(label: 'DONE', value: '1 / 3'),
        ],
      ),
    );
  }

  Widget _statChip({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0D0D0D),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickReplies() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _quickReplies.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _sendMessage(_quickReplies[index]),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                _quickReplies[index],
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0D0D0D),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(100),
              ),
              child: TextField(
                controller: _inputController,
                style: const TextStyle(fontSize: 11),
                decoration: const InputDecoration(
                  hintText: 'Ask your coach anything...',
                  hintStyle: TextStyle(color: Color(0xFFB0B0B0), fontSize: 11),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                onSubmitted: _sendMessage,
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _sendMessage(_inputController.text),
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFF0D0D0D),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 52,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_outlined,
            label: 'Home',
            selected: false,
            onTap: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            ),
          ),
          _NavItem(
            icon: Icons.calendar_today_outlined,
            label: 'Schedule',
            selected: false,
            onTap: () => Navigator.pushNamed(context, '/schedule'),
          ),
          _NavItem(
            icon: Icons.chat_bubble_outline,
            label: 'Coach',
            selected: true,
            onTap: () => Navigator.pushNamed(context, '/schedule'),
          ),
          _NavItem(
            icon: Icons.person_outline,
            label: 'Profile',
            selected: false,
            onTap: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
    );
  }
}

class _CoachBubble extends StatelessWidget {
  final String text;
  const _CoachBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D0D),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
              size: 12,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFF2F2F2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.5,
                  color: Color(0xFF0D0D0D),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  final String text;
  const _UserBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF0D0D0D),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.5,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: selected ? Colors.black : const Color(0xFFB0B0B0),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected ? Colors.black : const Color(0xFFB0B0B0),
            ),
          ),
        ],
      ),
    );
  }
}
