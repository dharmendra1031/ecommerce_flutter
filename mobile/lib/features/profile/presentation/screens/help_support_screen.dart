import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<FAQCategory> _faqCategories = [
    FAQCategory(
      title: 'Orders & Tracking',
      icon: Icons.shopping_bag_outlined,
      faqs: [
        FAQ(
          question: 'How do I track my order?',
          answer:
              'You can track your order by going to "My Orders" in your profile. Select the order you want to track and tap "Track Order" to see real-time shipping updates.',
        ),
        FAQ(
          question: 'Can I cancel my order?',
          answer:
              'Orders can be cancelled within 1 hour of placement or before they are processed for shipping. Go to "My Orders", select the order, and tap "Cancel Order" if the option is available.',
        ),
        FAQ(
          question: 'What if my order is delayed?',
          answer:
              'Shipping delays can occur due to weather, high demand, or carrier issues. If your order is significantly delayed, please contact our support team for assistance.',
        ),
        FAQ(
          question: 'Why was my order cancelled?',
          answer:
              'Orders may be cancelled due to: item out of stock, payment issues, or unable to verify shipping address. You will receive an email notification with the reason.',
        ),
      ],
    ),
    FAQCategory(
      title: 'Shipping & Delivery',
      icon: Icons.local_shipping_outlined,
      faqs: [
        FAQ(
          question: 'How long does shipping take?',
          answer:
              'Standard shipping takes 5-7 business days. Express shipping takes 2-3 business days. Delivery times may vary based on your location and product availability.',
        ),
        FAQ(
          question: 'Do you offer free shipping?',
          answer:
              'Yes! We offer free standard shipping on orders over \$50. Express shipping is available for a flat rate of \$9.99.',
        ),
        FAQ(
          question: 'Do you ship internationally?',
          answer:
              'Currently, we only ship within the United States. We plan to expand to international shipping soon.',
        ),
        FAQ(
          question: 'What if I\'m not home for delivery?',
          answer:
              'If you\'re not home, the carrier will leave a notice and attempt redelivery or hold the package at a nearby facility. You can also provide delivery instructions during checkout.',
        ),
      ],
    ),
    FAQCategory(
      title: 'Returns & Refunds',
      icon: Icons.assignment_return_outlined,
      faqs: [
        FAQ(
          question: 'What is your return policy?',
          answer:
              'We accept returns within 30 days of delivery. Items must be unused, in original packaging, with all tags attached. Some items like perishables and personal care products cannot be returned.',
        ),
        FAQ(
          question: 'How do I return an item?',
          answer:
              'Go to "My Orders", select the order, and tap "Return Item". Follow the instructions to print your return label and drop off the package at any authorized location.',
        ),
        FAQ(
          question: 'When will I receive my refund?',
          answer:
              'Refunds are processed within 3-5 business days after we receive your return. The refund will be issued to your original payment method and may take an additional 5-10 business days to appear.',
        ),
        FAQ(
          question: 'What if I received a damaged item?',
          answer:
              'We\'re sorry! Please contact us within 48 hours of delivery with photos of the damaged item. We\'ll send a replacement or issue a full refund immediately.',
        ),
      ],
    ),
    FAQCategory(
      title: 'Payments & Security',
      icon: Icons.payment_outlined,
      faqs: [
        FAQ(
          question: 'What payment methods do you accept?',
          answer:
              'We accept all major credit cards (Visa, Mastercard, American Express, Discover), debit cards, and PayPal. All transactions are secure and encrypted.',
        ),
        FAQ(
          question: 'Is my payment information secure?',
          answer:
              'Absolutely! We use industry-standard SSL encryption and never store your full credit card details. All payments are processed through secure, PCI-compliant payment gateways.',
        ),
        FAQ(
          question: 'Why was my payment declined?',
          answer:
              'Payments may be declined due to: insufficient funds, incorrect card details, expired card, or bank security blocks. Please verify your information or contact your bank.',
        ),
        FAQ(
          question: 'Can I change my payment method after ordering?',
          answer:
              'Unfortunately, we cannot change the payment method after an order is placed. You would need to cancel the order (if still possible) and place a new one.',
        ),
      ],
    ),
    FAQCategory(
      title: 'Account & Profile',
      icon: Icons.person_outline,
      faqs: [
        FAQ(
          question: 'How do I update my email address?',
          answer:
              'Go to "Edit Profile" in your account settings. Note that you\'ll need to verify your new email address before the change takes effect.',
        ),
        FAQ(
          question: 'I forgot my password. What should I do?',
          answer:
              'Tap "Forgot Password" on the login screen. We\'ll send a password reset link to your registered email address. The link expires in 24 hours for security.',
        ),
        FAQ(
          question: 'How do I delete my account?',
          answer:
              'Go to Settings > Delete Account. Please note that this action is permanent and will delete all your data including order history and saved addresses.',
        ),
        FAQ(
          question: 'Can I have multiple shipping addresses?',
          answer:
              'Yes! You can save multiple addresses in your profile. During checkout, simply select which address you want to use for that order.',
        ),
      ],
    ),
  ];

  List<FAQ> get _filteredFAQs {
    if (_searchQuery.isEmpty) return [];

    final List<FAQ> results = [];
    final query = _searchQuery.toLowerCase();

    for (final category in _faqCategories) {
      for (final faq in category.faqs) {
        if (faq.question.toLowerCase().contains(query) ||
            faq.answer.toLowerCase().contains(query)) {
          results.add(faq);
        }
      }
    }
    return results;
  }

  Future<void> _contactSupport() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@westore.com',
      queryParameters: {
        'subject': 'WeStore Support Request',
        'body': 'Hello WeStore Support Team,\n\nI need help with:\n\n',
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Could not open email client. Please email support@westore.com'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Error opening email. Please contact support@westore.com'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for help...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Contact Support Card
          if (_searchQuery.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _ContactSupportCard(onTap: _contactSupport),
            ),

          // Quick Actions
          if (_searchQuery.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: _QuickActionsRow(),
            ),

          // Content
          Expanded(
            child: _searchQuery.isNotEmpty
                ? _buildSearchResults()
                : _buildFAQCategories(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final results = _filteredFAQs;
    final colorScheme = Theme.of(context).colorScheme;

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found for "$_searchQuery"',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords or contact support',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return _FAQExpansionTile(faq: results[index]);
      },
    );
  }

  Widget _buildFAQCategories() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _faqCategories.length,
      itemBuilder: (context, index) {
        final category = _faqCategories[index];
        return _CategorySection(category: category);
      },
    );
  }
}

