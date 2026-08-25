import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xFF12879A);
const Color kLightTeal = Color(0xFF7FC8BD);

InputDecoration appInputDecoration(
    BuildContext context,
    String hint, {
      Widget? suffixIcon,
      Widget? prefixIcon,
    }) {
  final theme = Theme.of(context);

  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      color: theme.colorScheme.onSurface.withOpacity(0.45),
    ),
    filled: true,
    fillColor: theme.inputDecorationTheme.fillColor ??
        theme.colorScheme.surfaceContainerHighest,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 16,
    ),
  );
}

Widget socialIconButton(IconData icon, Color color) {
  return Builder(
    builder: (context) {
      final theme = Theme.of(context);
      return Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                theme.brightness == Brightness.dark ? 0.35 : 0.10,
              ),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(icon, color: color),
      );
    },
  );
}

Widget appBottomNav(BuildContext context, int currentIndex) {
  final theme = Theme.of(context);

  return BottomNavigationBar(
    currentIndex: currentIndex,
    backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
    selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor ??
        theme.colorScheme.primary,
    unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor ??
        theme.colorScheme.onSurface.withOpacity(0.55),
    showSelectedLabels: false,
    showUnselectedLabels: false,
    type: BottomNavigationBarType.fixed,
    onTap: (index) {
      switch (index) {
        case 0:
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          break;
        case 1:
          Navigator.pushNamed(context, '/message');
          break;
        case 2:
          Navigator.pushNamed(context, '/profile');
          break;
      }
    },
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.chat_bubble_outline),
        label: 'Chat',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        label: 'Profile',
      ),
    ],
  );
}
