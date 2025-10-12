import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fee_minimizer/screen/help_support/widget/faq_item.dart';
import 'package:fee_minimizer/screen/help_support/widget/contact_card.dart';
import 'package:fee_minimizer/util/theme_util.dart';
import 'package:fee_minimizer/widget/collapsible_card.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Help & Support',
          style: TextStyle(
            fontSize: ThemeUtil.fontSizeTitleLarge,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search help...',
                    hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    prefixIcon: Icon(
                      Icons.search,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ),
              // Tab bar
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'FAQ'),
                  Tab(text: 'Contact'),
                ],
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                indicatorColor: colorScheme.primary,
                dividerColor: colorScheme.outlineVariant,
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFAQTab(colorScheme),
          _buildContactTab(colorScheme),
        ],
      ),
    );
  }

  Widget _buildFAQTab(ColorScheme colorScheme) {
    final faqItems = _getFilteredFAQItems();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: faqItems.length,
      itemBuilder: (context, index) {
        final item = faqItems[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CollapsibleCard(
            title: item.question,
            titleStyle: TextStyle(
              fontSize: ThemeUtil.fontSizeBodyMedium,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
            children: [
              Text(
                item.answer,
                style: TextStyle(
                  fontSize: ThemeUtil.fontSizeBodyMedium,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactTab(ColorScheme colorScheme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Contact Us',
          style: TextStyle(
            fontSize: ThemeUtil.fontSizeTitleLarge,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Get in touch with our support team for help with any questions or issues.',
          style: TextStyle(
            fontSize: ThemeUtil.fontSizeBodyMedium,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        ContactCard(
          title: 'Email',
          subtitle: 'support@feeminimizer.com',
          icon: Icons.email,
          onTap: () => _launchEmail(),
        ),
        const SizedBox(height: 12),
        ContactCard(
          title: 'Phone',
          subtitle: '+1 (555) 123-4567',
          icon: Icons.phone,
          onTap: () => _launchPhone(),
        ),
        const SizedBox(height: 12),
        ContactCard(
          title: 'Website',
          subtitle: 'www.feeminimizer.com',
          icon: Icons.web,
          onTap: () => _launchWebsite(),
        ),
      ],
    );
  }

  List<FaqItem> _getFilteredFAQItems() {
    final allItems = [
      FaqItem(
        question: 'How do I minimize transaction fees?',
        answer: 'Our app automatically calculates the most cost-effective way to handle your transactions by comparing different providers and payment methods.',
        category: 'general',
      ),
      FaqItem(
        question: 'What currencies are supported?',
        answer: 'We support all major world currencies including USD, EUR, GBP, JPY, and many others. The app automatically handles currency conversion rates.',
        category: 'general',
      ),
      FaqItem(
        question: 'Is my financial data secure?',
        answer: 'Yes, we use bank-level encryption and security measures. Your data is never stored on our servers and all calculations are done locally on your device.',
        category: 'general',
      ),
      FaqItem(
        question: 'How do I update currency rates?',
        answer: 'Currency rates are automatically updated in real-time from reliable financial data providers. You can also manually refresh rates in the settings.',
        category: 'general',
      ),
      FaqItem(
        question: 'Can I save my favorite providers?',
        answer: 'Yes, you can save your preferred banking providers and payment methods for quick access when making new calculations.',
        category: 'general',
      ),
    ];

    if (_searchQuery.isEmpty) {
      return allItems;
    }

    return allItems.where((item) {
      return item.question.toLowerCase().contains(_searchQuery) ||
             item.answer.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@feeminimizer.com',
      queryParameters: {
        'subject': 'Fee Minimizer Support Request',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+15551234567');

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchWebsite() async {
    final Uri websiteUri = Uri.parse('https://www.feeminimizer.com');

    if (await canLaunchUrl(websiteUri)) {
      await launchUrl(websiteUri, mode: LaunchMode.externalApplication);
    }
  }
}