// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malagasy (`mg`).
class AppLocalizationsMg extends AppLocalizations {
  AppLocalizationsMg([String locale = 'mg']) : super(locale);

  @override
  String get onboardingTitle1 => 'Mandoava sarany kely kokoa';

  @override
  String get onboardingDescription1 =>
      'Ampidiro ny vola: zarain\'i Feezer ho fifanakalozana mora indrindra izany.';

  @override
  String get onboardingTitle2 => 'Ny tena saran\'ny mpandraharaha';

  @override
  String get onboardingDescription2 =>
      'MVola, Orange Money, Airtel Money: avy amin\'ny saran\'ny mpandraharaha ofisialy ny tabilao ary havaozina amin\'ny tsindry iray.';

  @override
  String get onboardingTitle3 => 'Fisintonana sy famindrana';

  @override
  String get onboardingDescription3 =>
      'Fidio ny mpandraharaha sy ny fifanakalozana. Mijanona ao amin\'ny findainao ny angon-drakitrao, na tsy misy aterineto aza.';

  @override
  String get next => 'Manaraka';

  @override
  String get skip => 'Handingana';

  @override
  String get getStarted => 'Hanomboka';

  @override
  String get cancel => 'Aoka ihany';

  @override
  String get delete => 'Fafao';

  @override
  String get settings => 'Fandrindrana';

  @override
  String get createInterval => 'Hanampy ny ambaratonga';

  @override
  String get optimize => 'Atsikafo';

  @override
  String get pleaseEnterValidAmount => 'Vola tsy mety';

  @override
  String get pleaseSelectProvider => 'Misafidiana mpandraharaha';

  @override
  String get appearance => 'Fisehoana';

  @override
  String get language => 'Fiteny';

  @override
  String get system => 'Rafitra';

  @override
  String get light => 'Mazava';

  @override
  String get dark => 'Maizina';

  @override
  String get newFeeInterval => 'Ambaratonga vaovao';

  @override
  String get maxAmountMustBeGreaterThanMinAmount =>
      'Tsy maintsy mihoatra ny farafahakeliny';

  @override
  String get fee => 'Sara';

  @override
  String get noOptimizationResultsFound => 'Tsy misy valiny';

  @override
  String get about => 'Momba';

  @override
  String get termsOfUse => 'Fepetra fampiasana';

  @override
  String get termsServiceTitle => 'Ny tolotra';

  @override
  String get termsServiceContent =>
      'Kajian\'i Feezer ny fomba hizarana fisintonana na famindrana mba handoavana sarany kely indrindra, araka ny tabilaon\'ny mpandraharaha.';

  @override
  String get termsPrivacyTitle => 'Ny angon-drakitrao';

  @override
  String get termsPrivacyContent =>
      'Tsy misy kaonty, tsy misy angona angonina. Mijanona ao amin\'ny findainao ny tabilao sy ny kajinao.';

  @override
  String get termsLiabilityTitle => 'Andraikitra';

  @override
  String get termsLiabilityContent =>
      'Fampahafantarana fotsiny ny valiny: mety hanova ny sarany ny mpandraharaha. Hamarino alohan\'ny fifanakalozana tsirairay.';

  @override
  String get termsContactTitle => 'Fifandraisana';

  @override
  String get noFeeIntervalsFound => 'Tsy misy ambaratonga ity tabilao ity';

  @override
  String get addFeeInterval => 'Hanampy ambaratonga';

  @override
  String get deleteFeeIntervals => 'Hamafa ny ambaratonga';

  @override
  String get feeIntervalCreatedSuccessfully => 'Tafiditra ny ambaratonga';

  @override
  String get icon => 'Sary famantarana';

  @override
  String get thisFieldIsRequired => 'Ilaina';

  @override
  String get feeIntervalUpdatedSuccessfully => 'Voaova ny ambaratonga';

