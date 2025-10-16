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
  String get onboardingTitle1 => 'Stop Losing Money to Mobile Money Fees';

  @override
  String get onboardingDescription1 =>
      'Mobile money fees can add up quickly. Feezer helps you minimize costs on every transaction.';

  @override
  String get onboardingTitle2 => 'Smart Mobile Money Optimization';

  @override
  String get onboardingDescription2 =>
      'Automatically calculate the most cost-effective way to handle your mobile money transfers and payments.';

  @override
  String get onboardingTitle3 => 'Save More on Mobile Transactions';

  @override
  String get onboardingDescription3 =>
      'Get personalized mobile money fee optimization strategies and watch your savings grow with every transaction.';

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
  String get totalFees => 'Total fees';

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
  String get deleteProviderWarning =>
      'This will also delete all associated fee intervals.';

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
  String get termsIntroductionTitle => 'Introduction';

  @override
  String get termsIntroductionContent =>
      'Welcome to Feezer! These Terms of Use govern your use of our mobile application designed to help you minimize mobile money fees. By using Feezer, you agree to be bound by these terms. Please read them carefully before using our service.';

  @override
  String get termsAcceptanceTitle => 'Acceptance of Terms';

  @override
  String get termsAcceptanceContent =>
      'By accessing and using Feezer, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.';

  @override
  String get termsResponsibilitiesTitle => 'User Responsibilities';

  @override
  String get termsResponsibilitiesContent =>
      'You are responsible for maintaining the confidentiality of your account information and for all activities that occur under your account. You agree to provide accurate and complete information when using our service and to update this information as necessary. You must ensure that you comply with the terms and conditions of your mobile money service provider.';

  @override
  String get termsServiceTitle => 'Service Description';

  @override
  String get termsServiceContent =>
      'Feezer is a fee minimization tool that helps you calculate and optimize mobile money transaction costs. Our service provides fee calculations, transaction optimization suggestions, and educational content about mobile money fees. We strive to provide accurate information, but all calculations are estimates and should be verified with your mobile money service provider.';

  @override
  String get termsPrivacyTitle => 'Privacy and Data Protection';

  @override
  String get termsPrivacyContent =>
      'Your privacy is important to us. Feezer collects minimal personal information necessary to provide our service. We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in our Privacy Policy. We implement appropriate security measures to protect your data against unauthorized access.';

  @override
  String get termsLiabilityTitle => 'Limitation of Liability';

  @override
  String get termsLiabilityContent =>
      'Feezer provides fee calculation services for informational purposes only. We are not responsible for any financial losses, damages, or decisions made based on the information provided by our application. Users should always verify calculations with their mobile money service provider and understand the fees charged by their provider. We are not affiliated with any mobile money service provider.';

  @override
  String get termsTerminationTitle => 'Termination';

  @override
  String get termsTerminationContent =>
      'We reserve the right to terminate or suspend your account and access to our service at our sole discretion, without prior notice, for conduct that we believe violates these Terms of Use or is harmful to other users, us, or third parties, or for any other reason.';

  @override
  String get termsGoverningLawTitle => 'Governing Law';

  @override
  String get termsGoverningLawContent =>
      'These Terms of Use shall be governed by and construed in accordance with the laws of the jurisdiction in which our service operates. Any disputes arising from these terms shall be resolved through appropriate legal channels in accordance with applicable local laws.';

  @override
  String get termsContactTitle => 'Contact Information';

  @override
  String get termsContactContent =>
      'If you have any questions about these Terms of Use, please contact us through the app\'s support section or via email at elsy.s.charles@gmail.com. We will respond to your inquiries as quickly as possible.';

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

  @override
  String get amountMustBePositive => 'Amount must be positive';

  @override
  String get amountTooHigh => 'Amount too high';

  @override
  String get noOptionsAvailable => 'No options available';

  @override
  String get maxOperationsMustBePositive => 'maxOperations must be >= 0';

  @override
  String get minOperationsMustBePositive => 'minOperations must be >= 0';

  @override
  String get minOperationsCannotBeGreaterThanMaxOperations =>
      'minOperations cannot be greater than maxOperations';

  @override
  String get importExportData => 'Import/Export Data';

  @override
  String get csvImportExportInfo => 'CSV Data Management';

  @override
  String get csvImportExportDescription =>
      'Import or export your providers and fee intervals using CSV files';

  @override
  String get importData => 'Import Data';

  @override
  String get exportData => 'Export Data';

  @override
  String get templates => 'CSV Templates';

  @override
  String get exportCombined => 'Export Combined';

  @override
  String get exportCombinedDescription =>
      'Export providers with their fee intervals';

  @override
  String get downloadProviderTemplate => 'Provider Template';

  @override
  String get csvTemplateForProviders =>
      'Download CSV template for importing providers';

  @override
  String get downloadFeeTemplate => 'Fee Intervals Template';

  @override
  String get csvTemplateForFees => 'Download CSV template for importing fees';

  @override
  String get downloadCombinedTemplate => 'Combined Template';

  @override
  String get csvTemplateForCombined =>
      'Download CSV template for combined import';

  @override
  String get importSuccessful => 'Import Successful';

  @override
  String importFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get exportSuccessful => 'Export successful';

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get templateDownloaded => 'Template Downloaded';

  @override
  String get failedToDownloadTemplate => 'Failed to download template';

  @override
  String get failedToReadFile => 'Failed to read file';

  @override
  String providersImported(int count) {
    return '$count provider(s) imported';
  }

  @override
  String feeIntervalsImported(int count) {
    return '$count fee interval(s) imported';
  }

  @override
  String errorsEncountered(int count) {
    return '$count error(s) encountered';
  }

  @override
  String get dataManagement => 'Data Management';

  @override
  String get backup => 'Backup';

  @override
  String get backupYourData => 'Backup your providers and fees';

  @override
  String get reset => 'Reset';

  @override
  String get clearAllData => 'Clear all data';

  @override
  String get confirmReset => 'Confirm Reset';

  @override
  String get resetWarningMessage =>
      'This will permanently delete all your providers and fee intervals. This action cannot be undone.';

  @override
  String get dataResetSuccessful => 'Data reset successful';

  @override
  String get resetFailed => 'Reset failed';

  @override
  String get csvManagement => 'CSV Management';

  @override
  String get previewTemplate => 'Preview Template';

  @override
  String get preview => 'Preview';

  @override
  String get download => 'Download';

  @override
  String get templatePreview => 'Template Preview';

  @override
  String get close => 'Close';

  @override
  String get importDataDescription =>
      'Import providers and fee intervals from CSV file. The system will automatically detect the data type based on columns.';

  @override
  String get exportDataDescription =>
      'Export all providers and their fee intervals to a combined CSV file.';

  @override
  String get csvContentCannotBeEmpty => 'CSV content cannot be empty';

  @override
  String get clickImportToSelectFile => 'Click to select a CSV file';

  @override
  String get copy => 'Copy';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get chooseWhereToSave => 'Choose where to save the file';

  @override
  String get fileSavedSuccessfully => 'File saved successfully';

  @override
  String get failedToSaveFile => 'Failed to save file';

  @override
  String get file => 'File';

  @override
  String get text => 'Text';

  @override
  String get pasteCsvContentHere => 'Paste your CSV content here...';

  @override
  String get fileSelected => 'File Selected';

  @override
  String get csvFilesOnly => 'CSV files only';

  @override
  String get csvContentPreview => 'CSV Content Preview:';

  @override
  String get failedToSelectFile => 'Failed to select file';

  @override
  String get failedToPreviewTemplate => 'Failed to preview template';

  @override
  String get csvFileIsEmpty => 'CSV file is empty';

  @override
  String get noDataRowsFound => 'No data rows found';

  @override
  String rowProviderNameRequired(int rowNumber) {
    return 'Row $rowNumber: Provider name is required';
  }

  @override
  String rowProviderAlreadyExists(int rowNumber, String name) {
    return 'Row $rowNumber: Provider \"$name\" already exists';
  }

  @override
  String rowGenericError(int rowNumber, String error) {
    return 'Row $rowNumber: $error';
  }

  @override
  String rowProviderNameRequiredFee(int rowNumber) {
    return 'Row $rowNumber: Provider name is required';
  }

  @override
  String rowProviderNotFound(int rowNumber, String providerName) {
    return 'Row $rowNumber: Provider \"$providerName\" not found';
  }

  @override
  String rowIntervalOverlaps(int rowNumber, String overlap) {
    return 'Row $rowNumber: Interval overlaps with existing interval ($overlap)';
  }

  @override
  String rowInvalidAmounts(
    int rowNumber,
    String minStr,
    String maxStr,
    String feeStr,
  ) {
    return 'Row $rowNumber: Invalid amounts (min: $minStr, max: $maxStr, fee: $feeStr)';
  }

  @override
  String rowMinAmountGreaterThanMax(int rowNumber, String min, String max) {
    return 'Row $rowNumber: Min amount ($min) must be less than max amount ($max)';
  }

  @override
  String rowFeeMustBePositive(int rowNumber) {
    return 'Row $rowNumber: Fee must be positive';
  }

  @override
  String rowFeePercentageInvalid(int rowNumber, String fee) {
    return 'Row $rowNumber: Percentage fee must be between 0 and 100 ($fee%)';
  }

  @override
  String importedProvidersAndFees(int providersCount, int feesCount) {
    return 'Imported $providersCount provider(s) and $feesCount fee interval(s)';
  }

  @override
  String providerInvalidProviderId(String providerName) {
    return 'Provider \"$providerName\": Invalid provider ID';
  }

  @override
  String providerNoFeeIntervals(String providerName) {
    return 'Provider \"$providerName\": No fee intervals found';
  }

  @override
  String providerImportError(String providerName, String error) {
    return 'Provider \"$providerName\": $error';
  }

  @override
  String rowIntervalOverlapsCombined(int rowNumber, String overlap) {
    return 'Row $rowNumber: Interval overlaps with existing interval ($overlap)';
  }

  @override
  String get noDataToExport => 'No data to export';

  @override
  String get providerNameColumnNotFound => 'Provider name column not found';

  @override
  String get pullToRefresh => 'Pull down to refresh';

  @override
  String get refreshing => 'Refreshing...';

  @override
  String get feeType => 'Fee Type';

  @override
  String get fixedAmount => 'Fixed Amount';

  @override
  String get percentage => 'Percentage';

  @override
  String get enterPercentage => 'Enter percentage';

  @override
  String get percentageMustBeBetween0And100 =>
      'Percentage must be between 0 and 100';

  @override
  String get invalidAmount => 'Invalid amount';

  @override
  String get pleaseEnterPercentage => 'Please enter percentage';

  @override
  String get pleaseEnterValidPercentage => 'Please enter a valid percentage';

  @override
  String get percentageCannotExceed100 => 'Percentage cannot exceed 100';

  @override
  String get searchHelpTopics => 'Search help topics...';

  @override
  String get faq => 'FAQ';

  @override
  String get contact => 'Contact';

  @override
  String get faqWhatIsFeeMinimizer => 'What is Feezer or Fee Minimizer?';

  @override
  String get faqWhatIsFeeMinimizerAnswer =>
      'Feezer or Fee Minimizer is a mobile application that helps users calculate and optimize transaction fees across different financial providers. It analyzes your transaction details and suggests the most cost-effective options to minimize mobile money fees.';

  @override
  String get faqHowToAddProvider => 'How do I add a new provider?';

  @override
  String get faqHowToAddProviderAnswer =>
      'To add a new provider, go to the Providers screen and tap the \'+\' button. Fill in the provider details including name, description, and fee structure. You can also import provider data using CSV files. There are no favorite providers - you have full control to add and remove providers as needed.';

  @override
  String get faqHowToCalculateFees => 'How does fee calculation work?';

  @override
  String get faqHowToCalculateFeesAnswer =>
      'Enter your transaction amount and select a provider. The app will calculate all applicable fees including fixed fees, percentage fees, and minimum/maximum fees. It then shows you the total cost and suggests optimizations.';

  @override
  String get faqMinMaxTransactionRange =>
      'What do \'Min transactions\' and \'Max transactions\' mean?';

  @override
  String get faqMinMaxTransactionRangeAnswer =>
      '\'Min transactions\' and \'Max transactions\' set the minimum and maximum number of operations the optimizer may use to split your entered amount. For example, if you enter 10,000 Ar and set Min transactions = 2, the optimizer will only consider solutions that split the amount into at least 2 operations. Ensure Min ≤ Max and that the values make sense for your intended split. This constrains the optimizer to produce results with a number of transactions within the specified range.';

  @override
  String get faqDataSecurity => 'Is my data secure?';

  @override
  String get faqDataSecurityAnswer =>
      'Your financial data is stored locally on your device without encryption or additional security measures. This app does not provide financial-level security features. All data remains on your device and is not transmitted anywhere.';

  @override
  String get faqOfflineMode => 'Does the app work offline?';

  @override
  String get faqOfflineModeAnswer =>
      'Yes, Feezer or Fee Minimizer works completely offline. All your data and calculations are stored locally on your device. You can use all features without an internet connection.';

  @override
  String get faqCurrencyRates => 'How do currency exchange rates work?';

  @override
  String get faqCurrencyRatesAnswer =>
      'The app does not automatically update currency exchange rates. You have full control and can manually set your own exchange rates for complete customization. This gives you total flexibility to use rates that suit your needs, and works perfectly offline.';

  @override
  String get faqExportData => 'How do I export my data?';

  @override
  String get faqExportDataAnswer =>
      'Go to Settings > Data Management > CSV Management. You can export providers, currencies, and fee intervals as CSV files. These can be used for backup or to import into other instances of the app.';

  @override
  String get emailSupport => 'Email Support';

  @override
  String get phoneSupport => 'Phone Support';

  @override
  String get website => 'Website';

  @override
  String get responseTime => 'Response Time';

  @override
  String get responseTimeDescription =>
      'We typically respond to support requests within 24 hours during business days.';

  @override
  String get gettingStarted => 'Getting Started';

  @override
  String get gettingStartedDescription =>
      'Learn the basics of using Feezer or Fee Minimizer';

  @override
  String get providerManagement => 'Provider Management';

  @override
  String get providerManagementDescription =>
      'How to add, edit, and manage financial providers';

  @override
  String get feeCalculation => 'Fee Calculation';

  @override
  String get feeCalculationDescription =>
      'Understanding how fees are calculated and optimized';

  @override
  String get dataManagementDescription =>
      'Import, export, and backup your data';

  @override
  String get videoTutorials => 'Video Tutorials';

  @override
  String get videoTutorialsDescription =>
      'Watch step-by-step video guides to master Feezer or Fee Minimizer';

  @override
  String get watchTutorials => 'Watch Tutorials';

  @override
  String get shareYourThoughts => 'Share Your Thoughts';

  @override
  String get feedbackDescription =>
      'Help us improve Feezer or Fee Minimizer by sharing your feedback and suggestions';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get contactDescription =>
      'Get in touch with our support team for help with any questions or issues.';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get faqQuestion1 => 'How do I minimize transaction fees?';

  @override
  String get faqAnswer1 =>
      'Our app automatically calculates the most cost-effective way to handle your transactions by comparing different providers and payment methods.';

  @override
  String get faqQuestion2 => 'What currencies are supported?';

  @override
  String get faqAnswer2 =>
      'We support all major world currencies including USD, EUR, GBP, JPY, and many others. The app automatically handles currency conversion rates.';

  @override
  String get faqQuestion3 => 'Is my financial data secure?';

  @override
  String get faqAnswer3 =>
      'Yes, we use bank-level encryption and security measures. Your data is never stored on our servers and all calculations are done locally on your device.';

  @override
  String get faqQuestion4 => 'How do I update currency rates?';

  @override
  String get faqAnswer4 =>
      'Currency rates are automatically updated in real-time from reliable financial data providers. You can also manually refresh rates in the settings.';

  @override
  String get faqQuestion5 => 'Can I save my favorite providers?';

  @override
  String get faqAnswer5 =>
      'Yes, you can save your preferred mobile money providers and payment methods for quick access when making new calculations.';

  @override
  String get faqQuestion6 => 'How do I add a new provider?';

  @override
  String get faqAnswer6 =>
      'Tap the \'+\' button in the provider list screen. Enter the provider name, description, and choose an icon. You can then add fee intervals for different transaction amounts.';

  @override
  String get faqQuestion7 => 'What are fee intervals?';

  @override
  String get faqAnswer7 =>
      'Fee intervals define the cost structure for each provider. You can set fixed fees (e.g., \$2.50) or percentage fees (e.g., 1.5%) for different transaction amount ranges.';

  @override
  String get faqQuestion8 => 'How does the optimization work?';

  @override
  String get faqAnswer8 =>
      'Feezer analyzes all your providers\' fee structures and calculates the optimal way to split your transaction into multiple operations to minimize total fees while respecting your constraints.';

  @override
  String get comparisonWithWithoutOptimization =>
      'Comparison with/without optimization';

  @override
  String get withOptimization => 'With optimization';

  @override
  String get withoutOptimizationMaxAmount =>
      'Without optimization (max amount)';

  @override
  String get withoutOptimizationSameNet =>
      'Without optimization (same net amount)';

  @override
  String get enteredAmount => 'Entered amount';

  @override
  String get netAmountSent => 'Net amount';

  @override
  String get totalSpent => 'Total spent';

  @override
  String get numberOfOperations => 'Number of operations';

  @override
  String youLoseAmount(String amount, String currency) {
    return 'You lose $amount $currency';
  }

  @override
  String youGainAmount(String amount, String currency) {
    return 'You gain $amount $currency';
  }

  @override
  String get sameResultAsOptimization => 'Same result as optimization';

  @override
  String netAmountLess(String amount, String currency) {
    return '• Net amount less: $amount $currency';
  }

  @override
  String netAmountMore(String amount, String currency) {
    return '• Net amount more: $amount $currency';
  }

  @override
  String feesLess(String amount, String currency) {
    return '• Fees less: $amount $currency';
  }

  @override
  String feesMore(String amount, String currency) {
    return '• Fees more: $amount $currency';
  }

  @override
  String optimizationCostsMoreFees(String amount, String currency) {
    return 'Optimization costs $amount $currency more in fees';
  }

  @override
  String dueToTransactionConstraints(String min, String max) {
    return '• This is due to transaction constraints (min: $min, max: $max)';
  }

  @override
  String get exceedsEnteredAmount => 'Exceeds entered amount';

  @override
  String youSaveFees(String amount, String currency) {
    return 'You save $amount $currency in fees';
  }

  @override
  String totalSavingsWithOptimization(String amount, String currency) {
    return 'Total savings with optimization: $amount $currency';
  }

  @override
  String transactionGainsVsOptimized(String amount, String currency) {
    return 'This transaction gains $amount $currency compared to optimization';
  }

  @override
  String transactionLosesVsOptimized(String amount, String currency) {
    return 'This transaction loses $amount $currency compared to optimization';
  }

  @override
  String get transactionSameResultAsOptimized =>
      'This transaction has the same result as optimization';

  @override
  String get noValidIntervalForComparison =>
      'The entered amount is not within any valid fee interval. Unable to perform comparison without optimization.';
}
