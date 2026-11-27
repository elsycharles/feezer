// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get onboardingTitle1 => 'Pay less in fees';

  @override
  String get onboardingTitle2 => 'In 3 steps';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get started';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get settings => 'Settings';

  @override
  String get createInterval => 'Add the tier';

  @override
  String get optimize => 'Optimize';

  @override
  String get pleaseEnterValidAmount => 'Invalid amount';

  @override
  String get pleaseSelectProvider => 'Choose an operator';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get newFeeInterval => 'New tier';

  @override
  String get maxAmountMustBeGreaterThanMinAmount => 'Must exceed the minimum';

  @override
  String get fee => 'Fee';

  @override
  String get noOptimizationResultsFound => 'No result';

  @override
  String get about => 'About';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get termsServiceTitle => 'The service';

  @override
  String get termsServiceContent =>
      'Feezer works out how to split a withdrawal or a transfer to pay the least fees, from the operators\' fee grids.';

  @override
  String get termsPrivacyTitle => 'Your data';

  @override
  String get termsPrivacyContent =>
      'No account, no data collected. Your grids and calculations stay on your phone.';

  @override
  String get termsLiabilityTitle => 'Liability';

  @override
  String get termsLiabilityContent =>
      'Results are indicative: operators can change their fees. Check them before each transaction.';

  @override
  String get termsContactTitle => 'Contact';

  @override
  String get noFeeIntervalsFound => 'This grid has no tier';

  @override
  String get addFeeInterval => 'Add a tier';

  @override
  String get deleteFeeIntervals => 'Delete the tier';

  @override
  String get feeIntervalCreatedSuccessfully => 'Tier added';

  @override
  String get icon => 'Icon';

  @override
  String get thisFieldIsRequired => 'Required';

  @override
  String get feeIntervalUpdatedSuccessfully => 'Tier updated';

  @override
  String feeIntervalDeletedSuccessfully(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tiers deleted',
      one: 'Tier deleted',
    );
    return '$_temp0';
  }

  @override
  String get editFeeInterval => 'Edit the tier';

  @override
  String get minTransactionsCannotBeGreaterThanMax => 'Minimum > maximum';

  @override
  String get pleaseEnterValidFee => 'Invalid fee';

  @override
  String get helpAndSupport => 'Help & support';

  @override
  String get addNewProvider => 'Add an operator';

  @override
  String get saveChanges => 'Save changes';

  @override
  String confirmDeleteIntervals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'These $count tiers will be removed from the grid.',
      one: 'This tier will be removed from the grid.',
    );
    return '$_temp0';
  }

  @override
  String get failedToCalculateOptimization => 'Calculation failed';

  @override
  String get importExportData => 'Import / export';

  @override
  String get importData => 'Import';

  @override
  String get exportData => 'Export';

  @override
  String get importSuccessful => 'Import done';

  @override
  String importFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String errorsEncountered(int count) {
    return '$count error(s)';
  }

  @override
  String get csvContentCannotBeEmpty => 'Empty text';

  @override
  String get chooseWhereToSave => 'Save the file';

  @override
  String get fileSavedSuccessfully => 'File saved';

  @override
  String get failedToSaveFile => 'Could not save the file';

  @override
  String get csvFileIsEmpty => 'Empty file';

  @override
  String get noDataRowsFound => 'No rows found';

  @override
  String rowProviderNameRequired(int rowNumber) {
    return 'Row $rowNumber: operator missing';
  }

  @override
  String rowProviderAlreadyExists(int rowNumber, String name) {
    return 'Row $rowNumber: \"$name\" already exists';
  }

  @override
  String rowIntervalOverlaps(int rowNumber, String overlap) {
    return 'Row $rowNumber: overlaps $overlap';
  }

  @override
  String rowInvalidAmounts(
    int rowNumber,
    String minStr,
    String maxStr,
    String feeStr,
  ) {
    return 'Row $rowNumber: invalid amounts ($minStr, $maxStr, $feeStr)';
  }

  @override
  String rowMinAmountGreaterThanMax(int rowNumber, String min, String max) {
    return 'Row $rowNumber: min $min > max $max';
  }

  @override
  String rowFeeMustBePositive(int rowNumber) {
    return 'Row $rowNumber: negative fee';
  }

  @override
  String rowFeePercentageInvalid(int rowNumber, String fee) {
    return 'Row $rowNumber: percentage outside 0–100 ($fee)';
  }

  @override
  String importedProvidersAndFees(int providersCount, int feesCount) {
    return '$providersCount grid(s), $feesCount tier(s)';
  }

  @override
  String get noDataToExport => 'No grid to export';

  @override
  String get providerNameColumnNotFound => 'Operator column missing';

  @override
  String get fixedAmount => 'Fixed amount';

  @override
  String get percentage => 'Percentage';

  @override
  String get percentageMustBeBetween0And100 => 'Between 0 and 100';

  @override
  String get faq => 'FAQ';

  @override
  String get faqExportData => 'How do I back up my grids?';

  @override
  String get faqExportDataAnswer =>
      'In Settings › Import / export, export them to a CSV file, then import it on another phone.';

  @override
  String get website => 'Website';

  @override
  String get contactUs => 'Contact us';

  @override
  String get email => 'Email';

  @override
  String get optimizationBudgetTooSmall => 'Amount too small for this grid';

  @override
  String get optimizationConstraintsUnsatisfiable =>
      'Not possible with this limit';

  @override
  String feeIntervalOverlaps(String range) {
    return 'Overlaps the tier $range';
  }

  @override
  String get failedToDeleteFeeIntervals => 'Could not delete';

  @override
  String get failedToSaveChanges => 'Could not save';

  @override
  String get tabOptimize => 'Optimize';

  @override
  String get add => 'Add';

  @override
  String get amountAvailable => 'Amount available';

  @override
  String get amountHelper => 'Fees included';

  @override
  String get transferCount => 'Number of transfers';

  @override
  String get transferCountFree => 'No limit';

  @override
  String transferCountExactly(int count) {
    return 'Exactly $count';
  }

  @override
  String transferCountRange(int min, int max) {
    return 'Between $min and $max';
  }

  @override
  String transferCountAtLeast(int count) {
    return 'At least $count';
  }

  @override
  String transferCountAtMost(int count) {
    return 'At most $count';
  }

  @override
  String get minimumShort => 'Minimum';

  @override
  String get maximumShort => 'Maximum';

  @override
  String get anyCount => 'Any';

  @override
  String get recipientReceives => 'The recipient receives';

  @override
  String get bestSplit => 'Optimal';

  @override
  String get goodSplit => 'Very good';

  @override
  String transferCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transfers',
      one: '1 transfer',
    );
    return '$_temp0';
  }

  @override
  String get feesLabel => 'Fees';

  @override
  String get debitedLabel => 'Debited';

  @override
  String get leftLabel => 'Left';

  @override
  String gainTitle(String amount) {
    return '+$amount more received';
  }

  @override
  String feesSavedTitle(String amount) {
    return '$amount of fees saved';
  }

  @override
  String get alreadyOptimalTitle => 'The usual way is already optimal';

  @override
  String limitCost(String amount) {
    return 'Your limit costs $amount';
  }

  @override
  String get planTitle => 'Transfer plan';

  @override
  String sendAmount(String amount) {
    return 'Send $amount';
  }

  @override
  String feePerTransfer(String amount) {
    return 'fee $amount per transfer';
  }

  @override
  String get compareTitle => 'Comparison';

  @override
  String get optimizedColumn => 'Optimized';

  @override
  String get classicColumn => 'Usual';

  @override
  String get receivedLabel => 'Received';

  @override
  String get transfersLabel => 'Transfers';

  @override
  String get classicExplanation => 'Usual: send the most, then the rest';

  @override
  String get classicPlan => 'Usual plan';

  @override
  String get showDetails => 'Show details';

  @override
  String get showLess => 'Hide details';

  @override
  String get noProvidersYet => 'No grid yet';

  @override
  String tierCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tiers',
      one: '1 tier',
      zero: 'No tier',
    );
    return '$_temp0';
  }

  @override
  String feesFrom(String amount) {
    return 'fees from $amount';
  }

  @override
  String get providerNameHint => 'e.g. MVola, my bank';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get feeGrid => 'Fee grid';

  @override
  String get amountRange => 'Amount sent';

  @override
  String get downloadingFees => 'Downloading…';

  @override
  String get feesDownloadFailed => 'Check your connection';

  @override
  String get feesAlreadyUpToDate => 'Your fees are up to date';

  @override
  String get updateAction => 'Update';

  @override
  String get feesUpdatedSuccessfully => 'Fees updated';

  @override
  String get replayIntroduction => 'Replay the introduction';

  @override
  String get faqFeeUpdate => 'Where do the fees come from?';

  @override
  String get faqFeeUpdateAnswer =>
      'From the official rates of MVola, Orange Money and Airtel Money. Tap “Update” to get the latest.';

  @override
  String get ok => 'OK';

  @override
  String get pasteCsv => 'Paste CSV text';

  @override
  String get chooseCsvFile => 'Choose a CSV file';

  @override
  String get csvTemplate => 'Template';

  @override
  String get downloadTemplate => 'Download the template';

  @override
  String get csvFormat => 'File format';

  @override
  String get opWithdrawal => 'Withdrawal';

  @override
  String get opTransferSame => 'Transfer';

  @override
  String get opTransferSameApp => 'Transfer in the app';

  @override
  String get opTransferOther => 'To another operator';

  @override
  String get opTransferMicrofinance => 'To a microfinance';

  @override
  String get opTransferUnregistered => 'To a non-subscriber';

  @override
  String get opCustom => 'Other';

  @override
  String get operators => 'Operators';

  @override
  String get operatorLabel => 'Operator';

  @override
  String get operationLabel => 'Operation';

  @override
  String get operatorName => 'Operator name';

  @override
  String gridCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count grids',
      one: '1 grid',
    );
    return '$_temp0';
  }

  @override
  String get customGrids => 'Added by you';

  @override
  String get editedTag => 'edited';

  @override
  String get newGrid => 'New grid';

  @override
  String get editGrid => 'Edit the grid';

  @override
  String get createGrid => 'Create the grid';

  @override
  String get gridCreated => 'Grid created';

  @override
  String get gridUpdated => 'Grid updated';

  @override
  String get gridDeleted => 'Grid deleted';

  @override
  String gridAlreadyExists(String name) {
    return '$name already exists';
  }

  @override
  String get deleteGridTitle => 'Delete the grid';

  @override
  String deleteGridMessage(String name) {
    return '$name and its tiers will be deleted.';
  }

  @override
  String get optimizeWithGrid => 'Optimize with this grid';

  @override
  String get moreOptions => 'More options';

  @override
  String get officialFees => 'Official fees';

  @override
  String feesCheckedOn(String date) {
    return 'Checked on $date';
  }

  @override
  String get feesNeverChecked => 'Not checked yet';

  @override
  String sourceOfficial(String host) {
    return 'Official grid · $host';
  }

  @override
  String sourceOfficialDated(String host, String date) {
    return 'Official grid · $host · $date';
  }

  @override
  String get sourceManual => 'Operator\'s rates';

  @override
  String sourceManualDated(String date) {
    return 'Operator\'s rates · $date';
  }

  @override
  String get sourceEdited => 'Edited by you';

  @override
  String get editPublishedGridWarning => 'A fee update will undo this change.';

  @override
  String get feesSection => 'Fees';

  @override
  String get updateFeesTitle => 'Update the fees';

  @override
  String get feesDownloadFailedTitle => 'Download failed';

  @override
  String get updateReviewIntro => 'New fees published:';

  @override
  String effectiveSince(String date) {
    return 'since $date';
  }

  @override
  String get newTag => 'New';

  @override
  String get updatedTag => 'Updated';

  @override
  String get later => 'Later';

  @override
  String get retry => 'Try again';

  @override
  String get withdrawalCount => 'Number of withdrawals';

  @override
  String get cashYouReceive => 'You receive in cash';

  @override
  String withdrawalCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count withdrawals',
      one: '1 withdrawal',
    );
    return '$_temp0';
  }

  @override
  String get withdrawalsLabel => 'Withdrawals';

  @override
  String withdrawAmount(String amount) {
    return 'Withdraw $amount';
  }

  @override
  String feePerWithdrawal(String amount) {
    return 'fee $amount per withdrawal';
  }

  @override
  String get planTitleWithdrawal => 'Withdrawal plan';

  @override
  String get classicExplanationWithdrawal =>
      'Usual: withdraw the most, then the rest';

  @override
  String get amountWithdrawn => 'Amount withdrawn';

  @override
  String get noTiersYet => 'No tier yet';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get free => 'Free';

  @override
  String get failedToLoadData => 'Could not load';

  @override
  String get failedToOpenLink => 'Could not open the link';

  @override
  String get pressAgainToExit => 'Press again to exit';

  @override
  String get optimizationStepTooLarge => 'Turn off rounding for this grid';

  @override
  String get roundToHundred => 'Round to the hundred';

  @override
  String get roundToHundredOff => 'Exact amounts';

  @override
  String get faqHowItWorks => 'How does it work?';

  @override
  String get faqHowItWorksAnswer =>
      'Pick the operator, the operation and the amount available. Feezer finds the split that costs the least in fees.';

  @override
  String get faqRounding => 'Why round to the hundred?';

  @override
  String get faqRoundingAnswer =>
      'Cash points only hand out notes: you can\'t withdraw 10 040. You can turn rounding off at any time.';

  @override
  String get faqPrivacy => 'Is my data shared?';

  @override
  String get faqPrivacyAnswer =>
      'No. Feezer needs no account and nothing leaves your phone.';

  @override
  String get onboardingText1 => 'Feezer splits your withdrawals and transfers.';

  @override
  String onboardingExample(String amount) {
    return 'Example: $amount in your account';
  }

  @override
  String get onboardingOneGo => 'In one go';

  @override
  String get onboardingWithFeezer => 'With Feezer';

  @override
  String get onboardingStep1 => 'Pick the operator';

  @override
  String get onboardingStep2 => 'Enter the amount';

  @override
  String get onboardingStep3 => 'Follow the plan';

  @override
  String roundToHundredOn(String example, String wrong) {
    return '$example, never $wrong';
  }

  @override
  String get vsUsualWay => 'Compared with the usual way';

  @override
  String get csvFormatRows => 'One row per tier; commas or semicolons.';

  @override
  String get faqInternet => 'Do I need internet?';

  @override
  String get faqInternetAnswer =>
      'No. Calculations run on your phone; internet is only used to update the fees.';

  @override
  String get termsIndependenceTitle => 'Independence';

  @override
  String get termsIndependenceContent =>
      'Feezer is not affiliated with any operator and is not responsible for the fees charged.';

  @override
  String get termsAcceptance => 'By using Feezer, you accept these terms.';
}
