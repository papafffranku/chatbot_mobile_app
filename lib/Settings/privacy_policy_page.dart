import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0b1e),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0a0b1e), // Dark blue instead of transparent
        elevation: 0,
        title: const Text('Privacy & Terms', style: TextStyle(color: Colors.white)),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Privacy Policy Section
              _buildSection(
                title: 'Privacy Policy',
                content: _privacyPolicyContent,
              ),
              
              const SizedBox(height: 24),
              
              // Terms of Service Section
              _buildSection(
                title: 'Terms of Service',
                content: _termsOfServiceContent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                content,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _privacyPolicyContent = '''
  Last updated: 2025

Quantisage Private Limited, values your privacy. This Privacy Policy explains what data we collect, how we use it, and the rights you have regarding your information.

We do not require you to create an account in order to use our services. The data we collect is limited to the text you type into the chatbot (“Chat Input”) and a short history of your conversations. Specifically, we temporarily store the last five chats on our servers to enable chat memory. These chats are automatically deleted after one week. We do not collect device information, usage analytics, or payment data. Any bookings or payments are handled directly by our partners such as Skyscanner and Booking.com.

We use your data solely to provide you with visa information via the chatbot, improve your experience by maintaining short-term chat memory, and enable travel searches that redirect you to our partner services. Importantly, we do not use chat data for AI training, advertising, or resale.

In order to provide services, we may share limited data with trusted partners. Your chat input is sent to the OpenAI API to generate chatbot responses. We also share data with travel partners through RapidAPI, such as Booking.com and Skyscanner, but only as required to fulfil your search queries. We do not sell or monetize your data.

Chat transcripts are stored for up to one week (last five chats only), after which they are automatically deleted. If you wish, you may request earlier deletion of your chat history and we will comply.

As a user, you have the right to request access to the chat data we hold (limited to the last five chats within the retention period) and request deletion of your chat history before the automatic reset. You may contact us with any questions or concerns at contact@quantisageai.com. We do not sell personal data. Residents of California and the European Union may exercise their privacy rights consistent with the CCPA and GDPR.

We take reasonable technical measures to safeguard your data; however, communications with our service are not secured with end-to-end encryption, and we cannot guarantee 100% security. For your protection, please avoid sharing sensitive personal, financial, or government identification information within the chatbot.

Our services are intended for users aged 13 and older. Users under the age of 18 should only use the App with parental supervision, particularly when making travel-related decisions.

Contact Us:
If you have questions about this Privacy Policy, please contact us at contact@quantisageai.com.''';

  static String _termsOfServiceContent = '''
Last updated: 2025

1. Acceptance of Terms
By using this app, you agree to these Terms of Service.

2. Service Overview
The App provides:

A visa information chatbot powered by OpenAI API and proprietary visa data.

Flight and hotel search features via RapidAPI integrations (e.g., Skyscanner, Booking.com).

Important:

Chatbot responses are AI-generated and for general information only.

The App is not a substitute for legal, immigration, or official travel advice.

Always confirm visa or travel details with government sources or embassies.

3. Eligibility & Use
You must be 13+ to use the App. Users under 18 should have parental supervision.

You must not misuse the App (e.g., reverse engineering, overloading, or illegal use).

Do not share sensitive financial, medical, or ID information — the App is not end-to-end encrypted.

4. Third-Party Services
Hotel and flight searches connect through RapidAPI.

Bookings and payments occur on partner sites (e.g., Skyscanner, Booking.com).

Quantisage is not responsible for confirmations, cancellations, refunds, or disputes with third parties.

5. AI Content Disclaimer
Chatbot answers may be incomplete, outdated, or inaccurate.

Quantisage does not guarantee accuracy and is not liable for reliance on chatbot responses.

Always double-check with official sources.

6. Limitation of Liability
To the fullest extent permitted by law:

The App is provided “as is” without warranties of any kind.

Quantisage is not responsible for errors, omissions, delays, or third-party outcomes.

We are not liable for visa decisions, bookings, or travel experiences.

7. Termination
We may suspend or terminate access if you violate these Terms.

8. Governing Law
These Terms are governed by the laws of India. Disputes will be resolved in the courts of Mumbai, Maharashtra.
Contact Information:
For questions regarding these terms, contact us at contact@quantisageai.com.''';
}