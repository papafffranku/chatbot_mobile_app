import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0b1e),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0a0b1e),
              Color(0xFF4c1d95),
              Color(0xFF1e293b),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // About Section
            _buildSection(
              title: 'About',
              children: [
                _buildTile(
                  icon: Icons.info_outline,
                  title: 'Version',
                  subtitle: '1.0.0',
                  onTap: null,
                ),
                _buildTile(
                  icon: Icons.business,
                  title: 'Developer',
                  subtitle: 'Quantisage',
                  onTap: null,
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Legal Section
            _buildSection(
              title: 'Legal',
              children: [
                _buildTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'View our privacy policy',
                  onTap: () => _launchURL('https://yourwebsite.com/privacy'),
                ),
                _buildTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  subtitle: 'View terms and conditions',
                  onTap: () => _launchURL('https://yourwebsite.com/terms'),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Support Section
            _buildSection(
              title: 'Support',
              children: [
                _buildTile(
                  icon: Icons.email_outlined,
                  title: 'Contact Us',
                  subtitle: 'support@quantisage.com',
                  onTap: () => _launchURL('mailto:support@quantisage.com'),
                ),
                _buildTile(
                  icon: Icons.bug_report_outlined,
                  title: 'Report an Issue',
                  subtitle: 'Help us improve the app',
                  onTap: () => _launchURL('mailto:support@quantisage.com?subject=Bug Report'),
                ),
                _buildTile(
                  icon: Icons.star_outline,
                  title: 'Rate Us',
                  subtitle: 'Leave a review on the store',
                  onTap: () {
                    // Platform-specific store URLs
                    // iOS: https://apps.apple.com/app/idYOUR_APP_ID
                    // Android: https://play.google.com/store/apps/details?id=YOUR_PACKAGE_NAME
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(children: children),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white.withOpacity(0.7)),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
      ),
      trailing: onTap != null
          ? Icon(Icons.arrow_forward_ios, 
              color: Colors.white.withOpacity(0.3), size: 16)
          : null,
      onTap: onTap,
    );
  }
}