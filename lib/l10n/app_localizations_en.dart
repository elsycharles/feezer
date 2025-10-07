// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Feezer';

  @override
  String get onboardingTitle1 => 'Plan ahead and save on fees';

  @override
  String get onboardingDescription1 =>
      'Calculate the most cost-efficient way to handle your money.';

  @override
  String get onboardingTitle2 => 'Optimize your transactions';

  @override
  String get onboardingDescription2 =>
      'Minimize fees automatically based on predefined intervals.';

  @override
  String get onboardingTitle3 => 'Save smart, spend better';

  @override
  String get onboardingDescription3 =>
      'Get personalized recommendations and make informed financial decisions instantly.';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get getStarted => 'Get Started';

  @override
  String get back => 'Back';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get create => 'Create';

  @override
  String get confirm => 'Confirm';

  @override
  String get optimizeFee => 'Optimize Fee';

  @override
  String get providers => 'Providers';

  @override
  String get settings => 'Settings';

  @override
  String get createInterval => 'Create Interval';

  @override
  String get optimize => 'Optimize';

  @override
  String get amount => 'Amount';

  @override
  String get provider => 'Provider';

  @override
  String get minTransactions => 'Min Transactions';

  @override
  String get maxTransactions => 'Max Transactions';

  @override
  String get pleaseEnterValidAmount => 'Please enter a valid amount';

  @override
  String get pleaseSelectProvider => 'Please select a provider';

  @override
  String get invalidTransactionRange =>
      'Min transactions must be less than max transactions';

  @override
  String get mvola => 'MVola';

  @override
  String get orangeMoney => 'Orange Money';

  @override
  String get airtelMoney => 'Airtel Money';

  @override
  String get mobileFinancialServices => 'Mobile financial services';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get french => 'French';

  @override
  String get malagasy => 'Malagasy';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get thisFeatureWillBeAvailableSoon =>
      'This feature will be available soon!';

  @override
  String get feeIntervals => 'Fee Intervals';

  @override
  String get newFeeInterval => 'New Fee Interval';

  @override
  String get minAmount => 'Min Amount';

  @override
  String get maxAmount => 'Max Amount';

  @override
  String get feePercentage => 'Fee Percentage';

  @override
  String get fixedFee => 'Fixed Fee';

  @override
  String get pleaseEnterMinAmount => 'Please enter minimum amount';

  @override
  String get pleaseEnterMaxAmount => 'Please enter maximum amount';

  @override
  String get pleaseEnterValidFeePercentage =>
      'Please enter a valid fee percentage';

  @override
  String get maxAmountMustBeGreaterThanMinAmount =>
      'Max amount must be greater than min amount';

  @override
  String get optimizationResults => 'Optimization Results';

  @override
  String get interval => 'Interval';

  @override
  String get fee => 'Fee';

  @override
  String get count => 'Count';

  @override
  String get total => 'Total';

  @override
  String get noResultsYet => 'No results yet';

  @override
  String get tapOptimizeToSeeResults => 'Tap \'Optimize\' to see results';

  @override
  String get error => 'Error';

  @override
  String screenNotFound(String route) {
    return 'Screen $route not found';
  }

  @override
  String get goHome => 'Go Home';

  @override
  String get currency => 'Ar';

  @override
  String get demo => 'Demo';

  @override
  String get noProvidersFound => 'No providers found';

  @override
  String get searchProviders => 'Search providers...';

  @override
  String get manageYourProviders => 'Manage your providers';

  @override
  String get centralizeProviders =>
      'Centralize bank and mobile money partners in one place.';

  @override
  String get activeProvider => 'Active provider';

  @override
  String get activeProviders => 'Active providers';

  @override
  String get deleteThisProvider => 'Delete this provider?';

  @override
  String deleteProvidersCount(int count) {
    return 'Delete $count providers?';
  }

  @override
  String get deleteProvider => 'Delete Provider';

  @override
  String get deleteProviders => 'Delete Providers';

  @override
  String providerDeletedSuccessfully(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count providers deleted successfully',
      one: '1 provider deleted successfully',
    );
    return '$_temp0';
  }

  @override
  String get editProvider => 'Edit Provider';

  @override
  String get providerName => 'Provider Name';

  @override
  String get description => 'Description';

  @override
  String get newProvider => 'New Provider';

  @override
  String get createNewProvider => 'Create New Provider';

  @override
  String get enterProviderName => 'Enter provider name';

  @override
  String get providerCreatedSuccessfully => 'Provider created successfully';
}
