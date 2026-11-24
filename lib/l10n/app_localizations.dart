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

  /// First onboarding screen title
  ///
  /// In en, this message translates to:
  /// **'Pay less in fees'**
  String get onboardingTitle1;

  /// First onboarding screen description
  ///
  /// In en, this message translates to:
  /// **'Enter an amount: Feezer splits it into the transactions that cost the least in fees.'**
  String get onboardingDescription1;

  /// Second onboarding screen title
  ///
  /// In en, this message translates to:
  /// **'Real operator fees'**
  String get onboardingTitle2;

  /// Second onboarding screen description
  ///
  /// In en, this message translates to:
  /// **'MVola, Orange Money, Airtel Money: the grids come from the operators\' official rates and update in one tap.'**
  String get onboardingDescription2;

  /// Third onboarding screen title
  ///
  /// In en, this message translates to:
  /// **'Withdrawals and transfers'**
  String get onboardingTitle3;

  /// Third onboarding screen description
  ///
  /// In en, this message translates to:
  /// **'Choose the operator and the operation. Your data stays on your phone, even offline.'**
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
  /// **'Get started'**
  String get getStarted;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Create interval button
  ///
  /// In en, this message translates to:
  /// **'Add the tier'**
  String get createInterval;

  /// Optimize button text
  ///
  /// In en, this message translates to:
  /// **'Optimize'**
  String get optimize;

  /// Error message for invalid amount
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get pleaseEnterValidAmount;

  /// Error message when no provider is selected
  ///
  /// In en, this message translates to:
  /// **'Choose an operator'**
  String get pleaseSelectProvider;

  /// Appearance section title
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

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

  /// New fee interval screen title
  ///
  /// In en, this message translates to:
  /// **'New tier'**
  String get newFeeInterval;

  /// Validation error for amount range
  ///
  /// In en, this message translates to:
  /// **'Max amount must be greater than min amount'**
  String get maxAmountMustBeGreaterThanMinAmount;

  /// Fee column header
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get fee;

  /// Message when no optimization results are found for the given parameters
  ///
  /// In en, this message translates to:
  /// **'No result. Check the amount and the chosen grid.'**
  String get noOptimizationResultsFound;

  /// About section
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

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

  /// Terms of use service description section title
  ///
  /// In en, this message translates to:
  /// **'The service'**
  String get termsServiceTitle;

  /// Terms of use service description section content
  ///
  /// In en, this message translates to:
  /// **'From the operators\' fee grids, Feezer calculates how to split a withdrawal or a transfer to pay the least fees. By using Feezer, you accept these terms.'**
  String get termsServiceContent;

  /// Terms of use privacy section title
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get termsPrivacyTitle;

  /// Terms of use privacy section content
  ///
  /// In en, this message translates to:
  /// **'Feezer requires no account and collects no personal data. Your grids and calculations stay on your phone and are erased if you uninstall the app. Updating the fees only downloads a public file.'**
  String get termsPrivacyContent;

  /// Terms of use liability section title
  ///
  /// In en, this message translates to:
  /// **'Liability'**
  String get termsLiabilityTitle;

  /// Terms of use liability section content
  ///
  /// In en, this message translates to:
  /// **'Results are for information only: operators can change their fees at any time, so check them before each transaction. Feezer is not affiliated with any operator and is not responsible for the fees actually charged.'**
  String get termsLiabilityContent;

  /// Terms of use contact section title
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get termsContactTitle;

  /// Terms of use contact section content
  ///
  /// In en, this message translates to:
  /// **'A question? Write to us from Help & support, or at elsy.s.charles@gmail.com.'**
  String get termsContactContent;

  /// Message when no fee intervals exist
  ///
  /// In en, this message translates to:
  /// **'This grid has no tier yet. Add them in the Operators tab.'**
  String get noFeeIntervalsFound;

  /// Add fee interval button
  ///
  /// In en, this message translates to:
  /// **'Add a tier'**
  String get addFeeInterval;

  /// Delete fee intervals title
  ///
  /// In en, this message translates to:
  /// **'Delete the tier'**
  String get deleteFeeIntervals;

  /// Success message for fee interval creation
  ///
  /// In en, this message translates to:
  /// **'Tier added'**
  String get feeIntervalCreatedSuccessfully;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// Required field validation message
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get thisFieldIsRequired;

  /// Fee interval update success message
  ///
  /// In en, this message translates to:
  /// **'Tier updated'**
  String get feeIntervalUpdatedSuccessfully;

  /// Fee interval deletion success message
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Tier deleted} other{{count} tiers deleted}}'**
  String feeIntervalDeletedSuccessfully(int count);

  /// Edit fee interval dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit the tier'**
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

  /// Help and support menu item
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get helpAndSupport;

  /// Add new provider button text
  ///
  /// In en, this message translates to:
  /// **'Add an operator'**
  String get addNewProvider;

  /// Save changes button text
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// Confirmation message for deleting fee intervals
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{This tier will be removed from the grid.} other{These {count} tiers will be removed from the grid.}}'**
  String confirmDeleteIntervals(int count);

  /// Generic error message when optimization calculation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to calculate optimization'**
  String get failedToCalculateOptimization;

  /// Import/Export data menu title
  ///
  /// In en, this message translates to:
  /// **'Import / export'**
  String get importExportData;

  /// Import data section title
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importData;

  /// Export data section title
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportData;

  /// Import success message title
  ///
  /// In en, this message translates to:
  /// **'Import done'**
  String get importSuccessful;

  /// Generic import failure message
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String importFailed(String error);

  /// Generic export failure message
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// Message showing number of providers imported
  ///
  /// In en, this message translates to:
  /// **'{count} grid(s) imported'**
  String providersImported(int count);

  /// Message showing number of fee intervals imported
  ///
  /// In en, this message translates to:
  /// **'{count} tier(s) imported'**
  String feeIntervalsImported(int count);

  /// Message showing number of errors encountered
  ///
  /// In en, this message translates to:
  /// **'{count} error(s) encountered'**
  String errorsEncountered(int count);

  /// Description for import data action
  ///
  /// In en, this message translates to:
  /// **'Add grids from a CSV file (one row per tier).'**
  String get importDataDescription;

  /// Description for export data action
  ///
  /// In en, this message translates to:
  /// **'Save all your grids and their tiers in a CSV file.'**
  String get exportDataDescription;

  /// Error message when CSV text input is empty
  ///
  /// In en, this message translates to:
  /// **'CSV content cannot be empty'**
  String get csvContentCannotBeEmpty;

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
  /// **'Row {rowNumber}: the operator name is required'**
  String rowProviderNameRequired(int rowNumber);

  /// Error message when provider already exists in database
  ///
  /// In en, this message translates to:
  /// **'Row {rowNumber}: the grid \"{name}\" already exists'**
  String rowProviderAlreadyExists(int rowNumber, String name);

  /// Error message when fee interval overlaps with existing interval
  ///
  /// In en, this message translates to:
  /// **'Row {rowNumber}: this tier overlaps an existing tier ({overlap})'**
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
  /// **'Imported {providersCount} grid(s) and {feesCount} tier(s)'**
  String importedProvidersAndFees(int providersCount, int feesCount);

  /// Error message when there is no data available for export
  ///
  /// In en, this message translates to:
  /// **'No data to export'**
  String get noDataToExport;

  /// Error message when provider name column is missing in CSV
  ///
  /// In en, this message translates to:
  /// **'Operator name column not found'**
  String get providerNameColumnNotFound;

  /// Option for fixed fee amount
  ///
  /// In en, this message translates to:
  /// **'Fixed amount'**
  String get fixedAmount;

  /// Option for percentage-based fee
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get percentage;

  /// Validation error for percentage input
  ///
  /// In en, this message translates to:
  /// **'Percentage must be between 0 and 100'**
  String get percentageMustBeBetween0And100;

  /// Frequently Asked Questions tab title
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// FAQ question
  ///
  /// In en, this message translates to:
  /// **'How do I back up my grids?'**
  String get faqExportData;

  /// FAQ answer
  ///
  /// In en, this message translates to:
  /// **'Settings › Import / export: export your grids to a CSV file, then import it on another phone or after reinstalling the app.'**
  String get faqExportDataAnswer;

  /// Website contact method
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// Contact us section title
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactUs;

  /// Email contact method
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @exceedsEnteredAmount.
  ///
  /// In en, this message translates to:
  /// **'Exceeds entered amount'**
  String get exceedsEnteredAmount;

  /// Optimizer / data validation message
  ///
  /// In en, this message translates to:
  /// **'The amount is too small for a transaction with this grid.'**
  String get optimizationBudgetTooSmall;

  /// Optimizer / data validation message
  ///
  /// In en, this message translates to:
  /// **'No split respects this number of transactions for this amount.'**
  String get optimizationConstraintsUnsatisfiable;

  /// Optimizer / data validation message
  ///
  /// In en, this message translates to:
  /// **'Very long search: this split is excellent but could not be proven to be the best.'**
  String get optimizationNotProven;

  /// Optimizer / data validation message
  ///
  /// In en, this message translates to:
  /// **'This tier overlaps an existing tier ({range}).'**
  String feeIntervalOverlaps(String range);

  /// Optimizer / data validation message
  ///
  /// In en, this message translates to:
  /// **'Could not delete the tier'**
  String get failedToDeleteFeeIntervals;

  /// Optimizer / data validation message
  ///
  /// In en, this message translates to:
  /// **'Failed to save changes'**
  String get failedToSaveChanges;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Optimize'**
  String get tabOptimize;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Pay less in fees'**
  String get optimizeTitle;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Feezer splits your amount into the transactions that cost the least.'**
  String get optimizeSubtitle;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Amount available'**
  String get amountAvailable;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Fees included: the total that will leave your account.'**
  String get amountHelper;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Number of transfers'**
  String get transferCount;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Optional. Limit how many transfers the plan may use.'**
  String get transferCountHelp;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get transferCountFree;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Exactly {count}'**
  String transferCountExactly(int count);

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Between {min} and {max}'**
  String transferCountRange(int min, int max);

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'At least {count}'**
  String transferCountAtLeast(int count);

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'At most {count}'**
  String transferCountAtMost(int count);

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get minimumShort;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get maximumShort;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get anyCount;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'The recipient receives'**
  String get recipientReceives;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Optimal'**
  String get bestSplit;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Very good'**
  String get goodSplit;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 transfer} other{{count} transfers}}'**
  String transferCountLabel(int count);

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Fees'**
  String get feesLabel;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Debited'**
  String get debitedLabel;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get leftLabel;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'+{amount} more received'**
  String gainTitle(String amount);

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Compared to sending the largest possible amount each time.'**
  String get gainVsClassic;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'{amount} of fees saved'**
  String feesSavedTitle(String amount);

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'The usual way would cost more for the same amount.'**
  String get feesSavedVsClassic;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'The usual way is already the best'**
  String get alreadyOptimalTitle;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'For this amount, splitting brings nothing more.'**
  String get alreadyOptimalMessage;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Without this limit, {amount} more would be received.'**
  String limitCost(String amount);

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'This limit costs you nothing here.'**
  String get limitFree;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Very large amount'**
  String get nearOptimalTitle;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Your transfer plan'**
  String get planTitle;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Send {amount}'**
  String sendAmount(String amount);

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'fee {amount} per transfer'**
  String feePerTransfer(String amount);

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Comparison'**
  String get compareTitle;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Optimized'**
  String get optimizedColumn;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Usual'**
  String get classicColumn;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get receivedLabel;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Transfers'**
  String get transfersLabel;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Usual way: send the largest possible amount, then the rest.'**
  String get classicExplanation;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Same amount received, usual way'**
  String get sameAmountByHand;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'To get {net}, the usual way costs {fees} in fees, i.e. {total} debited.'**
  String sameAmountByHandDetail(String net, String fees, String total);

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'The usual way cannot reach this amount.'**
  String get cannotSplitByHand;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Usual plan'**
  String get classicPlan;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Show details'**
  String get showDetails;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Hide details'**
  String get showLess;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'No grid yet'**
  String get noProvidersYet;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Update the official fees, or add your own grid.'**
  String get noProvidersMessage;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No tier} =1{1 tier} other{{count} tiers}}'**
  String tierCount(int count);

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'fees from {amount}'**
  String feesFrom(String amount);

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'e.g. MVola, Orange Money, my bank'**
  String get providerNameHint;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Fee grid'**
  String get feeGrid;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Amount sent'**
  String get amountRange;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Add the tiers of this grid to optimize your transactions.'**
  String get noIntervalsMessage;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Tap a tier to edit or delete it.'**
  String get gridHint;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'The fee applies when the amount sent is between the minimum and the maximum (included).'**
  String get intervalFormHelp;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Reading the published fee grids…'**
  String get downloadingFees;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get feesDownloadFailed;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Your fees are up to date'**
  String get feesAlreadyUpToDate;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Your other grids do not change.'**
  String get gridsOthersUnchanged;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateAction;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Fees updated'**
  String get feesUpdatedSuccessfully;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Back up or share your grids (CSV)'**
  String get importExportSubtitle;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Replay the introduction'**
  String get replayIntroduction;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Where do the fees come from?'**
  String get faqFeeUpdate;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'From the operators\' official rates: MVola and Orange Money grids are read every day on mvola.mg and orange.mg; the Airtel Money grid is copied from its published rates. Tap “Update” in the Operators tab to get the latest ones; the grids you added yourself do not change.'**
  String get faqFeeUpdateAnswer;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Paste CSV text'**
  String get pasteCsv;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Choose a CSV file'**
  String get chooseCsvFile;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get csvTemplate;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Start from a ready-made file with the expected columns.'**
  String get csvTemplateDescription;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'Download the template'**
  String get downloadTemplate;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'File format'**
  String get csvFormat;

  /// UI redesign
  ///
  /// In en, this message translates to:
  /// **'One row per tier. Rows with the same provider_name and operation form one grid. operation is withdrawal, transfer_same, transfer_same_app, transfer_other, transfer_microfinance or transfer_unregistered (optional); fee_type is fixed or percentage. Commas or semicolons are accepted.'**
  String get csvFormatHelp;

  /// No description provided for @opWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal'**
  String get opWithdrawal;

  /// No description provided for @opTransferSame.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get opTransferSame;

  /// No description provided for @opTransferSameApp.
  ///
  /// In en, this message translates to:
  /// **'Transfer in the app'**
  String get opTransferSameApp;

  /// No description provided for @opTransferOther.
  ///
  /// In en, this message translates to:
  /// **'To another operator'**
  String get opTransferOther;

  /// No description provided for @opTransferMicrofinance.
  ///
  /// In en, this message translates to:
  /// **'To a microfinance'**
  String get opTransferMicrofinance;

  /// No description provided for @opTransferUnregistered.
  ///
  /// In en, this message translates to:
  /// **'To a non-subscriber'**
  String get opTransferUnregistered;

  /// No description provided for @opCustom.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get opCustom;

  /// No description provided for @operators.
  ///
  /// In en, this message translates to:
  /// **'Operators'**
  String get operators;

  /// No description provided for @operatorsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The fee grids used for your calculations.'**
  String get operatorsSubtitle;

  /// No description provided for @operatorLabel.
  ///
  /// In en, this message translates to:
  /// **'Operator'**
  String get operatorLabel;

  /// No description provided for @operationLabel.
  ///
  /// In en, this message translates to:
  /// **'Operation'**
  String get operationLabel;

  /// No description provided for @operatorName.
  ///
  /// In en, this message translates to:
  /// **'Operator name'**
  String get operatorName;

  /// No description provided for @gridCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 grid} other{{count} grids}}'**
  String gridCount(int count);

  /// No description provided for @customGrids.
  ///
  /// In en, this message translates to:
  /// **'Added by you'**
  String get customGrids;

  /// No description provided for @editedTag.
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get editedTag;

  /// No description provided for @newGrid.
  ///
  /// In en, this message translates to:
  /// **'New grid'**
  String get newGrid;

  /// No description provided for @editGrid.
  ///
  /// In en, this message translates to:
  /// **'Edit the grid'**
  String get editGrid;

  /// No description provided for @createGrid.
  ///
  /// In en, this message translates to:
  /// **'Create the grid'**
  String get createGrid;

  /// No description provided for @gridCreated.
  ///
  /// In en, this message translates to:
  /// **'Grid created'**
  String get gridCreated;

  /// No description provided for @gridUpdated.
  ///
  /// In en, this message translates to:
  /// **'Grid updated'**
  String get gridUpdated;

  /// No description provided for @gridDeleted.
  ///
  /// In en, this message translates to:
  /// **'Grid deleted'**
  String get gridDeleted;

  /// No description provided for @gridAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'The grid {name} already exists.'**
  String gridAlreadyExists(String name);

  /// No description provided for @deleteGridTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete the grid'**
  String get deleteGridTitle;

  /// No description provided for @deleteGridMessage.
  ///
  /// In en, this message translates to:
  /// **'The grid {name} and its tiers will be deleted.'**
  String deleteGridMessage(String name);

  /// No description provided for @optimizeWithGrid.
  ///
  /// In en, this message translates to:
  /// **'Optimize with this grid'**
  String get optimizeWithGrid;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @officialFees.
  ///
  /// In en, this message translates to:
  /// **'Official fees'**
  String get officialFees;

  /// No description provided for @feesCheckedOn.
  ///
  /// In en, this message translates to:
  /// **'Checked on the operators\' websites on {date}'**
  String feesCheckedOn(String date);

  /// No description provided for @feesNeverChecked.
  ///
  /// In en, this message translates to:
  /// **'Download the latest fees published by the operators.'**
  String get feesNeverChecked;

  /// No description provided for @sourceOfficial.
  ///
  /// In en, this message translates to:
  /// **'Official grid · {host}'**
  String sourceOfficial(String host);

  /// No description provided for @sourceOfficialDated.
  ///
  /// In en, this message translates to:
  /// **'Official grid · {host} · {date}'**
  String sourceOfficialDated(String host, String date);

  /// No description provided for @sourceManual.
  ///
  /// In en, this message translates to:
  /// **'Grid copied from the operator\'s rates'**
  String get sourceManual;

  /// No description provided for @sourceManualDated.
  ///
  /// In en, this message translates to:
  /// **'Grid copied from the operator\'s rates · {date}'**
  String sourceManualDated(String date);

  /// No description provided for @sourceEdited.
  ///
  /// In en, this message translates to:
  /// **'Grid edited by you'**
  String get sourceEdited;

  /// No description provided for @openSource.
  ///
  /// In en, this message translates to:
  /// **'See the official page'**
  String get openSource;

  /// No description provided for @editPublishedGridWarning.
  ///
  /// In en, this message translates to:
  /// **'This grid comes from the operator\'s rates. If you update the fees later, your change will be replaced.'**
  String get editPublishedGridWarning;

  /// No description provided for @feesSection.
  ///
  /// In en, this message translates to:
  /// **'Fees'**
  String get feesSection;

  /// No description provided for @updateFeesTitle.
  ///
  /// In en, this message translates to:
  /// **'Update the fees'**
  String get updateFeesTitle;

  /// No description provided for @feesDownloadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get feesDownloadFailedTitle;

  /// No description provided for @updateReviewIntro.
  ///
  /// In en, this message translates to:
  /// **'The operators published new fees. Here is what changes:'**
  String get updateReviewIntro;

  /// No description provided for @effectiveSince.
  ///
  /// In en, this message translates to:
  /// **'in force since {date}'**
  String effectiveSince(String date);

  /// No description provided for @newTag.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newTag;

  /// No description provided for @updatedTag.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updatedTag;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @withdrawalCount.
  ///
  /// In en, this message translates to:
  /// **'Number of withdrawals'**
  String get withdrawalCount;

  /// No description provided for @withdrawalCountHelp.
  ///
  /// In en, this message translates to:
  /// **'Optional. Limit how many withdrawals the plan may use.'**
  String get withdrawalCountHelp;

  /// No description provided for @cashYouReceive.
  ///
  /// In en, this message translates to:
  /// **'You receive in cash'**
  String get cashYouReceive;

  /// No description provided for @withdrawalCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 withdrawal} other{{count} withdrawals}}'**
  String withdrawalCountLabel(int count);

  /// No description provided for @withdrawalsLabel.
  ///
  /// In en, this message translates to:
  /// **'Withdrawals'**
  String get withdrawalsLabel;

  /// No description provided for @withdrawAmount.
  ///
  /// In en, this message translates to:
  /// **'Withdraw {amount}'**
  String withdrawAmount(String amount);

  /// No description provided for @feePerWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'fee {amount} per withdrawal'**
  String feePerWithdrawal(String amount);

  /// No description provided for @planTitleWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Your withdrawal plan'**
  String get planTitleWithdrawal;

  /// No description provided for @gainVsClassicWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Compared to withdrawing the largest possible amount each time.'**
  String get gainVsClassicWithdrawal;

  /// No description provided for @classicExplanationWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Usual way: withdraw the largest possible amount, then the rest.'**
  String get classicExplanationWithdrawal;

  /// No description provided for @amountWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Amount withdrawn'**
  String get amountWithdrawn;

  /// No description provided for @noTiersYet.
  ///
  /// In en, this message translates to:
  /// **'No tier yet'**
  String get noTiersYet;

  /// No description provided for @intervalFormHelpWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'The fee applies when the amount withdrawn is between the minimum and the maximum (included).'**
  String get intervalFormHelpWithdrawal;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @failedToLoadData.
  ///
  /// In en, this message translates to:
  /// **'Could not load the data'**
  String get failedToLoadData;

  /// No description provided for @failedToOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link'**
  String get failedToOpenLink;

  /// No description provided for @pressAgainToExit.
  ///
  /// In en, this message translates to:
  /// **'Press again to exit'**
  String get pressAgainToExit;

  /// No description provided for @onlyOperation.
  ///
  /// In en, this message translates to:
  /// **'Only “{operation}” is available for {operator}.'**
  String onlyOperation(String operation, String operator);

  /// No description provided for @amountStepMultiples.
  ///
  /// In en, this message translates to:
  /// **'Multiples of {amount}'**
  String amountStepMultiples(String amount);

  /// No description provided for @optimizationStepTooLarge.
  ///
  /// In en, this message translates to:
  /// **'No tier of this grid accepts amounts in multiples of {amount}. Turn off rounding.'**
  String optimizationStepTooLarge(String amount);

  /// No description provided for @roundToHundred.
  ///
  /// In en, this message translates to:
  /// **'Round to the hundred'**
  String get roundToHundred;

  /// No description provided for @roundToHundredOnWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Every withdrawal is a multiple of 100: {example}, never {wrong}.'**
  String roundToHundredOnWithdrawal(String example, String wrong);

  /// No description provided for @roundToHundredOnTransfer.
  ///
  /// In en, this message translates to:
  /// **'Every transfer is a multiple of 100: {example}, never {wrong}.'**
  String roundToHundredOnTransfer(String example, String wrong);

  /// No description provided for @roundToHundredOff.
  ///
  /// In en, this message translates to:
  /// **'Exact amounts, not rounded.'**
  String get roundToHundredOff;

  /// No description provided for @faqHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How does it work?'**
  String get faqHowItWorks;

  /// No description provided for @faqHowItWorksAnswer.
  ///
  /// In en, this message translates to:
  /// **'Choose the operator, the operation (withdrawal, transfer…) and the amount available, fees included. Feezer finds the split that gets you the most money with the least fees, and compares it with the usual way: withdrawing or sending the largest possible amount each time.'**
  String get faqHowItWorksAnswer;

  /// No description provided for @faqRounding.
  ///
  /// In en, this message translates to:
  /// **'Why are the amounts rounded to the hundred?'**
  String get faqRounding;

  /// No description provided for @faqRoundingAnswer.
  ///
  /// In en, this message translates to:
  /// **'Cash points only hand out notes: you cannot withdraw 10 040. With “Round to the hundred”, every amount of the plan is a multiple of 100. It is on by default for withdrawals; turn it off for exact amounts.'**
  String get faqRoundingAnswer;

  /// No description provided for @faqPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Do I need internet? Is my data shared?'**
  String get faqPrivacy;

  /// No description provided for @faqPrivacyAnswer.
  ///
  /// In en, this message translates to:
  /// **'No. Calculations run on your phone, without an account, and nothing is sent. Internet is only used to update the fees (a public file).'**
  String get faqPrivacyAnswer;
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
