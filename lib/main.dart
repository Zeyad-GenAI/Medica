import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_settings.dart';
import 'create_account_screen.dart';
import 'home_screen.dart';
import 'message_screen.dart';
import 'onboarding_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'shared_widgets.dart';
import 'sign_in_screen.dart';
import 'splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings.instance.load();
  runApp(const MedicaApp());
}

class MedicaApp extends StatelessWidget {
  const MedicaApp({super.key});

  ThemeData _lightTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: kPrimaryColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      primaryColor: kPrimaryColor,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: kPrimaryColor,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFF2F2F2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  ThemeData _darkTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: kPrimaryColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      primaryColor: kLightTeal,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: const Color(0xFF101719),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF101719),
        foregroundColor: kLightTeal,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1C292B),
        hintStyle: TextStyle(color: Colors.grey.shade400),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF172124),
        selectedItemColor: kLightTeal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, _) {
        final settings = AppSettings.instance;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Medica',
          theme: _lightTheme(),
          darkTheme: _darkTheme(),
          themeMode: settings.themeMode,
          initialRoute: '/splash',
          routes: {
            '/': (context) => const SplashScreen(),
            '/splash': (context) => const SplashScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/signin': (context) => const SignInScreen(),
            '/create-account': (context) => const CreateAccountScreen(),
            '/home': (context) => const HomeScreen(),
            '/message': (context) => const MessageScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}
