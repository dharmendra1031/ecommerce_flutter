import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
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
              '1. Acceptance of Terms',
              'By accessing or using the WeStore mobile application ("App"), you agree to be bound by these Terms of Service ("Terms"). If you do not agree to these Terms, you may not access or use the App. We reserve the right to modify these Terms at any time, and such modifications shall be effective immediately upon posting. Your continued use of the App following any modifications indicates your acceptance of the modified Terms.',
              colorScheme,
            ),
            _buildSection(
              '2. Eligibility',
              'You must be at least 13 years old to use the App. By using the App, you represent and warrant that: (a) you are at least 13 years of age; (b) you have the legal capacity to enter into a binding agreement; (c) you will comply with these Terms and all applicable laws; and (d) all information you provide is accurate and complete.',
              colorScheme,
            ),
            _buildSection(
              '3. Account Registration',
              '''To access certain features, you must register for an account. You agree to:

• Provide accurate and complete information
• Maintain the security of your account credentials
• Promptly update your account information
• Accept responsibility for all activities under your account
• Notify us immediately of any unauthorized use

We reserve the right to suspend or terminate accounts that violate these Terms.''',
              colorScheme,
            ),
            _buildSection(
              '4. Products and Orders',
              '''All product descriptions and prices are subject to change without notice. We reserve the right to:

• Limit quantities of any product
• Discontinue any product at any time
• Refuse or cancel any order for any reason
• Verify information before processing an order

Prices displayed do not include taxes and shipping fees, which will be added at checkout.''',
              colorScheme,
            ),
            _buildSection(
              '5. Payment Terms',
              '''By providing a payment method, you authorize us to charge:

• The amount due for your purchases
• Applicable taxes and shipping fees
• Any other charges you authorize

All payments are processed securely through our payment providers. You represent that you have the legal right to use any payment method you provide.''',
              colorScheme,
            ),
            _buildSection(
              '6. Shipping and Delivery',
              '''We will make every effort to deliver products within the estimated timeframe. However:

• Delivery dates are estimates, not guarantees
• We are not responsible for delays beyond our control
• Risk of loss transfers upon delivery
• You are responsible for providing accurate shipping information

Please inspect your order upon delivery and report any issues within 48 hours.''',
              colorScheme,
            ),
            _buildSection(
              '7. Returns and Refunds',
              '''Our return policy allows returns within 30 days of delivery for most items. To be eligible:

• Items must be unused and in original packaging
• Proof of purchase is required
• Certain items (perishables, personal care) cannot be returned
• Refunds will be issued to original payment method

Please contact customer service to initiate a return.''',
              colorScheme,
            ),
            _buildSection(
              '8. User Content',
              '''You may submit reviews, ratings, and other content ("User Content"). By submitting User Content, you:

• Grant us a non-exclusive, royalty-free license to use it
• Represent that you own or have rights to the content
• Agree not to submit false, misleading, or harmful content
• Understand we may remove content at our discretion

Prohibited content includes: offensive material, spam, infringing content, and personal information of others.''',
              colorScheme,
            ),
            _buildSection(
              '9. Intellectual Property',
              '''All content in the App, including text, graphics, logos, and software, is our property or licensed to us and is protected by intellectual property laws. You may not:

• Copy, modify, or distribute App content
• Reverse engineer or decompile the App
• Use our trademarks without permission
• Remove copyright or proprietary notices

Your use of the App does not grant you any ownership rights.''',
              colorScheme,
            ),
            _buildSection(
              '10. Prohibited Activities',
              '''You agree not to:

• Use the App for illegal purposes
• Interfere with the App's operation
• Attempt to gain unauthorized access
• Use automated systems or scrapers
• Harass, abuse, or harm others
• Submit false or fraudulent information
• Circumvent any security measures

Violation may result in immediate account termination.''',
              colorScheme,
            ),
            _buildSection(
              '11. Disclaimer of Warranties',
              '''THE APP IS PROVIDED "AS IS" WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED. WE DO NOT WARRANT THAT:

• THE APP WILL BE UNINTERRUPTED OR ERROR-FREE
• DEFECTS WILL BE CORRECTED
• THE APP IS FREE OF VIRUSES OR HARMFUL COMPONENTS
• PRODUCT DESCRIPTIONS ARE ACCURATE

YOUR USE OF THE APP IS AT YOUR SOLE RISK.''',
              colorScheme,
            ),
            _buildSection(
              '12. Limitation of Liability',
              '''TO THE MAXIMUM EXTENT PERMITTED BY LAW, WE SHALL NOT BE LIABLE FOR:

• INDIRECT, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
• LOST PROFITS OR REVENUE
• LOSS OF DATA OR GOODWILL
• SERVICE INTERRUPTIONS
• DAMAGES EXCEEDING THE AMOUNT YOU PAID TO US

SOME JURISDICTIONS DO NOT ALLOW CERTAIN LIMITATIONS, SO THESE MAY NOT APPLY TO YOU.''',
              colorScheme,
            ),
            _buildSection(
              '13. Indemnification',
              'You agree to indemnify and hold harmless WeStore and its officers, directors, employees, and agents from any claims, damages, losses, or expenses (including attorneys\' fees) arising from your use of the App, your violation of these Terms, or your violation of any rights of a third party.',
              colorScheme,
            ),
            _buildSection(
              '14. Governing Law',
              'These Terms shall be governed by and construed in accordance with the laws of [Your State/Country], without regard to its conflict of law provisions. Any legal action arising from these Terms shall be brought exclusively in the courts located in [Your City, State/Country].',
              colorScheme,
            ),
            _buildSection(
              '15. Severability',
              'If any provision of these Terms is found to be unenforceable or invalid, that provision shall be limited or eliminated to the minimum extent necessary, and the remaining provisions shall remain in full force and effect.',
              colorScheme,
            ),
            _buildSection(
              '16. Entire Agreement',
              'These Terms, together with our Privacy Policy, constitute the entire agreement between you and WeStore regarding the use of the App and supersede all prior agreements and understandings.',
              colorScheme,
            ),
            _buildSection(
              '17. Contact Information',
              '''If you have any questions about these Terms, please contact us:

• Email: legal@westore.com
• Address: 123 Commerce Street, Business City, BC 12345
• Phone: 1-800-WESTORE

We will respond to your inquiry within 2 business days.''',
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
            Icons.description_outlined,
            size: 48,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Terms of Service',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Please read these terms carefully before using our services.',
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
            'By using WeStore, you agree to these Terms of Service. Please read them carefully.',
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
