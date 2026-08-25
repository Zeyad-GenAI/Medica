import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'shared_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color profileTeal = Color(0xFF12879A);
  static const String defaultProfileImage =
      'assets/images/profile_patient_avatar.png';

  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedProfileImage;

  Future<void> _changeProfileImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final pickedImage = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (pickedImage == null || !mounted) return;

      setState(() {
        _selectedProfileImage = File(pickedImage.path);
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not select profile image: $error'),
        ),
      );
    }
  }

  void _showComingSoon(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title will be available soon.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: profileTeal),
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: profileTeal,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildSectionLabel('Account'),
            const SizedBox(height: 10),
            _ProfileMenuTile(
              icon: Icons.history,
              title: 'History',
              subtitle: 'View your previous appointments',
              onTap: () => _showComingSoon('History'),
            ),
            const SizedBox(height: 10),
            _ProfileMenuTile(
              icon: Icons.person_outline,
              title: 'Personal Details',
              subtitle: 'Manage your personal information',
              onTap: () => _showComingSoon('Personal Details'),
            ),
            const SizedBox(height: 10),
            _ProfileMenuTile(
              icon: Icons.settings_outlined,
              title: 'Settings',
              subtitle: 'Manage app preferences',
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
            const SizedBox(height: 24),
            _buildSectionLabel('Session'),
            const SizedBox(height: 10),
            _ProfileMenuTile(
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out from this account',
              iconColor: Colors.redAccent,
              backgroundColor: const Color(0xFFFFF1F1),
              onTap: _logout,
            ),
          ],
        ),
      ),
      bottomNavigationBar: appBottomNav(context, 2),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF1FAF9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: profileTeal.withOpacity(0.10),
        ),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 58,
                  backgroundColor: const Color(0xFFE0E0E0),
                  backgroundImage: _selectedProfileImage != null
                      ? FileImage(_selectedProfileImage!)
                      : const AssetImage(defaultProfileImage)
                  as ImageProvider,
                ),
              ),
              Positioned(
                right: -2,
                bottom: 2,
                child: Material(
                  color: profileTeal,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: _changeProfileImage,
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Zeyad ElFaramawy',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 19,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Patient account',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: _changeProfileImage,
            icon: const Icon(Icons.edit_outlined, size: 17),
            label: const Text('Edit profile photo'),
            style: OutlinedButton.styleFrom(
              foregroundColor: profileTeal,
              side: BorderSide(
                color: profileTeal.withOpacity(0.35),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color iconColor;
  final Color backgroundColor;

  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor = const Color(0xFF12879A),
    this.backgroundColor = const Color(0xFFE1F5EE),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFEAEAEA),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
