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
  /// **'Stop Losing Money to Mobile Money Fees'**
  String get onboardingTitle1;

  /// First onboarding screen description
  ///
  /// In en, this message translates to:
  /// **'Mobile money fees can add up quickly. Feezer helps you minimize costs on every transaction.'**
  String get onboardingDescription1;

  /// Second onboarding screen title
  ///
  /// In en, this message translates to:
  /// **'Smart Mobile Money Optimization'**
  String get onboardingTitle2;

  /// Second onboarding screen description
  ///
  /// In en, this message translates to:
  /// **'Automatically calculate the most cost-effective way to handle your mobile money transfers and payments.'**
  String get onboardingDescription2;

  /// Third onboarding screen title
  ///
  /// In en, this message translates to:
  /// **'Save More on Mobile Transactions'**
  String get onboardingTitle3;

  /// Third onboarding screen description
  ///
  /// In en, this message translates to:
  /// **'Get personalized mobile money fee optimization strategies and watch your savings grow with every transaction.'**
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

  /// Label for total fees in comparison
  ///
  /// In en, this message translates to:
  /// **'Total fees'**
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

  /// Warning message when deleting providers about fee intervals
  ///
  /// In en, this message translates to:
  /// **'This will also delete all associated fee intervals.'**
  String get deleteProviderWarning;

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

  /// Terms of use introduction section title
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get termsIntroductionTitle;

  /// Terms of use introduction section content
  ///
  /// In en, this message translates to:
  /// **'Welcome to Feezer! These Terms of Use govern your use of our mobile application designed to help you minimize banking fees. By using Feezer, you agree to be bound by these terms. Please read them carefully before using our service.'**
  String get termsIntroductionContent;

  /// Terms of use acceptance section title
  ///
  /// In en, this message translates to:
  /// **'Acceptance of Terms'**
  String get termsAcceptanceTitle;

  /// Terms of use acceptance section content
  ///
  /// In en, this message translates to:
  /// **'By accessing and using Feezer, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.'**
  String get termsAcceptanceContent;

  /// Terms of use user responsibilities section title
  ///
  /// In en, this message translates to:
  /// **'User Responsibilities'**
  String get termsResponsibilitiesTitle;

  /// Terms of use user responsibilities section content
  ///
  /// In en, this message translates to:
  /// **'You are responsible for maintaining the confidentiality of your account information and for all activities that occur under your account. You agree to provide accurate and complete information when using our service and to update this information as necessary.'**
  String get termsResponsibilitiesContent;

  /// Terms of use service description section title
  ///
  /// In en, this message translates to:
  /// **'Service Description'**
  String get termsServiceTitle;

  /// Terms of use service description section content
  ///
  /// In en, this message translates to:
  /// **'Feezer is a fee minimization tool that helps you calculate and optimize banking transaction costs. Our service provides fee calculations, transaction optimization suggestions, and educational content about banking fees. We strive to provide accurate information, but all calculations are estimates and should be verified with your financial institutions.'**
  String get termsServiceContent;

  /// Terms of use privacy section title
  ///
  /// In en, this message translates to:
  /// **'Privacy and Data Protection'**
  String get termsPrivacyTitle;

  /// Terms of use privacy section content
  ///
  /// In en, this message translates to:
  /// **'Your privacy is important to us. Feezer collects minimal personal information necessary to provide our service. We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in our Privacy Policy. We implement appropriate security measures to protect your data.'**
  String get termsPrivacyContent;

  /// Terms of use liability section title
  ///
  /// In en, this message translates to:
  /// **'Limitation of Liability'**
  String get termsLiabilityTitle;

  /// Terms of use liability section content
  ///
  /// In en, this message translates to:
  /// **'Feezer provides fee calculation services for informational purposes only. We are not responsible for any financial losses, damages, or decisions made based on the information provided by our application. Users should always verify calculations with their financial institutions and consult with financial advisors for important financial decisions.'**
  String get termsLiabilityContent;

  /// Terms of use termination section title
  ///
  /// In en, this message translates to:
  /// **'Termination'**
  String get termsTerminationTitle;

  /// Terms of use termination section content
  ///
  /// In en, this message translates to:
  /// **'We reserve the right to terminate or suspend your account and access to our service at our sole discretion, without prior notice, for conduct that we believe violates these Terms of Use or is harmful to other users, us, or third parties, or for any other reason.'**
  String get termsTerminationContent;

  /// Terms of use governing law section title
  ///
  /// In en, this message translates to:
  /// **'Governing Law'**
  String get termsGoverningLawTitle;

  /// Terms of use governing law section content
  ///
  /// In en, this message translates to:
  /// **'These Terms of Use shall be governed by and construed in accordance with the laws of the jurisdiction in which our service operates. Any disputes arising from these terms shall be resolved through binding arbitration in accordance with the rules of the appropriate arbitration association.'**
  String get termsGoverningLawContent;

  /// Terms of use contact section title
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get termsContactTitle;

  /// Terms of use contact section content
  ///
  /// In en, this message translates to:
  /// **'If you have any questions about these Terms of Use, please contact us through the app\'s support section or via email at elsy.s.charles@gmail.com. We will respond to your inquiries as quickly as possible.'**
  String get termsContactContent;

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

  /// Error message when amount is not positive
  ///
  /// In en, this message translates to:
  /// **'Amount must be positive'**
  String get amountMustBePositive;

  /// Error message when amount exceeds maximum allowed limit
  ///
  /// In en, this message translates to:
  /// **'Amount too high'**
  String get amountTooHigh;

  /// Error message when no fee options are available
  ///
  /// In en, this message translates to:
  /// **'No options available'**
  String get noOptionsAvailable;

  /// Error message when maxOperations is negative
  ///
  /// In en, this message translates to:
  /// **'maxOperations must be >= 0'**
  String get maxOperationsMustBePositive;

  /// Error message when minOperations is negative
  ///
  /// In en, this message translates to:
  /// **'minOperations must be >= 0'**
  String get minOperationsMustBePositive;

  /// Error message when minOperations is greater than maxOperations
  ///
  /// In en, this message translates to:
  /// **'minOperations cannot be greater than maxOperations'**
  String get minOperationsCannotBeGreaterThanMaxOperations;

  /// Import/Export data menu title
  ///
  /// In en, this message translates to:
  /// **'Import/Export Data'**
  String get importExportData;

  /// CSV import/export information title
  ///
  /// In en, this message translates to:
  /// **'CSV Data Management'**
  String get csvImportExportInfo;

  /// Description of CSV import/export functionality
  ///
  /// In en, this message translates to:
  /// **'Import or export your providers and fee intervals using CSV files'**
  String get csvImportExportDescription;

  /// Import data section title
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// Export data section title
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// CSV templates section title
  ///
  /// In en, this message translates to:
  /// **'CSV Templates'**
  String get templates;

  /// Export combined data option title
  ///
  /// In en, this message translates to:
  /// **'Export Combined'**
  String get exportCombined;

  /// Description for exporting combined data
  ///
  /// In en, this message translates to:
  /// **'Export providers with their fee intervals'**
  String get exportCombinedDescription;

  /// Download provider CSV template option
  ///
  /// In en, this message translates to:
  /// **'Provider Template'**
  String get downloadProviderTemplate;

  /// Description for provider template download
  ///
  /// In en, this message translates to:
  /// **'Download CSV template for importing providers'**
  String get csvTemplateForProviders;

  /// Download fee intervals CSV template option
  ///
  /// In en, this message translates to:
  /// **'Fee Intervals Template'**
  String get downloadFeeTemplate;

  /// Description for fee intervals template download
  ///
  /// In en, this message translates to:
  /// **'Download CSV template for importing fees'**
  String get csvTemplateForFees;

  /// Download combined CSV template option
  ///
  /// In en, this message translates to:
  /// **'Combined Template'**
  String get downloadCombinedTemplate;

  /// Description for combined template download
  ///
  /// In en, this message translates to:
  /// **'Download CSV template for combined import'**
  String get csvTemplateForCombined;

  /// Import success message title
  ///
  /// In en, this message translates to:
  /// **'Import Successful'**
  String get importSuccessful;

  /// Generic import failure message
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String importFailed(String error);

  /// Success message when export completes successfully
  ///
  /// In en, this message translates to:
  /// **'Export successful'**
  String get exportSuccessful;

  /// Generic export failure message
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// Template download success message
  ///
  /// In en, this message translates to:
  /// **'Template Downloaded'**
  String get templateDownloaded;

  /// Error message when template download fails
  ///
  /// In en, this message translates to:
  /// **'Failed to download template'**
  String get failedToDownloadTemplate;

  /// File reading failure message
  ///
  /// In en, this message translates to:
  /// **'Failed to read file'**
  String get failedToReadFile;

  /// Message showing number of providers imported
  ///
  /// In en, this message translates to:
  /// **'{count} provider(s) imported'**
  String providersImported(int count);

  /// Message showing number of fee intervals imported
  ///
  /// In en, this message translates to:
  /// **'{count} fee interval(s) imported'**
  String feeIntervalsImported(int count);

  /// Message showing number of errors encountered
  ///
  /// In en, this message translates to:
  /// **'{count} error(s) encountered'**
  String errorsEncountered(int count);

  /// Data management guide title
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// Backup option title
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// Description for backup functionality
  ///
  /// In en, this message translates to:
  /// **'Backup your providers and fees'**
  String get backupYourData;

  /// Reset option title
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Description for reset functionality
  ///
  /// In en, this message translates to:
  /// **'Clear all data'**
  String get clearAllData;

  /// Reset confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm Reset'**
  String get confirmReset;

  /// Warning message for data reset
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your providers and fee intervals. This action cannot be undone.'**
  String get resetWarningMessage;

  /// Success message for data reset
  ///
  /// In en, this message translates to:
  /// **'Data reset successful'**
  String get dataResetSuccessful;

  /// Failure message for data reset
  ///
  /// In en, this message translates to:
  /// **'Reset failed'**
  String get resetFailed;

  /// Title for CSV management screen
  ///
  /// In en, this message translates to:
  /// **'CSV Management'**
  String get csvManagement;

  /// Preview template button text
  ///
  /// In en, this message translates to:
  /// **'Preview Template'**
  String get previewTemplate;

  /// Preview button text
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// Download button text
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// Template preview dialog title
  ///
  /// In en, this message translates to:
  /// **'Template Preview'**
  String get templatePreview;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Description for import data action
  ///
  /// In en, this message translates to:
  /// **'Import providers and fee intervals from CSV file. The system will automatically detect the data type based on columns.'**
  String get importDataDescription;

  /// Description for export data action
  ///
  /// In en, this message translates to:
  /// **'Export all providers and their fee intervals to a combined CSV file.'**
  String get exportDataDescription;

  /// Error message when CSV text input is empty
  ///
  /// In en, this message translates to:
  /// **'CSV content cannot be empty'**
  String get csvContentCannotBeEmpty;

  /// Instruction text for file import option
  ///
  /// In en, this message translates to:
  /// **'Click to select a CSV file'**
  String get clickImportToSelectFile;

  /// Button text for copying content
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// Message shown when content is copied to clipboard
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// Dialog title for file save location selection
  ///
  /// In en, this message translates to:
  /// **'Choose where to save the file'**
  String get chooseWhereToSave;

  /// Success message when file is saved
  ///
  /// In en, this message translates to:
  /// **'File saved successfully'**
  String get fileSavedSuccessfully;

  /// Error message when file save fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save file'**
  String get failedToSaveFile;

  /// File option text
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get file;

  /// Text option text
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get text;

  /// Hint text for CSV text input field
  ///
  /// In en, this message translates to:
  /// **'Paste your CSV content here...'**
  String get pasteCsvContentHere;

  /// Text shown when a file is selected
  ///
  /// In en, this message translates to:
  /// **'File Selected'**
  String get fileSelected;

  /// Text indicating only CSV files are accepted
  ///
  /// In en, this message translates to:
  /// **'CSV files only'**
  String get csvFilesOnly;

  /// Title for CSV content preview section
  ///
  /// In en, this message translates to:
  /// **'CSV Content Preview:'**
  String get csvContentPreview;

  /// Error message when file selection fails
  ///
  /// In en, this message translates to:
  /// **'Failed to select file'**
  String get failedToSelectFile;

  /// Error message when template preview fails
  ///
  /// In en, this message translates to:
  /// **'Failed to preview template'**
  String get failedToPreviewTemplate;

  /// Error message when CSV file contains no data
  ///
  /// In en, this message translates to:
  /// **'CSV file is empty'**
  String get csvFileIsEmpty;

  /// Error message when CSV file has no valid data rows
  ///
  /// In en, this message translates to:
  /// **'No data rows found'**
  String get noDataRowsFound;

  /// Error message when provider name is missing in CSV row
  ///
  /// In en, this message translates to:
  /// **'Row {rowNumber}: Provider name is required'**
  String rowProviderNameRequired(int rowNumber);

  /// Error message when provider already exists in database
  ///
  /// In en, this message translates to:
  /// **'Row {rowNumber}: Provider \"{name}\" already exists'**
  String rowProviderAlreadyExists(int rowNumber, String name);

  /// Generic error message for CSV row processing
  ///
  /// In en, this message translates to:
  /// **'Row {rowNumber}: {error}'**
  String rowGenericError(int rowNumber, String error);

  /// Error message when provider name is missing in fee interval CSV row
  ///
  /// In en, this message translates to:
  /// **'Row {rowNumber}: Provider name is required'**
  String rowProviderNameRequiredFee(int rowNumber);

  /// Error message when provider referenced in CSV doesn't exist
  ///
  /// In en, this message translates to:
  /// **'Row {rowNumber}: Provider \"{providerName}\" not found'**
  String rowProviderNotFound(int rowNumber, String providerName);

  /// Error message when fee interval overlaps with existing interval
  ///
  /// In en, this message translates to:
  /// **'Row {rowNumber}: Interval overlaps with existing interval ({overlap})'**
  String rowIntervalOverlaps(int rowNumber, String overlap);

  /// Error message when amounts in CSV row are invalid
  ///
  /// In en, this message translates to:
  /// **'Row {rowNumber}: Invalid amounts (min: {minStr}, max: {maxStr}, fee: {feeStr})'**
  String rowInvalidAmounts(
    int rowNumber,
    String minStr,
    String maxStr,
    String feeStr,
  );

  /// Error message when minimum amount is greater than maximum amount
  ///
  /// In en, this message translates to:
  /// **'Row {rowNumber}: Min amount ({min}) must be less than max amount ({max})'**
  String rowMinAmountGreaterThanMax(int rowNumber, String min, String max);

  /// Error message when fee amount is not positive
  ///
  /// In en, this message translates to:
  /// **'Row {rowNumber}: Fee must be positive'**
  String rowFeeMustBePositive(int rowNumber);

  /// Error message when percentage fee is invalid (not between 0 and 100)
  ///
  /// In en, this message translates to:
  /// **'Row {rowNumber}: Percentage fee must be between 0 and 100 ({fee}%)'**
  String rowFeePercentageInvalid(int rowNumber, String fee);

  /// Success message showing number of imported providers and fee intervals
  ///
  /// In en, this message translates to:
  /// **'Imported {providersCount} provider(s) and {feesCount} fee interval(s)'**
  String importedProvidersAndFees(int providersCount, int feesCount);

  /// Error message when provider ID is invalid during import
  ///
  /// In en, this message translates to:
  /// **'Provider \"{providerName}\": Invalid provider ID'**
  String providerInvalidProviderId(String providerName);

  /// Error message when provider has no fee intervals during import
  ///
  /// In en, this message translates to:
  /// **'Provider \"{providerName}\": No fee intervals found'**
  String providerNoFeeIntervals(String providerName);

  /// Generic error message for provider import
  ///
  /// In en, this message translates to:
  /// **'Provider \"{providerName}\": {error}'**
  String providerImportError(String providerName, String error);

  /// Error message for overlapping intervals in combined import
  ///
  /// In en, this message translates to:
  /// **'Row {rowNumber}: Interval overlaps with existing interval ({overlap})'**
  String rowIntervalOverlapsCombined(int rowNumber, String overlap);

  /// Error message when there is no data available for export
  ///
  /// In en, this message translates to:
  /// **'No data to export'**
  String get noDataToExport;

  /// Error message when provider name column is missing in CSV
  ///
  /// In en, this message translates to:
  /// **'Provider name column not found'**
  String get providerNameColumnNotFound;

  /// Hint text shown when user can pull down to refresh content
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh'**
  String get pullToRefresh;

  /// Text shown when content is being refreshed
  ///
  /// In en, this message translates to:
  /// **'Refreshing...'**
  String get refreshing;

  /// Label for fee type selector
  ///
  /// In en, this message translates to:
  /// **'Fee Type'**
  String get feeType;

  /// Option for fixed fee amount
  ///
  /// In en, this message translates to:
  /// **'Fixed Amount'**
  String get fixedAmount;

  /// Option for percentage-based fee
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get percentage;

  /// Placeholder for percentage input
  ///
  /// In en, this message translates to:
  /// **'Enter percentage'**
  String get enterPercentage;

  /// Validation error for percentage input
  ///
  /// In en, this message translates to:
  /// **'Percentage must be between 0 and 100'**
  String get percentageMustBeBetween0And100;

  /// Error message for invalid amount input
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get invalidAmount;

  /// Validation message for missing percentage input
  ///
  /// In en, this message translates to:
  /// **'Please enter percentage'**
  String get pleaseEnterPercentage;

  /// Validation message for invalid percentage input
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid percentage'**
  String get pleaseEnterValidPercentage;

  /// Validation error when percentage exceeds 100
  ///
  /// In en, this message translates to:
  /// **'Percentage cannot exceed 100'**
  String get percentageCannotExceed100;

  /// Placeholder text for help search field
  ///
  /// In en, this message translates to:
  /// **'Search help topics...'**
  String get searchHelpTopics;

  /// Frequently Asked Questions tab title
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// Contact tab title
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// FAQ question
  ///
  /// In en, this message translates to:
  /// **'What is Feezer or Fee Minimizer?'**
  String get faqWhatIsFeeMinimizer;

  /// FAQ answer
  ///
  /// In en, this message translates to:
  /// **'Feezer or Fee Minimizer is a mobile application that helps users calculate and optimize transaction fees across different financial providers. It analyzes your transaction details and suggests the most cost-effective options to minimize banking fees.'**
  String get faqWhatIsFeeMinimizerAnswer;

  /// FAQ question
  ///
  /// In en, this message translates to:
  /// **'How do I add a new provider?'**
  String get faqHowToAddProvider;

  /// FAQ answer
  ///
  /// In en, this message translates to:
  /// **'To add a new provider, go to the Providers screen and tap the \'+\' button. Fill in the provider details including name, description, and fee structure. You can also import provider data using CSV files. There are no favorite providers - you have full control to add and remove providers as needed.'**
  String get faqHowToAddProviderAnswer;

  /// FAQ question
  ///
  /// In en, this message translates to:
  /// **'How does fee calculation work?'**
  String get faqHowToCalculateFees;

  /// FAQ answer
  ///
  /// In en, this message translates to:
  /// **'Enter your transaction amount and select a provider. The app will calculate all applicable fees including fixed fees, percentage fees, and minimum/maximum fees. It then shows you the total cost and suggests optimizations.'**
  String get faqHowToCalculateFeesAnswer;

  /// FAQ question
  ///
  /// In en, this message translates to:
  /// **'Is my data secure?'**
  String get faqDataSecurity;

  /// FAQ answer
  ///
  /// In en, this message translates to:
  /// **'Your financial data is stored locally on your device without encryption or additional security measures. This app does not provide banking-level security features. All data remains on your device and is not transmitted anywhere.'**
  String get faqDataSecurityAnswer;

  /// FAQ question
  ///
  /// In en, this message translates to:
  /// **'Does the app work offline?'**
  String get faqOfflineMode;

  /// FAQ answer
  ///
  /// In en, this message translates to:
  /// **'Yes, Feezer or Fee Minimizer works completely offline. All your data and calculations are stored locally on your device. You can use all features without an internet connection.'**
  String get faqOfflineModeAnswer;

  /// FAQ question
  ///
  /// In en, this message translates to:
  /// **'How do currency exchange rates work?'**
  String get faqCurrencyRates;

  /// No description provided for @faqCurrencyRatesAnswer.
  ///
  /// In en, this message translates to:
  /// **'The app does not automatically update currency exchange rates. You have full control and can manually set your own exchange rates for complete customization. This gives you total flexibility to use rates that suit your needs, and works perfectly offline.'**
  String get faqCurrencyRatesAnswer;

  /// FAQ question
  ///
  /// In en, this message translates to:
  /// **'How do I export my data?'**
  String get faqExportData;

  /// FAQ answer
  ///
  /// In en, this message translates to:
  /// **'Go to Settings > Data Management > CSV Management. You can export providers, currencies, and fee intervals as CSV files. These can be used for backup or to import into other instances of the app.'**
  String get faqExportDataAnswer;

  /// Email support option title
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get emailSupport;

  /// Phone support option title
  ///
  /// In en, this message translates to:
  /// **'Phone Support'**
  String get phoneSupport;

  /// Website contact method
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// Response time section title
  ///
  /// In en, this message translates to:
  /// **'Response Time'**
  String get responseTime;

  /// Response time description
  ///
  /// In en, this message translates to:
  /// **'We typically respond to support requests within 24 hours during business days.'**
  String get responseTimeDescription;

  /// Getting started guide title
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get gettingStarted;

  /// Getting started guide description
  ///
  /// In en, this message translates to:
  /// **'Learn the basics of using Feezer or Fee Minimizer'**
  String get gettingStartedDescription;

  /// Provider management guide title
  ///
  /// In en, this message translates to:
  /// **'Provider Management'**
  String get providerManagement;

  /// Provider management guide description
  ///
  /// In en, this message translates to:
  /// **'How to add, edit, and manage financial providers'**
  String get providerManagementDescription;

  /// Fee calculation guide title
  ///
  /// In en, this message translates to:
  /// **'Fee Calculation'**
  String get feeCalculation;

  /// Fee calculation guide description
  ///
  /// In en, this message translates to:
  /// **'Understanding how fees are calculated and optimized'**
  String get feeCalculationDescription;

  /// Data management guide description
  ///
  /// In en, this message translates to:
  /// **'Import, export, and backup your data'**
  String get dataManagementDescription;

  /// Video tutorials section title
  ///
  /// In en, this message translates to:
  /// **'Video Tutorials'**
  String get videoTutorials;

  /// Video tutorials description
  ///
  /// In en, this message translates to:
  /// **'Watch step-by-step video guides to master Feezer or Fee Minimizer'**
  String get videoTutorialsDescription;

  /// Watch tutorials button text
  ///
  /// In en, this message translates to:
  /// **'Watch Tutorials'**
  String get watchTutorials;

  /// Feedback section title
  ///
  /// In en, this message translates to:
  /// **'Share Your Thoughts'**
  String get shareYourThoughts;

  /// Feedback description
  ///
  /// In en, this message translates to:
  /// **'Help us improve Feezer or Fee Minimizer by sharing your feedback and suggestions'**
  String get feedbackDescription;

  /// Contact us section title
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// Contact section description
  ///
  /// In en, this message translates to:
  /// **'Get in touch with our support team for help with any questions or issues.'**
  String get contactDescription;

  /// Email contact method
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Phone contact method
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// First FAQ question
  ///
  /// In en, this message translates to:
  /// **'How do I minimize transaction fees?'**
  String get faqQuestion1;

  /// First FAQ answer
  ///
  /// In en, this message translates to:
  /// **'Our app automatically calculates the most cost-effective way to handle your transactions by comparing different providers and payment methods.'**
  String get faqAnswer1;

  /// Second FAQ question
  ///
  /// In en, this message translates to:
  /// **'What currencies are supported?'**
  String get faqQuestion2;

  /// Second FAQ answer
  ///
  /// In en, this message translates to:
  /// **'We support all major world currencies including USD, EUR, GBP, JPY, and many others. The app automatically handles currency conversion rates.'**
  String get faqAnswer2;

  /// Third FAQ question
  ///
  /// In en, this message translates to:
  /// **'Is my financial data secure?'**
  String get faqQuestion3;

  /// Third FAQ answer
  ///
  /// In en, this message translates to:
  /// **'Yes, we use bank-level encryption and security measures. Your data is never stored on our servers and all calculations are done locally on your device.'**
  String get faqAnswer3;

  /// Fourth FAQ question
  ///
  /// In en, this message translates to:
  /// **'How do I update currency rates?'**
  String get faqQuestion4;

  /// Fourth FAQ answer
  ///
  /// In en, this message translates to:
  /// **'Currency rates are automatically updated in real-time from reliable financial data providers. You can also manually refresh rates in the settings.'**
  String get faqAnswer4;

  /// Fifth FAQ question
  ///
  /// In en, this message translates to:
  /// **'Can I save my favorite providers?'**
  String get faqQuestion5;

  /// Fifth FAQ answer
  ///
  /// In en, this message translates to:
  /// **'Yes, you can save your preferred banking providers and payment methods for quick access when making new calculations.'**
  String get faqAnswer5;

  /// Sixth FAQ question
  ///
  /// In en, this message translates to:
  /// **'How do I add a new provider?'**
  String get faqQuestion6;

  /// Sixth FAQ answer
  ///
  /// In en, this message translates to:
  /// **'Tap the \'+\' button in the provider list screen. Enter the provider name, description, and choose an icon. You can then add fee intervals for different transaction amounts.'**
  String get faqAnswer6;

  /// Seventh FAQ question
  ///
  /// In en, this message translates to:
  /// **'What are fee intervals?'**
  String get faqQuestion7;

  /// Seventh FAQ answer
  ///
  /// In en, this message translates to:
  /// **'Fee intervals define the cost structure for each provider. You can set fixed fees (e.g., \$2.50) or percentage fees (e.g., 1.5%) for different transaction amount ranges.'**
  String get faqAnswer7;

  /// Eighth FAQ question
  ///
  /// In en, this message translates to:
  /// **'How does the optimization work?'**
  String get faqQuestion8;

  /// Eighth FAQ answer
  ///
  /// In en, this message translates to:
  /// **'Feezer analyzes all your providers\' fee structures and calculates the optimal way to split your transaction into multiple operations to minimize total fees while respecting your constraints.'**
  String get faqAnswer8;

  /// Title for the comparison section showing optimized vs non-optimized results
  ///
  /// In en, this message translates to:
  /// **'Comparison with/without optimization'**
  String get comparisonWithWithoutOptimization;

  /// Label for the optimized results section
  ///
  /// In en, this message translates to:
  /// **'With optimization'**
  String get withOptimization;

  /// Label for the non-optimized results section using maximum amount
  ///
  /// In en, this message translates to:
  /// **'Without optimization (max amount)'**
  String get withoutOptimizationMaxAmount;

  /// Label for the non-optimized results section using same net amount
  ///
  /// In en, this message translates to:
  /// **'Without optimization (same net amount)'**
  String get withoutOptimizationSameNet;

  /// No description provided for @enteredAmount.
  ///
  /// In en, this message translates to:
  /// **'Entered amount'**
  String get enteredAmount;

  /// Label for net amount sent in comparison
  ///
  /// In en, this message translates to:
  /// **'Net amount sent'**
  String get netAmountSent;

  /// Label for total amount spent in comparison
  ///
  /// In en, this message translates to:
  /// **'Total spent'**
  String get totalSpent;

  /// Label for number of operations in comparison
  ///
  /// In en, this message translates to:
  /// **'Number of operations'**
  String get numberOfOperations;

  /// Message when optimization results in loss
  ///
  /// In en, this message translates to:
  /// **'You lose {amount} {currency}'**
  String youLoseAmount(String amount, String currency);

  /// Message when optimization results in gain
  ///
  /// In en, this message translates to:
  /// **'You gain {amount} {currency}'**
  String youGainAmount(String amount, String currency);

  /// Message when non-optimized result is same as optimized
  ///
  /// In en, this message translates to:
  /// **'Same result as optimization'**
  String get sameResultAsOptimization;

  /// Detail showing net amount loss
  ///
  /// In en, this message translates to:
  /// **'• Net amount less: {amount} {currency}'**
  String netAmountLess(String amount, String currency);

  /// Detail showing net amount gain
  ///
  /// In en, this message translates to:
  /// **'• Net amount more: {amount} {currency}'**
  String netAmountMore(String amount, String currency);

  /// Detail showing fee savings
  ///
  /// In en, this message translates to:
  /// **'• Fees less: {amount} {currency}'**
  String feesLess(String amount, String currency);

  /// Detail showing additional fees
  ///
  /// In en, this message translates to:
  /// **'• Fees more: {amount} {currency}'**
  String feesMore(String amount, String currency);

  /// Message when optimization costs more than single transaction
  ///
  /// In en, this message translates to:
  /// **'Optimization costs {amount} {currency} more in fees'**
  String optimizationCostsMoreFees(String amount, String currency);

  /// Explanation for optimization cost due to transaction limits
  ///
  /// In en, this message translates to:
  /// **'• This is due to transaction constraints (min: {min}, max: {max})'**
  String dueToTransactionConstraints(String min, String max);

  /// No description provided for @exceedsEnteredAmount.
  ///
  /// In en, this message translates to:
  /// **'Exceeds entered amount'**
  String get exceedsEnteredAmount;

  /// Message showing savings from optimization
  ///
  /// In en, this message translates to:
  /// **'You save {amount} {currency} in fees'**
  String youSaveFees(String amount, String currency);

  /// Summary of total savings achieved with optimization
  ///
  /// In en, this message translates to:
  /// **'Total savings with optimization: {amount} {currency}'**
  String totalSavingsWithOptimization(String amount, String currency);

  /// Message showing gain when a non-optimized transaction performs better
  ///
  /// In en, this message translates to:
  /// **'This transaction gains {amount} {currency} compared to optimization'**
  String transactionGainsVsOptimized(String amount, String currency);

  /// Message showing loss when a non-optimized transaction performs worse
  ///
  /// In en, this message translates to:
  /// **'This transaction loses {amount} {currency} compared to optimization'**
  String transactionLosesVsOptimized(String amount, String currency);

  /// Message showing when a non-optimized transaction has the same result as optimization
  ///
  /// In en, this message translates to:
  /// **'This transaction has the same result as optimization'**
  String get transactionSameResultAsOptimized;

  /// Message displayed when the entered amount is not within any valid fee interval for comparison
  ///
  /// In en, this message translates to:
  /// **'The entered amount is not within any valid fee interval. Unable to perform comparison without optimization.'**
  String get noValidIntervalForComparison;
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
