import 'package:flutter/material.dart';

import 'shared_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingData> _pages = [
    _OnboardingData(
      imageAsset: 'assets/images/medica_onboarding_health_network.png',
      title: 'Your health,\njust a tap away',
      description:
      'Easily book appointments with trusted doctors and manage your care from one place.',
    ),
    _OnboardingData(
      imageAsset: 'assets/images/medica_onboarding_doctors.png',
      title: 'Find the right doctor\nwith confidence',
      description:
      'Explore trusted healthcare professionals and choose the care that fits your needs.',
    ),
    _OnboardingData(
      imageAsset: 'assets/images/medica_onboarding_organize_care.png',
      title: 'Stay organized and\nin control',
      description:
      'Keep appointments, prescriptions, reminders, and your health journey in one place.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, '/signin');
  }

  Future<void> _continue() async {
    if (_currentPage == _pages.length - 1) {
      _skip();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _skip,
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                  ),
                  label: const Text('Skip'),
                  iconAlignment: IconAlignment.end,
                  style: TextButton.styleFrom(
                    foregroundColor: kPrimaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return _ReferenceStyleOnboardingPage(
                    data: _pages[index],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 30),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                          (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: index == _currentPage ? 22 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: index == _currentPage
                              ? kPrimaryColor
                              : kLightTeal.withOpacity(0.30),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _continue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        isLastPage ? 'Get Started' : 'Continue',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferenceStyleOnboardingPage extends StatelessWidget {
  final _OnboardingData data;

  const _ReferenceStyleOnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF7FCFB),
                    Color(0xFFFFFFFF),
                    Color(0xFFFFFCF5),
                  ],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Image.asset(
                  data.imageAsset,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.medical_services_outlined,
                        color: kPrimaryColor,
                        size: 90,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: kPrimaryColor,
                    fontSize: 23,
                    height: 1.15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 13),
                Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final String imageAsset;
  final String title;
  final String description;

  const _OnboardingData({
    required this.imageAsset,
    required this.title,
    required this.description,
  });
}
