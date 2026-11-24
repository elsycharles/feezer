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
  String get onboardingDescription1 =>
      'Enter an amount: Feezer splits it into the transactions that cost the least in fees.';

  @override
  String get onboardingTitle2 => 'Real operator fees';

  @override
  String get onboardingDescription2 =>
      'MVola, Orange Money, Airtel Money: the grids come from the operators\' official rates and update in one tap.';

  @override
  String get onboardingTitle3 => 'Withdrawals and transfers';

  @override
  String get onboardingDescription3 =>
      'Choose the operator and the operation. Your data stays on your phone, even offline.';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

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
  String get pleaseEnterValidAmount => 'Please enter a valid amount';

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
  String get maxAmountMustBeGreaterThanMinAmount =>
      'Max amount must be greater than min amount';

  @override
  String get fee => 'Fee';

  @override
  String get noOptimizationResultsFound =>
      'No result. Check the amount and the chosen grid.';

  @override
  String get about => 'About';

  @override
  String get faqAndContact => 'FAQ and contact';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get termsIntroductionTitle => 'Introduction';

  @override
  String get termsIntroductionContent =>
      'These terms apply to the Feezer app, which helps you reduce mobile money fees. By using Feezer, you accept them.';

  @override
  String get termsAcceptanceTitle => 'Acceptance';

  @override
  String get termsAcceptanceContent =>
      'If you do not accept these terms, do not use the app. They may change with new versions of Feezer.';

  @override
  String get termsServiceTitle => 'The service';

  @override
  String get termsServiceContent =>
      'From fee grids, Feezer calculates how to split a withdrawal or a transfer to pay less in fees. The official grids are read on the operators\' websites and may change at any time: always check the fees with your operator.';

  @override
  String get termsPrivacyTitle => 'Privacy';

  @override
  String get termsPrivacyContent =>
      'Feezer requires no account and collects no personal data. Your grids and calculations stay on your phone. Updating the fees downloads a public file without sending your data.';

  @override
  String get termsLiabilityTitle => 'Liability';

  @override
  String get termsLiabilityContent =>
      'Results are given for information only. Feezer is not affiliated with any operator and is not responsible for the fees actually charged, nor for decisions made from its calculations.';

  @override
  String get termsTerminationTitle => 'Stopping';

  @override
  String get termsTerminationContent =>
      'You can stop using Feezer at any time: uninstalling the app erases its data from your phone.';

  @override
  String get termsGoverningLawTitle => 'Governing law';

  @override
  String get termsGoverningLawContent =>
      'These terms are governed by the laws that apply where Feezer is used. Any dispute will be handled through the legal means provided by those laws.';

  @override
  String get termsContactTitle => 'Contact';

  @override
  String get termsContactContent =>
      'A question? Write to us from Help & support, or at elsy.s.charles@gmail.com.';

  @override
  String get noFeeIntervalsFound =>
      'This grid has no tier yet. Add them in the Operators tab.';

  @override
  String get addFeeInterval => 'Add a tier';

  @override
  String get deleteFeeIntervals => 'Delete the tier';

  @override
  String get feeIntervalCreatedSuccessfully => 'Tier added';

  @override
  String get icon => 'Icon';

  @override
  String get thisFieldIsRequired => 'This field is required';

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
  String get minTransactionsCannotBeGreaterThanMax =>
      'Min transactions cannot be greater than max';

  @override
  String get pleaseEnterValidFee => 'Please enter a valid fee';

  @override
  String get minimumAmount => 'Minimum amount';

  @override
  String get maximumAmount => 'Maximum amount';

  @override
  String get helpAndSupport => 'Help & support';

  @override
  String get addNewProvider => 'Add new provider';

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
  String get failedToCalculateOptimization =>
      'Failed to calculate optimization';

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
  String providersImported(int count) {
    return '$count grid(s) imported';
  }

  @override
  String feeIntervalsImported(int count) {
    return '$count tier(s) imported';
  }

  @override
  String errorsEncountered(int count) {
    return '$count error(s) encountered';
  }

  @override
  String get importDataDescription =>
      'Add grids from a CSV file (one row per tier).';

  @override
  String get exportDataDescription =>
      'Save all your grids and their tiers in a CSV file.';

  @override
  String get csvContentCannotBeEmpty => 'CSV content cannot be empty';

  @override
  String get chooseWhereToSave => 'Choose where to save the file';

  @override
  String get fileSavedSuccessfully => 'File saved successfully';

  @override
  String get failedToSaveFile => 'Failed to save file';

  @override
  String get csvFileIsEmpty => 'CSV file is empty';

  @override
  String get noDataRowsFound => 'No data rows found';

  @override
  String rowProviderNameRequired(int rowNumber) {
    return 'Row $rowNumber: the operator name is required';
  }

  @override
  String rowProviderAlreadyExists(int rowNumber, String name) {
    return 'Row $rowNumber: the grid \"$name\" already exists';
  }

  @override
  String rowIntervalOverlaps(int rowNumber, String overlap) {
    return 'Row $rowNumber: this tier overlaps an existing tier ($overlap)';
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
    return 'Imported $providersCount grid(s) and $feesCount tier(s)';
  }

  @override
  String get noDataToExport => 'No data to export';

  @override
  String get providerNameColumnNotFound => 'Operator name column not found';

  @override
  String get fixedAmount => 'Fixed amount';

  @override
  String get percentage => 'Percentage';

  @override
  String get percentageMustBeBetween0And100 =>
      'Percentage must be between 0 and 100';

  @override
  String get faq => 'FAQ';

  @override
  String get faqWhatIsFeeMinimizer => 'What is Feezer?';

  @override
  String get faqWhatIsFeeMinimizerAnswer =>
      'Feezer works out how to split a mobile money withdrawal or transfer so you pay the least fees, using the operators\' official fee grids.';

  @override
  String get faqHowToAddProvider => 'How do I add a grid?';

  @override
  String get faqHowToAddProviderAnswer =>
      'In the Operators tab, tap \"Add\", enter the operator name and the operation, then add the tiers (minimum, maximum and fee). You can also import a CSV file.';

  @override
  String get faqHowToCalculateFees => 'How is it calculated?';

  @override
  String get faqHowToCalculateFeesAnswer =>
      'Choose the operator and the operation, then enter the amount available (fees included). Feezer tries every combination of tiers and keeps the one that delivers the most. The result is compared with the usual way: withdrawing or sending the largest possible amount each time.';

  @override
  String get faqMinMaxTransactionRange =>
      'What is the number of transactions for?';

  @override
  String get faqMinMaxTransactionRangeAnswer =>
      'It is optional. It limits how many withdrawals or transfers the split may use, for example \"at most 2\" if you do not want more than two. Feezer shows what the limit costs you.';

  @override
  String get faqDataSecurity => 'Is my data shared?';

  @override
  String get faqDataSecurityAnswer =>
      'No. Your grids and amounts stay on your phone; Feezer has no account and sends nothing. Updating the fees only downloads a public file.';

  @override
  String get faqOfflineMode => 'Do I need internet?';

  @override
  String get faqOfflineModeAnswer =>
      'No. Calculations run on your phone. Internet is only used to update the fees.';

  @override
  String get faqExportData => 'How do I back up my grids?';

  @override
  String get faqExportDataAnswer =>
      'Settings › Import / export: export your grids to a CSV file, then import it later or on another phone.';

  @override
  String get website => 'Website';

  @override
  String get contactUs => 'Contact us';

  @override
  String get email => 'Email';

  @override
  String get exceedsEnteredAmount => 'Exceeds entered amount';

  @override
  String get optimizationBudgetTooSmall =>
      'The amount is too small for a transaction with this grid.';

  @override
  String get optimizationConstraintsUnsatisfiable =>
      'No split respects this number of transactions for this amount.';

  @override
  String get optimizationNotProven =>
      'Very long search: this split is excellent but could not be proven to be the best.';

  @override
  String feeIntervalOverlaps(String range) {
    return 'This tier overlaps an existing tier ($range).';
  }

  @override
  String get failedToDeleteFeeIntervals => 'Could not delete the tier';

  @override
  String get failedToSaveChanges => 'Failed to save changes';

  @override
  String get tabOptimize => 'Optimize';

  @override
  String get optimizeTitle => 'Pay less in fees';

  @override
  String get optimizeSubtitle =>
      'Feezer splits your amount into the transactions that cost the least.';

  @override
  String get add => 'Add';

  @override
  String get amountAvailable => 'Amount available';

  @override
  String get amountHelper =>
      'Fees included: the total that will leave your account.';

  @override
  String get transferCount => 'Number of transfers';

  @override
  String get transferCountHelp =>
      'Optional. Limit how many transfers the plan may use.';

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
  String get gainVsClassic =>
      'Compared to sending the largest possible amount each time.';

  @override
  String feesSavedTitle(String amount) {
    return '$amount of fees saved';
  }

  @override
  String get feesSavedVsClassic =>
      'The usual way would cost more for the same amount.';

  @override
  String get alreadyOptimalTitle => 'The usual way is already the best';

  @override
  String get alreadyOptimalMessage =>
      'For this amount, splitting brings nothing more.';

  @override
  String limitCost(String amount) {
    return 'Without this limit, $amount more would be received.';
  }

  @override
  String get limitFree => 'This limit costs you nothing here.';

  @override
  String get nearOptimalTitle => 'Very large amount';

  @override
  String get planTitle => 'Your transfer plan';

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
  String get classicExplanation =>
      'Usual way: send the largest possible amount, then the rest.';

  @override
  String get sameAmountByHand => 'Same amount received, usual way';

  @override
  String sameAmountByHandDetail(String net, String fees, String total) {
    return 'To get $net, the usual way costs $fees in fees, i.e. $total debited.';
  }

  @override
  String get cannotSplitByHand => 'The usual way cannot reach this amount.';

  @override
  String get classicPlan => 'Usual plan';

  @override
  String get showDetails => 'Show details';

  @override
  String get showLess => 'Hide details';

  @override
  String get noProvidersYet => 'No grid yet';

  @override
  String get noProvidersMessage =>
      'Update the official fees, or add your own grid.';

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
  String get providerNameHint => 'e.g. MVola, Orange Money, my bank';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get feeGrid => 'Fee grid';

  @override
  String get amountRange => 'Amount sent';

  @override
  String get noIntervalsMessage =>
      'Add the tiers of this grid to optimize your transactions.';

  @override
  String get gridHint => 'Tap a tier to edit or delete it.';

  @override
  String get intervalFormHelp =>
      'The fee applies when the amount sent is between the minimum and the maximum (included).';

  @override
  String get downloadingFees => 'Reading the published fee grids…';

  @override
  String get feesDownloadFailed => 'Check your connection and try again.';

  @override
  String get feesAlreadyUpToDate => 'Your fees are up to date';

  @override
  String get gridsOthersUnchanged => 'Your other grids do not change.';

  @override
  String get updateAction => 'Update';

  @override
  String get feesUpdatedSuccessfully => 'Fees updated';

  @override
  String get importExportSubtitle => 'Back up or share your grids (CSV)';

  @override
  String get replayIntroduction => 'Replay the introduction';

  @override
  String get faqFeeUpdate => 'Where do the fees come from?';

  @override
  String get faqFeeUpdateAnswer =>
      'Every day, the public feezer-fee-tables project reads the official grids on mvola.mg and orange.mg. The Airtel grid is copied by hand from its rates, because its website cannot be read automatically. \"Update\" downloads these grids; your other grids stay the same.';

  @override
  String get ok => 'OK';

  @override
  String get pasteCsv => 'Paste CSV text';

  @override
  String get chooseCsvFile => 'Choose a CSV file';

  @override
  String get csvTemplate => 'Template';

  @override
  String get csvTemplateDescription =>
      'Start from a ready-made file with the expected columns.';

  @override
  String get downloadTemplate => 'Download the template';

  @override
  String get csvFormat => 'File format';

  @override
  String get csvFormatHelp =>
      'One row per tier. Rows with the same provider_name and operation form one grid. operation is withdrawal, transfer_same, transfer_same_app, transfer_other, transfer_microfinance or transfer_unregistered (optional); fee_type is fixed or percentage. Commas or semicolons are accepted.';

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
  String get operatorsSubtitle => 'The fee grids used for your calculations.';

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
    return 'The grid $name already exists.';
  }

  @override
  String get deleteGridTitle => 'Delete the grid';

  @override
  String deleteGridMessage(String name) {
    return 'The grid $name and its tiers will be deleted.';
  }

  @override
  String get optimizeWithGrid => 'Optimize with this grid';

  @override
  String get moreOptions => 'More options';

  @override
  String get officialFees => 'Official fees';

  @override
  String feesCheckedOn(String date) {
    return 'Checked on the operators\' websites on $date';
  }

  @override
  String get feesNeverChecked =>
      'Download the latest fees published by the operators.';

  @override
  String sourceOfficial(String host) {
    return 'Official grid · $host';
  }

  @override
  String sourceOfficialDated(String host, String date) {
    return 'Official grid · $host · $date';
  }

  @override
  String get sourceManual => 'Grid copied from the operator\'s rates';

  @override
  String sourceManualDated(String date) {
    return 'Grid copied from the operator\'s rates · $date';
  }

  @override
  String get sourceEdited => 'Grid edited by you';

  @override
  String get openSource => 'See the official page';

  @override
  String get editPublishedGridWarning =>
      'This grid comes from the operator\'s rates. If you update the fees later, your change will be replaced.';

  @override
  String get feesSection => 'Fees';

  @override
  String get updateFeesTitle => 'Update the fees';

  @override
  String get feesDownloadFailedTitle => 'Download failed';

  @override
  String get updateReviewIntro =>
      'The operators published new fees. Here is what changes:';

  @override
  String effectiveSince(String date) {
    return 'in force since $date';
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
  String get withdrawalCountHelp =>
      'Optional. Limit how many withdrawals the plan may use.';

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
  String get planTitleWithdrawal => 'Your withdrawal plan';

  @override
  String get gainVsClassicWithdrawal =>
      'Compared to withdrawing the largest possible amount each time.';

  @override
  String get classicExplanationWithdrawal =>
      'Usual way: withdraw the largest possible amount, then the rest.';

  @override
  String get amountWithdrawn => 'Amount withdrawn';

  @override
  String get noTiersYet => 'No tier yet';

  @override
  String get intervalFormHelpWithdrawal =>
      'The fee applies when the amount withdrawn is between the minimum and the maximum (included).';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get free => 'Free';

  @override
  String get failedToLoadData => 'Could not load the data';

  @override
  String get failedToOpenLink => 'Could not open the link';

  @override
  String get pressAgainToExit => 'Press again to exit';
}
