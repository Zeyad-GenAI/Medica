import 'dart:async';

import 'package:flutter/material.dart';

import 'shared_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();

    _navigationTimer = Timer(
      const Duration(milliseconds: 2200),
      _openOnboarding,
    );
  }

  void _openOnboarding() {
    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/onboarding');
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 118,
                    height: 118,
                    decoration: const BoxDecoration(
                      color: kLightTeal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.volunteer_activism,
                      color: Colors.white,
                      size: 56,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Medica',
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Care that feels closer',
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 14,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 52),
                  SizedBox(
                    width: 42,
                    child: LinearProgressIndicator(
                      minHeight: 4,
                      backgroundColor: kLightTeal.withOpacity(0.25),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        kPrimaryColor,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
