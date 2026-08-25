import 'package:flutter/material.dart';

import 'shared_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const String medicalBannerAsset =
      'assets/images/medical_consultation_banner.png';

  static const List<_DiseaseCategory> _diseaseCategories = [
    _DiseaseCategory(
      title: 'Hypertension',
      subtitle: 'Blood pressure',
      icon: Icons.favorite_border,
    ),
    _DiseaseCategory(
      title: 'Diabetes',
      subtitle: 'Blood sugar',
      icon: Icons.water_drop_outlined,
    ),
    _DiseaseCategory(
      title: 'Osteoporosis',
      subtitle: 'Bone health',
      icon: Icons.accessibility_new,
    ),
    _DiseaseCategory(
      title: 'Asthma',
      subtitle: 'Breathing care',
      icon: Icons.air,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            TextField(
              decoration: appInputDecoration(
                context,
                'Search a condition',
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                suffixIcon: const Icon(
                  Icons.mic_none,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildMedicalBanner(context),
            const SizedBox(height: 18),
            _buildSectionTitle(
              title: 'Health Conditions',
              actionText: 'See All',
              onActionPressed: () {},
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 126,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _diseaseCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final category = _diseaseCategories[index];
                  return _DiseaseCategoryCard(
                    category: category,
                    onTap: () {
                      Navigator.pushNamed(context, '/message');
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 22),
            _buildHealthTipCard(),
          ],
        ),
      ),
      bottomNavigationBar: appBottomNav(context, 0),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 26,
          backgroundColor: Color(0xFFE0E0E0),
          child: Icon(
            Icons.person_outline,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, welcome back',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Zeyad ElFaramawy',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMedicalBanner(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 178,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              medicalBannerAsset,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: kPrimaryColor,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(
                    Icons.medical_services_outlined,
                    color: Colors.white54,
                    size: 72,
                  ),
                );
              },
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    kPrimaryColor.withOpacity(0.95),
                    kPrimaryColor.withOpacity(0.72),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.42, 1.0],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 150, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Medical care made simple',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      height: 1.08,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Connect with doctors and get trusted clinical guidance from anywhere.',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/message'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Medica Assistant',
                        style: TextStyle(
                          fontSize: 11,
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

  Widget _buildSectionTitle({
    required String title,
    required String actionText,
    required VoidCallback onActionPressed,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        TextButton(
          onPressed: onActionPressed,
          child: Text(
            actionText,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthTipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1FAF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: kPrimaryColor.withOpacity(0.12),
        ),
      ),
      child: const Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0x1F12879A),
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 46,
              height: 46,
              child: Icon(
                Icons.health_and_safety_outlined,
                color: kPrimaryColor,
                size: 26,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your health matters',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Choose a condition to start a conversation with Medica Assistant.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    height: 1.3,
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

class _DiseaseCategory {
  final String title;
  final String subtitle;
  final IconData icon;

  const _DiseaseCategory({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _DiseaseCategoryCard extends StatelessWidget {
  final _DiseaseCategory category;
  final VoidCallback onTap;

  const _DiseaseCategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 142,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFF8CCFC4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.24),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const Spacer(),
            Text(
              category.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              category.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