class _ContactSupportCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ContactSupportCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.email_outlined,
                  color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Can\'t find what you\'re looking for?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Contact our support team',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.shopping_bag_outlined,
        label: 'Track Order',
        onTap: () {},
      ),
      _QuickAction(
        icon: Icons.assignment_return_outlined,
        label: 'Start Return',
        onTap: () {},
      ),
      _QuickAction(
        icon: Icons.payment_outlined,
        label: 'Payment Help',
        onTap: () {},
      ),
      _QuickAction(
        icon: Icons.lock_outline,
        label: 'Account Help',
        onTap: () {},
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children:
          actions.map((action) => _buildQuickAction(context, action)).toList(),
    );
  }

  Widget _buildQuickAction(BuildContext context, _QuickAction action) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Icon(
                action.icon,
                color: colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final FAQCategory category;

  const _CategorySection({required this.category});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Icon(
            category.icon,
            color: colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          category.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        children:
            category.faqs.map((faq) => _FAQExpansionTile(faq: faq)).toList(),
      ),
    );
  }
}

class _FAQExpansionTile extends StatelessWidget {
  final FAQ faq;

  const _FAQExpansionTile({required this.faq});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ExpansionTile(
      title: Text(
        faq.question,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            faq.answer,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class FAQCategory {
  final String title;
  final IconData icon;
  final List<FAQ> faqs;

  FAQCategory({
    required this.title,
    required this.icon,
    required this.faqs,
  });
}

class FAQ {
  final String question;
  final String answer;

  FAQ({
    required this.question,
    required this.answer,
  });
}

class _QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
