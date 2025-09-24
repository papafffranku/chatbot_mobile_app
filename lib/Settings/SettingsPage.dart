import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import '../main.dart';
import 'privacy_policy_page.dart';
import 'contact_page.dart';
import '../ChatPage/animationtest.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _deleteAllChats(BuildContext context) async {
    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1d1936),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Delete All Chats',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to delete all your chat history? This action cannot be undone.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.2),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        // Send email to request chat deletion
        final String emailBody = '''
Hello Quantisage Team,

I would like to request the deletion of all my chat history.

User ID: $globalUserId
Request Date: ${DateTime.now().toLocal().toString().split('.')[0]}

Please delete all my chat data within 7 days as per your privacy policy.

Thank you.
''';

        final Uri emailUri = Uri(
          scheme: 'mailto',
          path: 'contact@quantisageai.com',
          query: 'subject=Chat Deletion Request - $globalUserId&body=${Uri.encodeComponent(emailBody)}',
        );

        await launchUrl(emailUri);

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Chat deletion request sent. Your chats will be deleted within 7 days.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF282442),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Could not open email app. Please contact us directly at contact@quantisageai.com',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red.withOpacity(0.8),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0b1e),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0a0b1e), // Change from transparent
        elevation: 0,
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: const Color(0xFF0a0b1e),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Settings Section
            _buildSection(
              title: 'Settings',
              children: [
                _buildTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy & Terms',
                  subtitle: 'View privacy policy and terms of service',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyPage(),
                      ),
                    );
                  },
                ),
                _buildTile(
                  icon: Icons.email_outlined,
                  title: 'Contact Us',
                  subtitle: 'Send us a message or feedback',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ContactPage(),
                      ),
                    );
                  },
                ),
                _buildTile(
                  icon: Icons.delete_outline,
                  title: 'Delete All Chats',
                  subtitle: 'Request deletion of all chat history',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _deleteAllChats(context);
                  },
                  isDestructive: true,
                ),
                _buildTile(
                  icon: Icons.email_outlined,
                  title: 'Animation',
                  subtitle: 'Test',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TravelGlobeWithText(),
                      ),
                    );
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
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon, 
        color: isDestructive 
          ? Colors.red.withOpacity(0.7) 
          : Colors.white.withOpacity(0.7)
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.white, 
          fontSize: 16
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDestructive 
            ? Colors.red.withOpacity(0.5) 
            : Colors.white.withOpacity(0.5), 
          fontSize: 14
        ),
      ),
      trailing: onTap != null
          ? Icon(
              Icons.arrow_forward_ios, 
              color: Colors.white.withOpacity(0.3), 
              size: 16
            )
          : null,
      onTap: onTap,
    );
  }
}