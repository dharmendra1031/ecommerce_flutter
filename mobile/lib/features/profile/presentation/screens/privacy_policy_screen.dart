import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(colorScheme),
            const SizedBox(height: 24),
            _buildLastUpdated(colorScheme),
            const SizedBox(height: 32),
            _buildSection(
              '1. Introduction',
              'WeStore ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application. Please read this privacy policy carefully. If you do not agree with the terms of this privacy policy, please do not access the application.',
              colorScheme,
            ),
            _buildSection(
              '2. Information We Collect',
              '''We collect information that you provide directly to us when you:

• Create an account (name, email, phone number)
• Make a purchase (shipping address, payment information)
• Contact our support team
• Submit reviews or ratings
• Participate in promotions or surveys

We also automatically collect certain information when you use our app:

• Device information (model, operating system, unique identifiers)
• Usage data (pages visited, features used, time spent)
• Location data (with your permission)
• Log data (IP address, access times, crashes)''',
              colorScheme,
            ),
            _buildSection(
              '3. How We Use Your Information',
              '''We use the information we collect to:

• Process and fulfill your orders
• Communicate with you about orders and account
• Send promotional emails and push notifications (with consent)
• Improve our app and services
• Personalize your shopping experience
• Detect and prevent fraud
• Comply with legal obligations''',
              colorScheme,
            ),
            _buildSection(
              '4. Sharing Your Information',
              '''We may share your information with:

• Service providers (payment processors, shipping companies)
• Business partners (with your consent)
• Legal authorities (when required by law)
• Successors in case of merger or acquisition

We do not sell your personal information to third parties.''',
              colorScheme,
            ),
            _buildSection(
              '5. Data Security',
              '''We implement appropriate technical and organizational measures to protect your personal information:

• Encryption of sensitive data
• Secure payment processing
• Regular security assessments
• Limited access to personal information
• Employee training on data protection

However, no method of transmission over the internet is 100% secure.''',
              colorScheme,
            ),
            _buildSection(
              '6. Your Rights',
              '''Depending on your location, you may have the right to:

• Access your personal information
• Correct inaccurate information
• Delete your account and data
• Object to certain processing
• Withdraw consent
• Export your data

To exercise these rights, contact us at privacy@westore.com''',
              colorScheme,
            ),
            _buildSection(
              '7. Cookies and Tracking',
              '''We use cookies and similar technologies to:

• Remember your preferences
• Understand app usage patterns
• Deliver personalized content
• Improve app performance

You can control cookies through your device settings.''',
              colorScheme,
            ),
            _buildSection(
              '8. Third-Party Services',
              '''Our app may contain links to third-party websites or services. We are not responsible for the privacy practices of these third parties. We encourage you to read their privacy policies.''',
              colorScheme,
            ),
            _buildSection(
              '9. Children\'s Privacy',
              '''Our app is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13. If you believe we have collected information from a child under 13, please contact us immediately.''',
              colorScheme,
            ),
            _buildSection(
              '10. Changes to This Policy',
              '''We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the "Last Updated" date.''',
              colorScheme,
            ),
            _buildSection(
              '11. Contact Us',
              '''If you have any questions about this Privacy Policy, please contact us:

• Email: privacy@westore.com
• Address: 123 Commerce Street, Business City, BC 12345
• Phone: 1-800-WESTORE''',
              colorScheme,
            ),
            const SizedBox(height: 32),
            _buildAcceptance(colorScheme),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            Icons.privacy_tip_outlined,
            size: 48,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Privacy Matters',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'We are committed to protecting your personal information.',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdated(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.update, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            'Last Updated: January 2024',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptance(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, color: colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            'By using WeStore, you agree to this Privacy Policy. If you do not agree, please do not use our services.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