  @override
  String feeIntervalDeletedSuccessfully(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Voafafa ny ambaratonga $count',
      one: 'Voafafa ny ambaratonga',
    );
    return '$_temp0';
  }

  @override
  String get editFeeInterval => 'Hanova ny ambaratonga';

  @override
  String get minTransactionsCannotBeGreaterThanMax =>
      'Farafahakeliny > farafahabetsany';

  @override
  String get pleaseEnterValidFee => 'Sarany tsy mety';

  @override
  String get helpAndSupport => 'Fanampiana';

  @override
  String get addNewProvider => 'Hanampy mpandraharaha';

  @override
  String get saveChanges => 'Tehirizina';

  @override
  String confirmDeleteIntervals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hesorina amin\'ny tabilao ireo ambaratonga $count ireo.',
      one: 'Hesorina amin\'ny tabilao ity ambaratonga ity.',
    );
    return '$_temp0';
  }

  @override
  String get failedToCalculateOptimization => 'Tsy nahomby ny kajy';

  @override
  String get importExportData => 'Hampiditra / hamoaka';

  @override
  String get importData => 'Hampiditra';

  @override
  String get exportData => 'Hamoaka';

  @override
  String get importSuccessful => 'Vita ny fampidirana';

  @override
  String importFailed(String error) {
    return 'Tsy nahomby ny fampidirana: $error';
  }

  @override
  String exportFailed(String error) {
    return 'Tsy nahomby ny famoahana: $error';
  }

  @override
  String errorsEncountered(int count) {
    return 'Hadisoana $count';
  }

  @override
  String get csvContentCannotBeEmpty => 'Foana ny lahatsoratra';

  @override
  String get chooseWhereToSave => 'Tehirizo ny rakitra';

  @override
  String get fileSavedSuccessfully => 'Voatahiry ny rakitra';

  @override
  String get failedToSaveFile => 'Tsy voatahiry ny rakitra';

  @override
  String get csvFileIsEmpty => 'Foana ny rakitra';

  @override
  String get noDataRowsFound => 'Tsy misy andalana';

  @override
  String rowProviderNameRequired(int rowNumber) {
    return 'Andalana $rowNumber: tsy misy mpandraharaha';
  }

  @override
  String rowProviderAlreadyExists(int rowNumber, String name) {
    return 'Andalana $rowNumber: efa misy « $name »';
  }

  @override
  String rowIntervalOverlaps(int rowNumber, String overlap) {
    return 'Andalana $rowNumber: mifanindry amin\'ny $overlap';
  }

  @override
  String rowInvalidAmounts(
    int rowNumber,
    String minStr,
    String maxStr,
    String feeStr,
  ) {
    return 'Andalana $rowNumber: vola tsy mety ($minStr, $maxStr, $feeStr)';
  }

  @override
  String rowMinAmountGreaterThanMax(int rowNumber, String min, String max) {
    return 'Andalana $rowNumber: min $min > max $max';
  }

  @override
  String rowFeeMustBePositive(int rowNumber) {
    return 'Andalana $rowNumber: sarany latsaky ny 0';
  }

  @override
  String rowFeePercentageInvalid(int rowNumber, String fee) {
    return 'Andalana $rowNumber: isan-jato ivelan\'ny 0–100 ($fee)';
  }

  @override
  String importedProvidersAndFees(int providersCount, int feesCount) {
    return 'Tabilao $providersCount, ambaratonga $feesCount';
  }

  @override
  String get noDataToExport => 'Tsy misy tabilao havoaka';

  @override
  String get providerNameColumnNotFound =>
      'Tsy hita ny tsanganana mpandraharaha';

  @override
  String get fixedAmount => 'Vola raikitra';

  @override
  String get percentage => 'Isan-jato';

  @override
  String get percentageMustBeBetween0And100 => 'Eo anelanelan\'ny 0 sy 100';

  @override
  String get faq => 'Fanontaniana matetika';

  @override
  String get faqExportData => 'Ahoana no hitahirizana ny tabilaoko?';

  @override
  String get faqExportDataAnswer =>
      'Ao amin\'ny Fandrindrana › Hampiditra / hamoaka, avoahy ho rakitra CSV izy ireo, dia ampidiro amin\'ny finday hafa.';

  @override
  String get website => 'Tranonkala';

  @override
  String get contactUs => 'Hifandray aminay';

  @override
  String get email => 'Email';

  @override
  String get optimizationBudgetTooSmall =>
      'Kely loatra ny vola ho an\'ity tabilao ity';

  @override
  String get optimizationConstraintsUnsatisfiable =>
      'Tsy azo atao amin\'io fetra io';

  @override
  String feeIntervalOverlaps(String range) {
    return 'Mifanindry amin\'ny ambaratonga $range';
  }

  @override
  String get failedToDeleteFeeIntervals => 'Tsy voafafa';

  @override
  String get failedToSaveChanges => 'Tsy voatahiry';

  @override
  String get tabOptimize => 'Hanatsara';

  @override
  String get add => 'Hanampy';

  @override
  String get amountAvailable => 'Vola azo ampiasaina';

  @override
  String get amountHelper => 'Tafiditra ny sarany';

  @override
  String get transferCount => 'Isan\'ny fandefasana';

  @override
  String get transferCountFree => 'Tsy voafetra';

  @override
  String transferCountExactly(int count) {
    return '$count marina';
  }

  @override
  String transferCountRange(int min, int max) {
    return 'Eo anelanelan\'ny $min sy $max';
  }

  @override
  String transferCountAtLeast(int count) {
    return 'Farafahakeliny $count';
  }

  @override
  String transferCountAtMost(int count) {
    return 'Farafahabetsany $count';
  }

  @override
  String get minimumShort => 'Farafahakeliny';

  @override
  String get maximumShort => 'Farafahabetsany';

  @override
  String get anyCount => 'Malalaka';

  @override
  String get recipientReceives => 'Ho azon\'ny mpandray';

  @override
  String get bestSplit => 'Tsara indrindra';

  @override
  String get goodSplit => 'Tsara dia tsara';

  @override
  String transferCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'fandefasana $count',
      one: 'fandefasana 1',
    );
    return '$_temp0';
  }

  @override
  String get feesLabel => 'Sarany';

  @override
  String get debitedLabel => 'Nesorina';

  @override
  String get leftLabel => 'Sisa';

  @override
  String gainTitle(String amount) {
    return '+$amount fanampiny voaray';
  }

  @override
  String feesSavedTitle(String amount) {
    return '$amount sarany voatsitsy';
  }

  @override
  String get alreadyOptimalTitle => 'Efa tsara indrindra ny fomba mahazatra';

  @override
  String limitCost(String amount) {
    return 'Mandany $amount ny fetranao';
  }

  @override
  String get planTitle => 'Drafitra fandefasana';

  @override
  String sendAmount(String amount) {
    return 'Alefaso $amount';
  }

  @override
  String feePerTransfer(String amount) {
    return 'sarany $amount isaky ny fandefasana';
  }

  @override
  String get compareTitle => 'Fampitahana';

  @override
  String get optimizedColumn => 'Voahatsara';

  @override
  String get classicColumn => 'Mahazatra';

  @override
  String get receivedLabel => 'Voaray';

  @override
  String get transfersLabel => 'Fandefasana';

  @override
  String get classicExplanation =>
      'Mahazatra: alefa ny be indrindra, avy eo ny sisa';

  @override
  String get classicPlan => 'Drafitra mahazatra';

  @override
  String get showDetails => 'Hijery ny antsipiriany';

  @override
  String get showLess => 'Hanafina ny antsipiriany';

  @override
  String get noProvidersYet => 'Tsy misy tabilao';

  @override
  String tierCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ambaratonga $count',
      one: 'Ambaratonga 1',
      zero: 'Tsy misy ambaratonga',
    );
    return '$_temp0';
  }

  @override
  String feesFrom(String amount) {
    return 'sarany manomboka amin\'ny $amount';
  }

  @override
  String get providerNameHint => 'oh. MVola, ny bankiko';

  @override
  String get descriptionOptional => 'Famaritana (tsy voatery)';

  @override
  String get feeGrid => 'Tabilaon\'ny sarany';

  @override
  String get amountRange => 'Vola alefa';

  @override
  String get downloadingFees => 'Eo am-pakana…';

  @override
  String get feesDownloadFailed => 'Hamarino ny fifandraisanao';

  @override
  String get feesAlreadyUpToDate => 'Efa vaovao ny saranao';

  @override
  String get updateAction => 'Havaozina';

  @override
  String get feesUpdatedSuccessfully => 'Voavao ny sarany';

  @override
  String get replayIntroduction => 'Hijery indray ny fampidirana';

  @override
  String get faqFeeUpdate => 'Avy aiza ny sarany?';

  @override
  String get faqFeeUpdateAnswer =>
      'Avy amin\'ny sarany ofisialy an\'i MVola, Orange Money ary Airtel Money. Tsindrio « Havaozina » hahazoana ny farany.';

  @override
  String get ok => 'Eny';

  @override
  String get pasteCsv => 'Hametaka lahatsoratra CSV';

  @override
  String get chooseCsvFile => 'Hisafidy rakitra CSV';

  @override
  String get csvTemplate => 'Modely';

  @override
  String get downloadTemplate => 'Haka ny modely';

  @override
  String get csvFormat => 'Endriky ny rakitra';

  @override
  String get opWithdrawal => 'Fisintonana';

  @override
  String get opTransferSame => 'Famindrana';

  @override
  String get opTransferSameApp => 'Famindrana amin\'ny appli';

  @override
  String get opTransferOther => 'Mankany amin\'ny mpandraharaha hafa';

  @override
  String get opTransferMicrofinance => 'Mankany amin\'ny microfinance';

  @override
  String get opTransferUnregistered => 'Mankany amin\'ny tsy mpanjifa';

  @override
  String get opCustom => 'Hafa';

  @override
  String get operators => 'Mpandraharaha';

  @override
  String get operatorLabel => 'Mpandraharaha';

  @override
  String get operationLabel => 'Fifanakalozana';

  @override
  String get operatorName => 'Anaran\'ny mpandraharaha';

  @override
  String gridCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tabilao $count',
      one: 'tabilao 1',
    );
    return '$_temp0';
  }

  @override
  String get customGrids => 'Nampidirinao';

  @override
  String get editedTag => 'novaina';

  @override
  String get newGrid => 'Tabilao vaovao';

  @override
  String get editGrid => 'Hanova ny tabilao';

  @override
  String get createGrid => 'Hamorona ny tabilao';

  @override
  String get gridCreated => 'Voaforona ny tabilao';

  @override
  String get gridUpdated => 'Voaova ny tabilao';

  @override
  String get gridDeleted => 'Voafafa ny tabilao';

  @override
  String gridAlreadyExists(String name) {
    return 'Efa misy $name';
  }

  @override
  String get deleteGridTitle => 'Hamafa ny tabilao';

  @override
  String deleteGridMessage(String name) {
    return 'Ho voafafa $name sy ny ambaratongany.';
  }

  @override
  String get optimizeWithGrid => 'Hanatsara amin\'ity tabilao ity';

  @override
  String get moreOptions => 'Safidy hafa';

  @override
  String get officialFees => 'Sarany ofisialy';

  @override
  String feesCheckedOn(String date) {
    return 'Nohamarinina ny $date';
  }

  @override
  String get feesNeverChecked => 'Mbola tsy nohamarinina';

  @override
  String sourceOfficial(String host) {
    return 'Tabilao ofisialy · $host';
  }

  @override
  String sourceOfficialDated(String host, String date) {
    return 'Tabilao ofisialy · $host · $date';
  }

  @override
  String get sourceManual => 'Saran\'ny mpandraharaha';

  @override
  String sourceManualDated(String date) {
    return 'Saran\'ny mpandraharaha · $date';
  }

  @override
  String get sourceEdited => 'Novainao';

  @override
  String get editPublishedGridWarning =>
      'Hofafan\'ny fanavaozana ny sarany ity fanovana ity.';

  @override
  String get feesSection => 'Sarany';

  @override
  String get updateFeesTitle => 'Havaozina ny sarany';

  @override
  String get feesDownloadFailedTitle => 'Tsy nahomby ny fakana';

  @override
  String get updateReviewIntro => 'Sarany vaovao navoaka:';

  @override
  String effectiveSince(String date) {
    return 'hatramin\'ny $date';
  }

  @override
  String get newTag => 'Vaovao';

  @override
  String get updatedTag => 'Novaina';

  @override
  String get later => 'Any aoriana';

  @override
  String get retry => 'Andramo indray';

  @override
  String get withdrawalCount => 'Isan\'ny fisintonana';

  @override
  String get cashYouReceive => 'Vola raisinao an-tanana';

  @override
  String withdrawalCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'fisintonana $count',
      one: 'fisintonana 1',
    );
    return '$_temp0';
  }

  @override
  String get withdrawalsLabel => 'Fisintonana';

  @override
  String withdrawAmount(String amount) {
    return 'Misintona $amount';
  }

  @override
  String feePerWithdrawal(String amount) {
    return 'sarany $amount isaky ny fisintonana';
  }

  @override
  String get planTitleWithdrawal => 'Drafitra fisintonana';

  @override
  String get classicExplanationWithdrawal =>
      'Mahazatra: sintonina ny be indrindra, avy eo ny sisa';

  @override
  String get amountWithdrawn => 'Vola sintonina';

  @override
  String get noTiersYet => 'Tsy misy ambaratonga';

  @override
  String versionLabel(String version) {
    return 'Dikan-teny $version';
  }

  @override
  String get free => 'Maimaim-poana';

  @override
  String get failedToLoadData => 'Tsy voaray ny angona';

  @override
  String get failedToOpenLink => 'Tsy nety nisokatra ny rohy';

  @override
  String get pressAgainToExit => 'Tsindrio indray mba hivoaka';

  @override
  String get optimizationStepTooLarge =>
      'Esory ny boribory ho an\'ity tabilao ity';

  @override
  String get roundToHundred => 'Boribory amin\'ny zato';

  @override
  String get roundToHundredOff => 'Vola marina';

  @override
  String get faqHowItWorks => 'Ahoana no fiasany?';

  @override
  String get faqHowItWorksAnswer =>
      'Fidio ny mpandraharaha, ny fifanakalozana ary ny vola azo ampiasaina. Tadiavin\'i Feezer ny fizarana mora sarany indrindra.';

  @override
  String get faqRounding => 'Nahoana no boribory amin\'ny zato?';

  @override
  String get faqRoundingAnswer =>
      'Taratasim-bola ihany no omena rehefa misintona: tsy azo sintonina ny 10 040. Azonao esorina amin\'ny fotoana rehetra ny boribory.';

  @override
  String get faqPrivacy => 'Zaraina ve ny angon-drakitro?';

  @override
  String get faqPrivacyAnswer =>
      'Tsia. Tsy mila kaonty i Feezer ary tsy misy miala amin\'ny findainao.';

  @override
  String roundToHundredOn(String example, String wrong) {
    return '$example, fa tsy $wrong';
  }

  @override
  String get vsUsualWay => 'Raha oharina amin\'ny fomba mahazatra';

  @override
  String get csvFormatRows =>
      'Andalana iray isaky ny ambaratonga; faingo na teboka sy faingo.';

  @override
  String get faqInternet => 'Mila aterineto ve?';

  @override
  String get faqInternetAnswer =>
      'Tsia. Ao amin\'ny findainao no anaovana ny kajy; ny fanavaozana ny sarany ihany no mila aterineto.';

  @override
  String get termsIndependenceTitle => 'Fahaleovan-tena';

  @override
  String get termsIndependenceContent =>
      'Tsy mifandray amin\'ny mpandraharaha i Feezer ary tsy tompon\'andraikitra amin\'ny sarany aloa.';

  @override
  String get termsAcceptance =>
      'Raha mampiasa an\'i Feezer ianao dia manaiky ireo fepetra ireo.';
}
