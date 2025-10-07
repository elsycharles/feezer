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

  /// Create interval button text
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

  /// Fee intervals title
  ///
  /// In en, this message translates to:
  /// **'Fee Intervals'**
  String get feeIntervals;

  /// New fee interval title
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

  /// Validation message for amount range
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

  /// Message when no optimization results
  ///
  /// In en, this message translates to:
  /// **'No results yet'**
  String get noResultsYet;

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

  /// Malagasy Ariary currency symbol
  ///
  /// In en, this message translates to:
  /// **'Ar'**
  String get currency;

  /// Demo screen title
  ///
  /// In en, this message translates to:
  /// **'Demo'**
  String get demo;

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
