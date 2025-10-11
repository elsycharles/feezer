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
  String get feeIntervals => 'Fee intervals';

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
  String get transactionDetails => 'Transaction Details';

  @override
  String get currencySymbol => 'Ar';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get netAmount => 'Net Amount';

  @override
  String get totalFees => 'Total Fees';

  @override
  String get efficiency => 'Efficiency';

  @override
  String get operations => 'Operations';

  @override
  String get remaining => 'Remaining';

  @override
  String get noOptimizationResultsFound =>
      'No optimization results found. Please check your input parameters.';

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

  @override
  String get systemDefault => 'System default';

  @override
  String get general => 'General';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get faqAndContact => 'FAQ and contact';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get termsAndPrivacyPolicy => 'Terms and privacy policy';

  @override
  String get featureComingNextVersion => 'Feature coming in the next version';

  @override
  String get financialProvider => 'Financial Provider';

  @override
  String get chooseProviderToAnalyze =>
      'Choose the provider you want to analyze';

  @override
  String get amountToOptimize => 'Amount to Optimize';

  @override
  String get enterTransactionAmountToOptimize =>
      'Enter the transaction amount you want to optimize';

  @override
  String get transactionRange => 'Transaction Range';

  @override
  String get defineMinMaxTransactions =>
      'Define the minimum and maximum number of transactions';

  @override
  String get readyToOptimize => 'Ready to Optimize';

  @override
  String get clickOptimizeButtonToAnalyze =>
      'Click the Optimize button to analyze the best fee structure for your transactions';

  @override
  String get providerDetails => 'Provider details';

  @override
  String get noFeeIntervalsFound => 'No fee intervals found';

  @override
  String get feeInterval => 'Fee interval';

  @override
  String get searchByFeeRange => 'Search by Fee Range';

  @override
  String get addFeeInterval => 'Add Fee Interval';

  @override
  String get minFee => 'Min fee';

  @override
  String get maxFee => 'Max fee';

  @override
  String get deleteFeeIntervals => 'Delete Fee Intervals';

  @override
  String get createNewFeeInterval => 'Create New Fee Interval';

  @override
  String get defineNewFeeStructure =>
      'Define a new fee structure for transaction amounts';

  @override
  String get enterMinimumAmount => 'Enter minimum amount';

  @override
  String get enterMaximumAmount => 'Enter maximum amount';

  @override
  String get enterFeeAmount => 'Enter fee amount';

  @override
  String get maxAmountMustBeGreater =>
      'Max amount must be greater than min amount';

  @override
  String get feeIntervalCreatedSuccessfully =>
      'Fee interval created successfully';

  @override
  String get addNewFinancialServiceProvider =>
      'Add a new financial service provider to your list';

  @override
  String get enterDescription => 'Enter description';

  @override
  String get createProvider => 'Create Provider';

  @override
  String get clearSelection => 'Clear selection';

  @override
  String get selectAll => 'Select all';

  @override
  String get icon => 'Icon';

  @override
  String get tapToSelectIcon => 'Tap to select icon';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get selectIcon => 'Select Icon';

  @override
  String get thisFieldIsRequired => 'This field is required';

  @override
  String get pressAgainToExit => 'Press again to exit';

  @override
  String get providerUpdatedSuccessfully => 'Provider updated successfully';

  @override
  String get feeIntervalUpdatedSuccessfully =>
      'Fee interval updated successfully';

  @override
  String feeIntervalDeletedSuccessfully(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString fee intervals deleted successfully',
      one: '1 fee interval deleted successfully',
    );
    return '$_temp0';
  }

  @override
  String get editFeeInterval => 'Edit Fee Interval';

  @override
  String get minTransactionsCannotBeGreaterThanMax =>
      'Min transactions cannot be greater than max';

  @override
  String get pleaseEnterValidFee => 'Please enter a valid fee';

  @override
  String mustBeAtLeastNCharacters(int count) {
    return 'Must be at least $count characters';
  }

  @override
  String get enterValidNumber => 'Enter a valid number';

  @override
  String get pleaseEnterFeeAmount => 'Please enter fee amount';

  @override
  String get details => 'Details';

  @override
  String get minimumAmount => 'Minimum amount';

  @override
  String get maximumAmount => 'Maximum amount';

  @override
  String get feeAmount => 'Fee amount';

  @override
  String get traditionalBanking => 'Traditional banking';

  @override
  String get mobileMoney => 'Mobile money';

  @override
  String get selected => 'selected';

  @override
  String get feeOptimizer => 'Fee Optimizer';

  @override
  String get totalFeeIntervals => 'Total Fee Intervals';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get addNewProvider => 'Add new provider';

  @override
  String get tryAdjustingYourSearchRange => 'Try adjusting your search range';

  @override
  String get chooseTheme => 'Choose Theme';

  @override
  String get alwaysUseLightTheme => 'Always use light theme';

  @override
  String get alwaysUseDarkTheme => 'Always use dark theme';

  @override
  String get followSystemSettings => 'Follow system settings';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get minimumAmountAr => 'Minimum Amount (Ar)';

  @override
  String get maximumAmountAr => 'Maximum Amount (Ar)';

  @override
  String get feeAr => 'Fee (Ar)';

  @override
  String confirmDeleteIntervals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return 'Are you sure you want to delete $count selected interval$_temp0?';
  }

  @override
  String fieldIsRequired(String fieldName) {
    return '$fieldName is required';
  }

  @override
  String get mustBeGreaterThanZero => 'Must be greater than 0';

  @override
  String mustBeLessThanNCharacters(int count) {
    return 'Must be less than $count characters';
  }

  @override
  String get deleteCurrencies => 'Delete Currencies';

  @override
  String get currencyDeletedSuccessfully => 'Currency deleted successfully';

  @override
  String get currencies => 'Currencies';

  @override
  String get searchCurrencies => 'Search currencies...';

  @override
  String get noCurrenciesFound => 'No currencies found';

  @override
  String get centralizeCurrencies => 'Centralize your currencies in one place';

  @override
  String get addNewCurrency => 'Add new currency';

  @override
  String get newCurrency => 'New Currency';

  @override
  String get createNewCurrency => 'Create New Currency';

  @override
  String get currencyCode => 'Currency Code';

  @override
  String get currencyName => 'Currency Name';

  @override
  String get currencySymbolLabel => 'Currency Symbol';

  @override
  String get exchangeRate => 'Exchange Rate';

  @override
  String get currencyCreatedSuccessfully => 'Currency created successfully';

  @override
  String get manageYourCurrencies => 'Manage your currencies';

  @override
  String get totalCurrencies => 'Total Currencies';

  @override
  String get activeCurrencies => 'Active Currencies';

  @override
  String get editCurrency => 'Edit Currency';

  @override
  String get currencyUpdatedSuccessfully => 'Currency updated successfully';

  @override
  String get addNewCurrencyDescription =>
      'Add a new currency to your collection';

  @override
  String get currencyCodeMustBe3Characters =>
      'Currency code must be exactly 3 characters';

  @override
  String get currencyCodeMustContainOnlyUppercase =>
      'Currency code must contain only uppercase letters';

  @override
  String get pleaseEnterValidPositiveRate =>
      'Please enter a valid positive rate';

  @override
  String get failedToCreateCurrency => 'Failed to create currency';

  @override
  String get failedToUpdateCurrency => 'Failed to update currency';

  @override
  String get codeMustBe3Characters => 'Code must be 3 characters';

  @override
  String get invalidRate => 'Invalid rate';

  @override
  String get rateLabel => 'Rate:';

  @override
  String confirmDeleteCurrencies(int count) {
    return 'Are you sure you want to delete $count currencies?';
  }

  @override
  String operationCount(int count) {
    return '$count operations';
  }

  @override
  String get optimizationFailedNoValidSolution =>
      'Optimization failed: No valid solution found';

  @override
  String optimizationIncomplete(String percentage) {
    return 'Optimization incomplete: Only $percentage% of amount covered. Consider adjusting transaction limits or fee intervals.';
  }

  @override
  String amountExceedsMaximumLimit(String amount, String currency) {
    return 'Amount exceeds maximum limit ($amount $currency)';
  }

  @override
  String get failedToCalculateOptimization =>
      'Failed to calculate optimization';

  @override
  String get amountExceedsMaximumAllowedLimit =>
      'Amount exceeds maximum allowed limit';

  @override
  String get invalidTransactionRangeConstraints =>
      'Invalid transaction range constraints';

  @override
  String get noValidFeeIntervalsAvailable => 'No valid fee intervals available';
}
