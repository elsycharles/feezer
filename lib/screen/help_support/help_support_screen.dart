import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fee_minimizer/screen/help_support/widget/faq_item.dart';
import 'package:fee_minimizer/widget/surface_card.dart';
import 'package:fee_minimizer/widget/interactive_surface.dart';
import 'package:fee_minimizer/util/theme_util.dart';
import 'package:fee_minimizer/widget/collapsible_card.dart';
import 'package:fee_minimizer/widget/app_bar.dart' as custom;
import 'package:fee_minimizer/l10n/app_localizations.dart';
import 'package:fee_minimizer/widget/refreshable_screen.dart';
import 'package:fee_minimizer/screen/provider_list/widget/search_field.dart';

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: custom.AppBar(
        title: AppLocalizations.of(context).helpAndSupport,
        menuExcludeRoutes: const [],
      ),
      body: SafeArea(
        child: RefreshableScreen(
          onRefresh: () async {
            // For help screen, we could refresh FAQ data or just provide haptic feedback
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SearchField(
                  hintText: AppLocalizations.of(context).searchHelpTopics,
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Tab bar
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: AppLocalizations.of(context).faq),
                  Tab(text: AppLocalizations.of(context).contact),
                ],
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                indicatorColor: colorScheme.primary,
                dividerColor: colorScheme.outlineVariant,
              ),
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFAQTab(colorScheme),
                    _buildContactTab(colorScheme),
                  ],
                ),
              ),
            ],
          ),
        ),
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
            isInitiallyExpanded: false,
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
          AppLocalizations.of(context).contactUs,
          style: TextStyle(
            fontSize: ThemeUtil.fontSizeTitleLarge,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context).contactDescription,
          style: TextStyle(
            fontSize: ThemeUtil.fontSizeBodyMedium,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        SurfaceCard(
          child: InteractiveSurface(
            onTap: () => _launchEmail(),
            builder: (context, hovered, pressed) => ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.email,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              title: Text(
                AppLocalizations.of(context).email,
                style: TextStyle(
                  fontSize: ThemeUtil.fontSizeBodyLarge,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'support@feeminimizer.com',
                style: TextStyle(
                  fontSize: ThemeUtil.fontSizeBodyMedium,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: colorScheme.onSurfaceVariant,
                size: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SurfaceCard(
          child: InteractiveSurface(
            onTap: () => _launchPhone(),
            builder: (context, hovered, pressed) => ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.phone,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              title: Text(
                AppLocalizations.of(context).phone,
                style: TextStyle(
                  fontSize: ThemeUtil.fontSizeBodyLarge,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                '+1 (555) 123-4567',
                style: TextStyle(
                  fontSize: ThemeUtil.fontSizeBodyMedium,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: colorScheme.onSurfaceVariant,
                size: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SurfaceCard(
          child: InteractiveSurface(
            onTap: () => _launchWebsite(),
            builder: (context, hovered, pressed) => ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.web,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              title: Text(
                AppLocalizations.of(context).website,
                style: TextStyle(
                  fontSize: ThemeUtil.fontSizeBodyLarge,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'www.feeminimizer.com',
                style: TextStyle(
                  fontSize: ThemeUtil.fontSizeBodyMedium,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: colorScheme.onSurfaceVariant,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<FaqItem> _getFilteredFAQItems() {
    final allItems = [
      FaqItem(
        question: AppLocalizations.of(context).faqQuestion1,
        answer: AppLocalizations.of(context).faqAnswer1,
        category: 'general',
      ),
      FaqItem(
        question: AppLocalizations.of(context).faqQuestion2,
        answer: AppLocalizations.of(context).faqAnswer2,
        category: 'general',
      ),
      FaqItem(
        question: AppLocalizations.of(context).faqQuestion3,
        answer: AppLocalizations.of(context).faqAnswer3,
        category: 'general',
      ),
      FaqItem(
        question: AppLocalizations.of(context).faqQuestion4,
        answer: AppLocalizations.of(context).faqAnswer4,
        category: 'general',
      ),
      FaqItem(
        question: AppLocalizations.of(context).faqQuestion5,
        answer: AppLocalizations.of(context).faqAnswer5,
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