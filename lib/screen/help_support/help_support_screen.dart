import 'package:flutter/material.dart';
import 'package:fee_minimizer/util/theme_util.dart';
import 'package:fee_minimizer/util/navigation_util.dart';
import 'package:fee_minimizer/widget/app_bar.dart' as custom;
import 'package:fee_minimizer/widget/surface_card.dart';
import 'package:fee_minimizer/widget/interactive_surface.dart';
import 'package:fee_minimizer/widget/collapsible_card.dart';
import 'package:fee_minimizer/widget/refreshable_screen.dart';
import 'package:fee_minimizer/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widget/faq_item.dart';
import 'widget/contact_card.dart';
import 'widget/help_category_card.dart';

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
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh(BuildContext context) async {
    // Simulate refresh - could refresh help content from server
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<FaqItem> _getFilteredFaqs(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final allFaqs = [
      FaqItem(
        question: localizations.faqWhatIsFeeMinimizer,
        answer: localizations.faqWhatIsFeeMinimizerAnswer,
        category: 'getting_started',
      ),
      FaqItem(
        question: localizations.faqHowToAddProvider,
        answer: localizations.faqHowToAddProviderAnswer,
        category: 'providers',
      ),
      FaqItem(
        question: localizations.faqHowToCalculateFees,
        answer: localizations.faqHowToCalculateFeesAnswer,
        category: 'calculations',
      ),
      FaqItem(
        question: localizations.faqDataSecurity,
        answer: localizations.faqDataSecurityAnswer,
        category: 'security',
      ),
      FaqItem(
        question: localizations.faqOfflineMode,
        answer: localizations.faqOfflineModeAnswer,
        category: 'features',
      ),
      FaqItem(
        question: localizations.faqExportData,
        answer: localizations.faqExportDataAnswer,
        category: 'data',
      ),
    ];

    if (_searchQuery.isEmpty) {
      return allFaqs;
    }

    return allFaqs.where((faq) =>
        faq.question.toLowerCase().contains(_searchQuery) ||
        faq.answer.toLowerCase().contains(_searchQuery)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: custom.AppBar(
        title: localizations.helpAndSupport,
        menuExcludeRoutes: [NavigationUtil.helpSupportRoute],
      ),
      body: SafeArea(
        child: RefreshableScreen(
          onRefresh: () => _onRefresh(context),
          child: Column(
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: localizations.searchHelpTopics,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: ThemeUtil.primaryColor,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: theme.cardColor,
                  ),
                ),
              ),

              // Tab Bar
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: localizations.faq),
                  Tab(text: localizations.contact),
                  Tab(text: localizations.userGuide),
                  Tab(text: localizations.feedback),
                ],
                labelStyle: ThemeUtil.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: ThemeUtil.bodyMedium,
                indicatorColor: ThemeUtil.primaryColor,
                labelColor: ThemeUtil.primaryColor,
                unselectedLabelColor: ThemeUtil.textSecondary,
              ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFaqTab(context),
                    _buildContactTab(context),
                    _buildUserGuideTab(context),
                    _buildFeedbackTab(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqTab(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final filteredFaqs = _getFilteredFaqs(context);

    if (filteredFaqs.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: ThemeUtil.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.noResultsFound,
              style: ThemeUtil.titleMedium.copyWith(
                color: ThemeUtil.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              localizations.tryDifferentKeywords,
              style: ThemeUtil.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              '${localizations.found} ${filteredFaqs.length} ${localizations.results}',
              style: ThemeUtil.bodySmall.copyWith(
                color: ThemeUtil.textSecondary,
              ),
            ),
          ),
        ...filteredFaqs.map((faq) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CollapsibleCard(
                title: faq.question,
                isInitiallyExpanded: false,
                icon: Icons.help_outline,
                children: [
                  Text(
                    faq.answer,
                    style: ThemeUtil.bodyMedium,
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildContactTab(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ContactCard(
          title: localizations.emailSupport,
          subtitle: 'support@feeminimizer.com',
          icon: Icons.email_outlined,
          onTap: () => _launchEmail(),
        ),
        const SizedBox(height: 12),
        ContactCard(
          title: localizations.phoneSupport,
          subtitle: '+1 (555) 123-4567',
          icon: Icons.phone_outlined,
          onTap: () => _launchPhone(),
        ),
        const SizedBox(height: 12),
        ContactCard(
          title: localizations.website,
          subtitle: 'www.feeminimizer.com',
          icon: Icons.web_outlined,
          onTap: () => _launchWebsite(),
        ),
        const SizedBox(height: 24),
        SurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.responseTime,
                  style: ThemeUtil.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.responseTimeDescription,
                  style: ThemeUtil.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserGuideTab(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        HelpCategoryCard(
          title: localizations.gettingStarted,
          description: localizations.gettingStartedDescription,
          icon: Icons.play_arrow_outlined,
          onTap: () => _showGettingStartedGuide(context),
        ),
        const SizedBox(height: 12),
        HelpCategoryCard(
          title: localizations.providerManagement,
          description: localizations.providerManagementDescription,
          icon: Icons.business_outlined,
          onTap: () => _showProviderGuide(context),
        ),
        const SizedBox(height: 12),
        HelpCategoryCard(
          title: localizations.feeCalculation,
          description: localizations.feeCalculationDescription,
          icon: Icons.calculate_outlined,
          onTap: () => _showCalculationGuide(context),
        ),
        const SizedBox(height: 12),
        HelpCategoryCard(
          title: localizations.dataManagement,
          description: localizations.dataManagementDescription,
          icon: Icons.data_usage_outlined,
          onTap: () => _showDataGuide(context),
        ),
        const SizedBox(height: 24),
        SurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.videoTutorials,
                  style: ThemeUtil.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.videoTutorialsDescription,
                  style: ThemeUtil.bodyMedium,
                ),
                const SizedBox(height: 16),
                InteractiveSurface(
                  onTap: () => _launchVideoTutorials(),
                  builder: (context, hovered, pressed) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeUtil.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          color: ThemeUtil.primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          localizations.watchTutorials,
                          style: ThemeUtil.bodyMedium.copyWith(
                            color: ThemeUtil.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: ThemeUtil.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackTab(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.shareYourThoughts,
                  style: ThemeUtil.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.feedbackDescription,
                  style: ThemeUtil.bodyMedium,
                ),
                const SizedBox(height: 16),
                InteractiveSurface(
                  onTap: () => _openFeedbackForm(),
                  builder: (context, hovered, pressed) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeUtil.secondaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.feedback_outlined,
                          color: ThemeUtil.secondaryColor,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          localizations.submitFeedback,
                          style: ThemeUtil.bodyMedium.copyWith(
                            color: ThemeUtil.secondaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: ThemeUtil.secondaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.rateApp,
                  style: ThemeUtil.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.rateAppDescription,
                  style: ThemeUtil.bodyMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  children: List.generate(5, (index) => Icon(
                    Icons.star_border,
                    color: ThemeUtil.warning,
                    size: 32,
                  )),
                ),
                const SizedBox(height: 16),
                InteractiveSurface(
                  onTap: () => _openAppStore(),
                  builder: (context, hovered, pressed) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeUtil.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star_outlined,
                          color: ThemeUtil.accentColor,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          localizations.rateOnStore,
                          style: ThemeUtil.bodyMedium.copyWith(
                            color: ThemeUtil.accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: ThemeUtil.accentColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _launchEmail() async {
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

  void _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+15551234567');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _launchWebsite() async {
    final Uri websiteUri = Uri.parse('https://www.feeminimizer.com');
    if (await canLaunchUrl(websiteUri)) {
      await launchUrl(websiteUri);
    }
  }

  void _launchVideoTutorials() async {
    final Uri tutorialsUri = Uri.parse('https://www.feeminimizer.com/tutorials');
    if (await canLaunchUrl(tutorialsUri)) {
      await launchUrl(tutorialsUri);
    }
  }

  void _openFeedbackForm() async {
    final Uri feedbackUri = Uri.parse('https://www.feeminimizer.com/feedback');
    if (await canLaunchUrl(feedbackUri)) {
      await launchUrl(feedbackUri);
    }
  }

  void _openAppStore() async {
    // This would be platform-specific - for demo purposes
    final Uri storeUri = Uri.parse('https://play.google.com/store/apps/details?id=com.feeminimizer');
    if (await canLaunchUrl(storeUri)) {
      await launchUrl(storeUri);
    }
  }

  void _showGettingStartedGuide(BuildContext context) {
    // Show getting started guide - could be a modal or navigate to detailed guide
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Getting Started Guide - Coming Soon!')),
    );
  }

  void _showProviderGuide(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Provider Management Guide - Coming Soon!')),
    );
  }

  void _showCalculationGuide(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fee Calculation Guide - Coming Soon!')),
    );
  }

  void _showDataGuide(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data Management Guide - Coming Soon!')),
    );
  }
}