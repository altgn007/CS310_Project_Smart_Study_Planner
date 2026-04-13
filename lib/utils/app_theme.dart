// lib/utils/app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color black = Color(0xFF0D0D0D);
  static const Color white = Color(0xFFFAFAFA);
  static const Color background = Color(0xFFF3F3F3);
  static const Color cardWhite = Colors.white;
  static const Color border = Color(0xFFE2E2E2);
  static const Color hint = Color(0xFFA0A0A0);
  static const Color mutedText = Color(0xFF8A8A8A);
  static const Color labelText = Color(0xFF7C7C7C);
  static const Color surface = Color(0xFFF7F7F7);
  static const Color urgent = Color(0xFFCC2222);
  static const Color urgentBg = Color(0xFFFFF0F0);
  static const Color green = Color(0xFF5BE878);
  static const Color yellow = Color(0xFFF5C842);
  static const Color orange = Color(0xFFF58C42);
  static const Color divider = Color(0xFFF0F0F0);
  static const Color navInactive = Color(0xFFB0B0B0);
}

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle screenTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.black,
    fontFamily: 'Sora',
  );

  static const TextStyle heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    height: 1.15,
    color: AppColors.black,
    fontFamily: 'Sora',
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
    fontFamily: 'Sora',
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.mutedText,
    fontFamily: 'Sora',
  );

  static const TextStyle label = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: AppColors.labelText,
    fontFamily: 'Sora',
  );

  static const TextStyle sectionLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: AppColors.labelText,
    fontFamily: 'Sora',
  );

  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    fontFamily: 'Sora',
  );

  static const TextStyle navLabel = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w400,
    color: AppColors.navInactive,
    fontFamily: 'Sora',
  );

  static const TextStyle navLabelActive = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
    fontFamily: 'Sora',
  );

  static const TextStyle statusBar = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    fontFamily: 'Sora',
  );
}

class AppPadding {
  AppPadding._();

  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: 18);
  static const EdgeInsets card = EdgeInsets.symmetric(horizontal: 18, vertical: 16);
  static const EdgeInsets inputContent = EdgeInsets.symmetric(horizontal: 18, vertical: 16);
  static const EdgeInsets buttonVertical = EdgeInsets.symmetric(vertical: 14);
}

class AppDecorations {
  AppDecorations._();

  static BoxDecoration phoneCard = BoxDecoration(
    color: AppColors.cardWhite,
    borderRadius: BorderRadius.circular(34),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );

  static InputDecoration inputField({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.hint, fontSize: 13, fontFamily: 'Sora'),
      filled: true,
      fillColor: AppColors.cardWhite,
      contentPadding: AppPadding.inputContent,
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: AppColors.black),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.black,
    foregroundColor: AppColors.cardWhite,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
  );
}

// Shared phone card wrapper — matches teammates' 290×590 style
class PhoneCard extends StatelessWidget {
  final Widget child;
  const PhoneCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Container(
            width: 290,
            height: 590,
            decoration: AppDecorations.phoneCard,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(34),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

// Shared status bar row
class AppStatusBar extends StatelessWidget {
  const AppStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text('9:41', style: AppTextStyles.statusBar),
          Icon(Icons.more_horiz, size: 18, color: AppColors.black),
        ],
      ),
    );
  }
}

// Shared bottom nav bar
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  const AppBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_outlined, 'Home', '/home'),
      (Icons.calendar_today_outlined, 'Schedule', '/schedule'),
      (Icons.chat_bubble_outline, 'Coach', '/coach'),
      (Icons.person_outline, 'Profile', '/profile'),
    ];

    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: AppColors.cardWhite,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final selected = i == currentIndex;
          return GestureDetector(
            onTap: () {
              if (!selected) {
                if (i == 0) {
                  Navigator.pushNamedAndRemoveUntil(context, item.$3, (r) => false);
                } else {
                  Navigator.pushNamed(context, item.$3);
                }
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.$1, size: 20, color: selected ? AppColors.black : AppColors.navInactive),
                const SizedBox(height: 2),
                Text(item.$2, style: selected ? AppTextStyles.navLabelActive : AppTextStyles.navLabel),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}