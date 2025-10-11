import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_mg.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('mg'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Feezer'**
  String get appTitle;

  /// First onboarding screen title
  ///
  /// In en, this message translates to:
  /// **'Plan ahead and save on fees'**
  String get onboardingTitle1;

  /// First onboarding screen description
  ///
  /// In en, this message translates to:
  /// **'Calculate the most cost-efficient way to handle your money.'**
  String get onboardingDescription1;

  /// Second onboarding screen title
  ///
  /// In en, this message translates to:
  /// **'Optimize your transactions'**
  String get onboardingTitle2;

  /// Second onboarding screen description
  ///
  /// In en, this message translates to:
  /// **'Minimize fees automatically based on predefined intervals.'**
  String get onboardingDescription2;

  /// Third onboarding screen title
  ///
  /// In en, this message translates to:
  /// **'Save smart, spend better'**
  String get onboardingTitle3;

  /// Third onboarding screen description
  ///
  /// In en, this message translates to:
  /// **'Get personalized recommendations and make informed financial decisions instantly.'**
  String get onboardingDescription3;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Skip button text
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Get started button text
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Back button text
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Create button text
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Optimize fee screen title
  ///
  /// In en, this message translates to:
  /// **'Optimize Fee'**
  String get optimizeFee;

  /// Providers screen title
  ///
  /// In en, this message translates to:
  /// **'Providers'**
  String get providers;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Create interval button
  ///
  /// In en, this message translates to:
  /// **'Create Interval'**
  String get createInterval;

  /// Optimize button text
  ///
  /// In en, this message translates to:
  /// **'Optimize'**
  String get optimize;

  /// Amount label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Provider label
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get provider;

  /// Minimum transactions label
  ///
  /// In en, this message translates to:
  /// **'Min Transactions'**
  String get minTransactions;

  /// Maximum transactions label
  ///
  /// In en, this message translates to:
  /// **'Max Transactions'**
  String get maxTransactions;

  /// Error message for invalid amount
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get pleaseEnterValidAmount;

  /// Error message when no provider is selected
  ///
  /// In en, this message translates to:
  /// **'Please select a provider'**
  String get pleaseSelectProvider;

  /// Error message for invalid transaction range
  ///
  /// In en, this message translates to:
  /// **'Min transactions must be less than max transactions'**
  String get invalidTransactionRange;

  /// MVola provider name
  ///
  /// In en, this message translates to:
  /// **'MVola'**
  String get mvola;

  /// Orange Money provider name
  ///
  /// In en, this message translates to:
  /// **'Orange Money'**
  String get orangeMoney;

  /// Airtel Money provider name
  ///
  /// In en, this message translates to:
  /// **'Airtel Money'**
  String get airtelMoney;

  /// Mobile financial services description
  ///
  /// In en, this message translates to:
  /// **'Mobile financial services'**
  String get mobileFinancialServices;

  /// Appearance section title
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Theme setting
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// French language option
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// Malagasy language option
  ///
  /// In en, this message translates to:
  /// **'Malagasy'**
  String get malagasy;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// Coming soon message
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// Coming soon feature message
  ///
  /// In en, this message translates to:
  /// **'This feature will be available soon!'**
  String get thisFeatureWillBeAvailableSoon;

  /// Fee intervals section title
  ///
  /// In en, this message translates to:
  /// **'Fee intervals'**
  String get feeIntervals;

  /// New fee interval screen title
  ///
  /// In en, this message translates to:
  /// **'New Fee Interval'**
  String get newFeeInterval;

  /// Minimum amount label
  ///
  /// In en, this message translates to:
  /// **'Min Amount'**
  String get minAmount;

  /// Maximum amount label
  ///
  /// In en, this message translates to:
  /// **'Max Amount'**
  String get maxAmount;

  /// Fee percentage label
  ///
  /// In en, this message translates to:
  /// **'Fee Percentage'**
  String get feePercentage;

  /// Fixed fee label
  ///
  /// In en, this message translates to:
  /// **'Fixed Fee'**
  String get fixedFee;

  /// Validation message for minimum amount
  ///
  /// In en, this message translates to:
  /// **'Please enter minimum amount'**
  String get pleaseEnterMinAmount;

  /// Validation message for maximum amount
  ///
  /// In en, this message translates to:
  /// **'Please enter maximum amount'**
  String get pleaseEnterMaxAmount;

  /// Validation message for fee percentage
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid fee percentage'**
  String get pleaseEnterValidFeePercentage;

  /// Validation error for amount range
  ///
  /// In en, this message translates to:
  /// **'Max amount must be greater than min amount'**
  String get maxAmountMustBeGreaterThanMinAmount;

  /// Optimization results title
  ///
  /// In en, this message translates to:
  /// **'Optimization Results'**
  String get optimizationResults;

  /// Interval column header
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get interval;

  /// Fee column header
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get fee;

  /// Count column header
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get count;

  /// Total column header
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Transaction details section title
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetails;

  /// Currency symbol for Ariary
  ///
  /// In en, this message translates to:
  /// **'Ar'**
  String get currencySymbol;

  /// Total amount metric title
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// Net amount after fees metric title
  ///
  /// In en, this message translates to:
  /// **'Net Amount'**
  String get netAmount;

  /// Total fees metric title
  ///
  /// In en, this message translates to:
  /// **'Total Fees'**
  String get totalFees;

  /// Optimization efficiency metric title
  ///
  /// In en, this message translates to:
  /// **'Efficiency'**
  String get efficiency;

  /// Number of operations metric title
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get operations;

  /// Remaining amount metric title
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// Message when no optimization results are found for the given parameters
  ///
  /// In en, this message translates to:
  /// **'No optimization results found. Please check your input parameters.'**
  String get noOptimizationResultsFound;

  /// Instructions for getting results
  ///
  /// In en, this message translates to:
  /// **'Tap \'Optimize\' to see results'**
  String get tapOptimizeToSeeResults;

  /// Error title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Error message for route not found
  ///
  /// In en, this message translates to:
  /// **'Screen {route} not found'**
  String screenNotFound(String route);

  /// Go to home screen button
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHome;

  /// Message shown when no providers are available
  ///
  /// In en, this message translates to:
  /// **'No providers found'**
  String get noProvidersFound;

  /// Placeholder text for provider search field
  ///
  /// In en, this message translates to:
  /// **'Search providers...'**
  String get searchProviders;

  /// Header title for provider management section
  ///
  /// In en, this message translates to:
  /// **'Manage your providers'**
  String get manageYourProviders;

  /// Description for provider management functionality
  ///
  /// In en, this message translates to:
  /// **'Centralize bank and mobile money partners in one place.'**
  String get centralizeProviders;

  /// Label for single active provider count
  ///
  /// In en, this message translates to:
  /// **'Active provider'**
  String get activeProvider;

  /// Label for multiple active providers count
  ///
  /// In en, this message translates to:
  /// **'Active providers'**
  String get activeProviders;

  /// Confirmation message for deleting a single provider
  ///
  /// In en, this message translates to:
  /// **'Delete this provider?'**
  String get deleteThisProvider;

  /// Confirmation message for deleting multiple providers
  ///
  /// In en, this message translates to:
  /// **'Delete {count} providers?'**
  String deleteProvidersCount(int count);

  /// Title for delete provider dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Provider'**
  String get deleteProvider;

  /// Title for delete multiple providers dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Providers'**
  String get deleteProviders;

  /// Success message after deleting provider(s)
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 provider deleted successfully} other{{count} providers deleted successfully}}'**
  String providerDeletedSuccessfully(num count);

  /// Title for edit provider bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Edit Provider'**
  String get editProvider;

  /// Label for provider name field
  ///
  /// In en, this message translates to:
  /// **'Provider Name'**
  String get providerName;

  /// Label for description field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Title for new provider screen
  ///
  /// In en, this message translates to:
  /// **'New Provider'**
  String get newProvider;

  /// Header title for creating a new provider
  ///
  /// In en, this message translates to:
  /// **'Create New Provider'**
  String get createNewProvider;

  /// Hint text for provider name field
  ///
  /// In en, this message translates to:
  /// **'Enter provider name'**
  String get enterProviderName;

  /// Success message when a provider is created
  ///
  /// In en, this message translates to:
  /// **'Provider created successfully'**
  String get providerCreatedSuccessfully;

  /// System default language option
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// General settings section
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// About section
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// FAQ and contact option
  ///
  /// In en, this message translates to:
  /// **'FAQ and contact'**
  String get faqAndContact;

  /// Terms of use option
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// Terms and privacy policy description
  ///
  /// In en, this message translates to:
  /// **'Terms and privacy policy'**
  String get termsAndPrivacyPolicy;

  /// Message for upcoming features
  ///
  /// In en, this message translates to:
  /// **'Feature coming in the next version'**
  String get featureComingNextVersion;

  /// Financial provider section title
  ///
  /// In en, this message translates to:
  /// **'Financial Provider'**
  String get financialProvider;

  /// Instructions for provider selection
  ///
  /// In en, this message translates to:
  /// **'Choose the provider you want to analyze'**
  String get chooseProviderToAnalyze;

  /// Title for amount optimization section
  ///
  /// In en, this message translates to:
  /// **'Amount to Optimize'**
  String get amountToOptimize;

  /// Instructions for amount input
  ///
  /// In en, this message translates to:
  /// **'Enter the transaction amount you want to optimize'**
  String get enterTransactionAmountToOptimize;

  /// Transaction range section title
  ///
  /// In en, this message translates to:
  /// **'Transaction Range'**
  String get transactionRange;

  /// Instructions for transaction range
  ///
  /// In en, this message translates to:
  /// **'Define the minimum and maximum number of transactions'**
  String get defineMinMaxTransactions;

  /// Ready to optimize message
  ///
  /// In en, this message translates to:
  /// **'Ready to Optimize'**
  String get readyToOptimize;

  /// Instructions for optimization
  ///
  /// In en, this message translates to:
  /// **'Click the Optimize button to analyze the best fee structure for your transactions'**
  String get clickOptimizeButtonToAnalyze;

  /// Provider details screen title
  ///
  /// In en, this message translates to:
  /// **'Provider details'**
  String get providerDetails;

  /// Message when no fee intervals exist
  ///
  /// In en, this message translates to:
  /// **'No fee intervals found'**
  String get noFeeIntervalsFound;

  /// Fee interval column header
  ///
  /// In en, this message translates to:
  /// **'Fee interval'**
  String get feeInterval;

  /// Search by fee range placeholder
  ///
  /// In en, this message translates to:
  /// **'Search by Fee Range'**
  String get searchByFeeRange;

  /// Add fee interval button
  ///
  /// In en, this message translates to:
  /// **'Add Fee Interval'**
  String get addFeeInterval;

  /// Minimum fee placeholder
  ///
  /// In en, this message translates to:
  /// **'Min fee'**
  String get minFee;

  /// Maximum fee placeholder
  ///
  /// In en, this message translates to:
  /// **'Max fee'**
  String get maxFee;

  /// Delete fee intervals title
  ///
  /// In en, this message translates to:
  /// **'Delete Fee Intervals'**
  String get deleteFeeIntervals;

  /// Create new fee interval header
  ///
  /// In en, this message translates to:
  /// **'Create New Fee Interval'**
  String get createNewFeeInterval;

  /// Fee interval creation instructions
  ///
  /// In en, this message translates to:
  /// **'Define a new fee structure for transaction amounts'**
  String get defineNewFeeStructure;

  /// Minimum amount input placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter minimum amount'**
  String get enterMinimumAmount;

  /// Maximum amount input placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter maximum amount'**
  String get enterMaximumAmount;

  /// Fee amount input placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter fee amount'**
  String get enterFeeAmount;

  /// Validation message for amount range
  ///
  /// In en, this message translates to:
  /// **'Max amount must be greater than min amount'**
  String get maxAmountMustBeGreater;

  /// Success message for fee interval creation
  ///
  /// In en, this message translates to:
  /// **'Fee interval created successfully'**
  String get feeIntervalCreatedSuccessfully;

  /// Description for adding new provider
  ///
  /// In en, this message translates to:
  /// **'Add a new financial service provider to your list'**
  String get addNewFinancialServiceProvider;

  /// Description input placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter description'**
  String get enterDescription;

  /// Create provider button
  ///
  /// In en, this message translates to:
  /// **'Create Provider'**
  String get createProvider;

  /// Clear selection tooltip
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get clearSelection;

  /// Select all tooltip
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// Icon label
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// Icon selection instruction
  ///
  /// In en, this message translates to:
  /// **'Tap to select icon'**
  String get tapToSelectIcon;

  /// Clear search tooltip
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// Select icon dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Icon'**
  String get selectIcon;

  /// Required field validation message
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get thisFieldIsRequired;

  /// Double back to exit message
  ///
  /// In en, this message translates to:
  /// **'Press again to exit'**
  String get pressAgainToExit;

  /// Provider update success message
  ///
  /// In en, this message translates to:
  /// **'Provider updated successfully'**
  String get providerUpdatedSuccessfully;

  /// Fee interval update success message
  ///
  /// In en, this message translates to:
  /// **'Fee interval updated successfully'**
  String get feeIntervalUpdatedSuccessfully;

  /// Fee interval deletion success message
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 fee interval deleted successfully} other{{count} fee intervals deleted successfully}}'**
  String feeIntervalDeletedSuccessfully(num count);

  /// Edit fee interval dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit Fee Interval'**
  String get editFeeInterval;

  /// Validation error for transaction range
  ///
  /// In en, this message translates to:
  /// **'Min transactions cannot be greater than max'**
  String get minTransactionsCannotBeGreaterThanMax;

  /// Validation error for fee field
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid fee'**
  String get pleaseEnterValidFee;

  /// Validation error for minimum length
  ///
  /// In en, this message translates to:
  /// **'Must be at least {count} characters'**
  String mustBeAtLeastNCharacters(int count);

  /// Validation error for numeric fields
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get enterValidNumber;

  /// Validation error for fee amount field
  ///
  /// In en, this message translates to:
  /// **'Please enter fee amount'**
  String get pleaseEnterFeeAmount;

  /// Details tooltip
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// Minimum amount validation field name
  ///
  /// In en, this message translates to:
  /// **'Minimum amount'**
  String get minimumAmount;

  /// Maximum amount validation field name
  ///
  /// In en, this message translates to:
  /// **'Maximum amount'**
  String get maximumAmount;

  /// Fee amount validation field name
  ///
  /// In en, this message translates to:
  /// **'Fee amount'**
  String get feeAmount;

  /// Traditional banking description
  ///
  /// In en, this message translates to:
  /// **'Traditional banking'**
  String get traditionalBanking;

  /// Mobile money description
  ///
  /// In en, this message translates to:
  /// **'Mobile money'**
  String get mobileMoney;

  /// Selected items text
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get selected;

  /// Fee optimizer button text
  ///
  /// In en, this message translates to:
  /// **'Fee Optimizer'**
  String get feeOptimizer;

  /// Total fee intervals label
  ///
  /// In en, this message translates to:
  /// **'Total Fee Intervals'**
  String get totalFeeIntervals;

  /// Help and support menu item
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// Add new provider button text
  ///
  /// In en, this message translates to:
  /// **'Add new provider'**
  String get addNewProvider;

  /// Search range adjustment message
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search range'**
  String get tryAdjustingYourSearchRange;

  /// Choose theme dialog title
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get chooseTheme;

  /// Light theme description
  ///
  /// In en, this message translates to:
  /// **'Always use light theme'**
  String get alwaysUseLightTheme;

  /// Dark theme description
  ///
  /// In en, this message translates to:
  /// **'Always use dark theme'**
  String get alwaysUseDarkTheme;

  /// System theme description
  ///
  /// In en, this message translates to:
  /// **'Follow system settings'**
  String get followSystemSettings;

  /// Save changes button text
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// Minimum amount field label with currency
  ///
  /// In en, this message translates to:
  /// **'Minimum Amount (Ar)'**
  String get minimumAmountAr;

  /// Maximum amount field label with currency
  ///
  /// In en, this message translates to:
  /// **'Maximum Amount (Ar)'**
  String get maximumAmountAr;

  /// Fee field label with currency
  ///
  /// In en, this message translates to:
  /// **'Fee (Ar)'**
  String get feeAr;

  /// Confirmation message for deleting fee intervals
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {count} selected interval{count, plural, =1{} other{s}}?'**
  String confirmDeleteIntervals(int count);

  /// Validation error for required field with field name
  ///
  /// In en, this message translates to:
  /// **'{fieldName} is required'**
  String fieldIsRequired(String fieldName);

  /// Validation error for positive numbers
  ///
  /// In en, this message translates to:
  /// **'Must be greater than 0'**
  String get mustBeGreaterThanZero;

  /// Validation error for maximum length
  ///
  /// In en, this message translates to:
  /// **'Must be less than {count} characters'**
  String mustBeLessThanNCharacters(int count);

  /// Title for delete currencies confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Currencies'**
  String get deleteCurrencies;

  /// Success message when currency is deleted
  ///
  /// In en, this message translates to:
  /// **'Currency deleted successfully'**
  String get currencyDeletedSuccessfully;

  /// Title for currencies screen
  ///
  /// In en, this message translates to:
  /// **'Currencies'**
  String get currencies;

  /// Placeholder text for currency search field
  ///
  /// In en, this message translates to:
  /// **'Search currencies...'**
  String get searchCurrencies;

  /// Message when no currencies are found
  ///
  /// In en, this message translates to:
  /// **'No currencies found'**
  String get noCurrenciesFound;

  /// Description text for empty currencies state
  ///
  /// In en, this message translates to:
  /// **'Centralize your currencies in one place'**
  String get centralizeCurrencies;

  /// Button text to add a new currency
  ///
  /// In en, this message translates to:
  /// **'Add new currency'**
  String get addNewCurrency;

  /// Title for new currency screen
  ///
  /// In en, this message translates to:
  /// **'New Currency'**
  String get newCurrency;

  /// Header text for new currency creation
  ///
  /// In en, this message translates to:
  /// **'Create New Currency'**
  String get createNewCurrency;

  /// Label for currency code field
  ///
  /// In en, this message translates to:
  /// **'Currency Code'**
  String get currencyCode;

  /// Label for currency name field
  ///
  /// In en, this message translates to:
  /// **'Currency Name'**
  String get currencyName;

  /// Label for currency symbol field
  ///
  /// In en, this message translates to:
  /// **'Currency Symbol'**
  String get currencySymbolLabel;

  /// Label for exchange rate field
  ///
  /// In en, this message translates to:
  /// **'Exchange Rate'**
  String get exchangeRate;

  /// Success message when currency is created
  ///
  /// In en, this message translates to:
  /// **'Currency created successfully'**
  String get currencyCreatedSuccessfully;

  /// Header text for currency management
  ///
  /// In en, this message translates to:
  /// **'Manage your currencies'**
  String get manageYourCurrencies;

  /// Label for total currencies count
  ///
  /// In en, this message translates to:
  /// **'Total Currencies'**
  String get totalCurrencies;

  /// Label for active currencies count
  ///
  /// In en, this message translates to:
  /// **'Active Currencies'**
  String get activeCurrencies;

  /// Title for edit currency bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Edit Currency'**
  String get editCurrency;

  /// Success message when currency is updated
  ///
  /// In en, this message translates to:
  /// **'Currency updated successfully'**
  String get currencyUpdatedSuccessfully;

  /// Description text for adding new currency
  ///
  /// In en, this message translates to:
  /// **'Add a new currency to your collection'**
  String get addNewCurrencyDescription;

  /// Validation message for currency code length
  ///
  /// In en, this message translates to:
  /// **'Currency code must be exactly 3 characters'**
  String get currencyCodeMustBe3Characters;

  /// Validation message for currency code format
  ///
  /// In en, this message translates to:
  /// **'Currency code must contain only uppercase letters'**
  String get currencyCodeMustContainOnlyUppercase;

  /// Validation message for exchange rate
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid positive rate'**
  String get pleaseEnterValidPositiveRate;

  /// Error message when currency creation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to create currency'**
  String get failedToCreateCurrency;

  /// Error message when currency update fails
  ///
  /// In en, this message translates to:
  /// **'Failed to update currency'**
  String get failedToUpdateCurrency;

  /// Short validation message for currency code length
  ///
  /// In en, this message translates to:
  /// **'Code must be 3 characters'**
  String get codeMustBe3Characters;

  /// Validation message for invalid exchange rate
  ///
  /// In en, this message translates to:
  /// **'Invalid rate'**
  String get invalidRate;

  /// Label for exchange rate display in currency card
  ///
  /// In en, this message translates to:
  /// **'Rate:'**
  String get rateLabel;

  /// Confirmation message for deleting currencies
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {count} currencies?'**
  String confirmDeleteCurrencies(int count);

  /// Display text for number of operations with count
  ///
  /// In en, this message translates to:
  /// **'{count} operations'**
  String operationCount(int count);

  /// Error message when optimization fails to find a valid solution
  ///
  /// In en, this message translates to:
  /// **'Optimization failed: No valid solution found'**
  String get optimizationFailedNoValidSolution;

  /// Warning message when optimization covers less than expected amount
  ///
  /// In en, this message translates to:
  /// **'Optimization incomplete: Only {percentage}% of amount covered. Consider adjusting transaction limits or fee intervals.'**
  String optimizationIncomplete(String percentage);

  /// Error message when amount exceeds the maximum allowed limit
  ///
  /// In en, this message translates to:
  /// **'Amount exceeds maximum limit ({amount} {currency})'**
  String amountExceedsMaximumLimit(String amount, String currency);

  /// Generic error message when optimization calculation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to calculate optimization'**
  String get failedToCalculateOptimization;

  /// Error message for amount exceeding maximum allowed limit
  ///
  /// In en, this message translates to:
  /// **'Amount exceeds maximum allowed limit'**
  String get amountExceedsMaximumAllowedLimit;

  /// Error message for invalid transaction range constraints
  ///
  /// In en, this message translates to:
  /// **'Invalid transaction range constraints'**
  String get invalidTransactionRangeConstraints;

  /// Error message when no valid fee intervals are available for the provider
  ///
  /// In en, this message translates to:
  /// **'No valid fee intervals available'**
  String get noValidFeeIntervalsAvailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr', 'mg'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'mg':
      return AppLocalizationsMg();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
