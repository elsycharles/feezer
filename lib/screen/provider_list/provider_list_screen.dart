import 'package:flutter/material.dart';
import '../../styles/global.dart';
import '../../util/theme_util.dart';
import '../../widget/app_bar.dart' as custom;
import '../../widget/search_field.dart';
import '../../widget/primary_button.dart';
import 'widget/provider_header.dart';
import 'widget/provider_list_view.dart';

class ProviderListScreen extends StatefulWidget {
  const ProviderListScreen({super.key});

  @override
  State<ProviderListScreen> createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends State<ProviderListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredProviders = [];
  
  final List<Map<String, String>> _allProviders = [
    {'name': 'Bank', 'logo': 'assets/images/fallback.png'},
    {'name': 'MVola', 'logo': 'assets/images/fallback.png'},
    {'name': 'Orange', 'logo': 'assets/images/fallback.png'},
    {'name': 'Airtel', 'logo': 'assets/images/fallback.png'},
  ];

  @override
  void initState() {
    super.initState();
    _filteredProviders = _allProviders;
    _searchController.addListener(_filterProviders);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProviders() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProviders = _allProviders
          .where((provider) =>
              provider['name']!.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const custom.AppBar(title: 'Providers'),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Global.gapMd,
            
            // Header with title and counter
            ProviderHeader(providerCount: _allProviders.length),
            
            Global.gapLg,
            
            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SearchField(
                hintText: 'Search providers...',
                controller: _searchController,
                onChanged: (_) => _filterProviders(),
              ),
            ),
            
            Global.gapMd,
            
            // Provider list
            Expanded(
              child: _filteredProviders.isEmpty
                  ? _buildEmptyState()
                  : ProviderListView(
                      providers: _filteredProviders,
                      onEditProvider: _handleEditProvider,
                      onDeleteProvider: _handleDeleteProvider,
                    ),
            ),
            
            // Add button
            Padding(
              padding: const EdgeInsets.all(16),
              child: PrimaryButton(
                text: '+ Add new provider',
                onPressed: _handleAddProvider,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: ThemeUtil.textSecondary),
          const SizedBox(height: 16),
          Text(
            'No providers found',
            style: TextStyle(
              fontSize: 18,
              color: ThemeUtil.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _handleAddProvider() {
    // TODO: Implement provider addition
    debugPrint('Add provider tapped');
  }

  void _handleEditProvider() {
    // TODO: Implement provider editing
    debugPrint('Edit provider tapped');
  }

  void _handleDeleteProvider() {
    // TODO: Implement provider deletion
    debugPrint('Delete provider tapped');
  }
}