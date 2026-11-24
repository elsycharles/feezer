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
  String get pleaseEnterValidAmount => 'Ampidiro ny vola manan-kery azafady';

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
      'Ny vola be dia tsy maintsy mihoatra ny vola kely';

  @override
  String get fee => 'Sara';

  @override
  String get noOptimizationResultsFound =>
      'Tsy misy valiny. Hamarino ny vola sy ny tabilao nofidina.';

  @override
  String get about => 'Momba';

  @override
  String get faqAndContact => 'Fanontaniana sy fifandraisana';

  @override
  String get termsOfUse => 'Fepetra fampiasana';

  @override
  String get termsIntroductionTitle => 'Fampidirana';

  @override
  String get termsIntroductionContent =>
      'Mihatra amin\'ny fampiharana Feezer, izay manampy anao hampihena ny saran\'ny vola finday, ireto fepetra ireto. Raha mampiasa an\'i Feezer ianao dia manaiky azy ireo.';

  @override
  String get termsAcceptanceTitle => 'Fanekena';

  @override
  String get termsAcceptanceContent =>
      'Raha tsy manaiky ireo fepetra ireo ianao dia aza mampiasa ny fampiharana. Mety hiova izy ireo miaraka amin\'ny dikan-teny vaovaon\'i Feezer.';

  @override
  String get termsServiceTitle => 'Ny tolotra';

  @override
  String get termsServiceContent =>
      'Avy amin\'ny tabilaon\'ny sarany, manisa ny fomba hizarana fisintonana na famindrana i Feezer mba handoavana sarany kely kokoa. Vakiana amin\'ny tranokalan\'ny mpandraharaha ny tabilao ofisialy ary mety hiova na oviana na oviana: hamarino foana amin\'ny mpandraharahanao ny sarany.';

  @override
  String get termsPrivacyTitle => 'Tsiambaratelo';

  @override
  String get termsPrivacyContent =>
      'Tsy mila kaonty i Feezer ary tsy manangona angon-drakitra manokana. Mijanona ao amin\'ny findainao ny tabilao sy ny kajinao. Ny fanavaozana ny sarany dia maka rakitra ho an\'ny besinimaro fotsiny, tsy mandefa ny angon-drakitrao.';

  @override
  String get termsLiabilityTitle => 'Andraikitra';

  @override
  String get termsLiabilityContent =>
      'Ho fampahafantarana fotsiny ny valiny. Tsy mifandray amin\'ny mpandraharaha na iray aza i Feezer ary tsy tompon\'andraikitra amin\'ny sarany tena aloa, na amin\'ny fanapahan-kevitra noraisina avy amin\'ny kajiny.';

  @override
  String get termsTerminationTitle => 'Fijanonana';

  @override
  String get termsTerminationContent =>
      'Afaka mijanona tsy mampiasa an\'i Feezer ianao na oviana na oviana: voafafa ao amin\'ny findainao ny angon-drakiny rehefa esorina ilay fampiharana.';

  @override
  String get termsGoverningLawTitle => 'Lalàna mifehy';

  @override
  String get termsGoverningLawContent =>
      'Fehezin\'ny lalàna mihatra any amin\'ny toerana ampiasana an\'i Feezer ireo fepetra ireo. Hovahana amin\'ny fomba ara-dalàna voalazan\'ireo lalàna ireo ny disadisa rehetra.';

  @override
  String get termsContactTitle => 'Fifandraisana';

  @override
  String get termsContactContent =>
      'Manana fanontaniana? Manorata aminay avy amin\'ny Fanampiana, na amin\'ny elsy.s.charles@gmail.com.';

  @override
  String get noFeeIntervalsFound =>
      'Mbola tsy misy ambaratonga ity tabilao ity. Ampio ao amin\'ny Mpandraharaha.';

  @override
  String get addFeeInterval => 'Hanampy ambaratonga';

  @override
  String get deleteFeeIntervals => 'Hamafa ny ambaratonga';

  @override
  String get feeIntervalCreatedSuccessfully => 'Tafiditra ny ambaratonga';

  @override
  String get icon => 'Sary famantarana';

  @override
  String get thisFieldIsRequired => 'Ilaina ity saha ity';

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
      'Ny fampiasana kely indrindra dia tsy afaka mihoatra ny be indrindra';

  @override
  String get pleaseEnterValidFee => 'Ampidiro ny sara manan-kery azafady';

  @override
  String get minimumAmount => 'Vola faran\'izay kely';

  @override
  String get maximumAmount => 'Vola faran\'izay lehibe';

  @override
  String get helpAndSupport => 'Fanampiana';

  @override
  String get addNewProvider => 'Hanampy mpanome tolotra vaovao';

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
  String get failedToCalculateOptimization =>
      'Tsy nahomby ny fanisana ny fanatsarana';

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
    return 'Tsy nahomby ny fanafarana : $error';
  }

  @override
  String exportFailed(String error) {
    return 'Tsy nahomby ny fanavoahana : $error';
  }

  @override
  String providersImported(int count) {
    return 'Tabilao $count nampidirina';
  }

  @override
  String feeIntervalsImported(int count) {
    return 'Ambaratonga $count nampidirina';
  }

  @override
  String errorsEncountered(int count) {
    return '$count tsy fetezana hita';
  }

  @override
  String get importDataDescription =>
      'Hanampy tabilao avy amin\'ny rakitra CSV (andalana iray isaky ny ambaratonga).';

  @override
  String get exportDataDescription =>
      'Tehirizo ao anaty rakitra CSV ny tabilaonao rehetra sy ny ambaratongany.';

  @override
  String get csvContentCannotBeEmpty =>
      'Tsy azo atao ho foana ny votoatin\'ny CSV';

  @override
  String get chooseWhereToSave => 'Misafidy toerana hitehirizana ny rakitra';

  @override
  String get fileSavedSuccessfully => 'Voatahiry soa aman-tsara ny rakitra';

  @override
  String get failedToSaveFile => 'Tsy nahomby ny fitahirizana rakitra';

  @override
  String get csvFileIsEmpty => 'Foana ny rakitra CSV';

  @override
  String get noDataRowsFound => 'Tsy misy andalana angona hita';

  @override
  String rowProviderNameRequired(int rowNumber) {
    return 'Andalana $rowNumber: ilaina ny anaran\'ny mpandraharaha';
  }

  @override
  String rowProviderAlreadyExists(int rowNumber, String name) {
    return 'Andalana $rowNumber: efa misy ny tabilao « $name »';
  }

  @override
  String rowIntervalOverlaps(int rowNumber, String overlap) {
    return 'Andalana $rowNumber: mifanindry amin\'ny ambaratonga efa misy ($overlap)';
  }

  @override
  String rowInvalidAmounts(
    int rowNumber,
    String minStr,
    String maxStr,
    String feeStr,
  ) {
    return 'Andalana $rowNumber : Tsy mety ny vola (kely : $minStr, lehibe : $maxStr, sara : $feeStr)';
  }

  @override
  String rowMinAmountGreaterThanMax(int rowNumber, String min, String max) {
    return 'Andalana $rowNumber : Ny vola kely ($min) tsy maintsy ambany noho ny vola lehibe ($max)';
  }

  @override
  String rowFeeMustBePositive(int rowNumber) {
    return 'Andalana $rowNumber : Tsy maintsy positif ny sara';
  }

  @override
  String rowFeePercentageInvalid(int rowNumber, String fee) {
    return 'Andalana $rowNumber : Tsy maintsy eo anelanelan\'ny 0 sy 100 ny sara isaky ny 100 ($fee%)';
  }

  @override
  String importedProvidersAndFees(int providersCount, int feesCount) {
    return 'Tabilao $providersCount sy ambaratonga $feesCount nampidirina';
  }

  @override
  String get noDataToExport => 'Tsy misy angona havoaka';

  @override
  String get providerNameColumnNotFound =>
      'Tsy hita ny tsanganana misy ny anaran\'ny mpandraharaha';

  @override
  String get fixedAmount => 'Vola raikitra';

  @override
  String get percentage => 'Isan-jato';

  @override
  String get percentageMustBeBetween0And100 =>
      'Ny isan-jato dia tsy maintsy eo anelanelan\'ny 0 sy 100';

  @override
  String get faq => 'Fanontaniana matetika';

  @override
  String get faqWhatIsFeeMinimizer => 'Inona no atao hoe Feezer?';

  @override
  String get faqWhatIsFeeMinimizerAnswer =>
      'Manisa ny fomba hizarana fisintonana na famindram-bola finday i Feezer mba handoavanao sarany kely indrindra, araka ny tabilao ofisialin\'ny mpandraharaha.';

  @override
  String get faqHowToAddProvider => 'Ahoana no hanampiana tabilao?';

  @override
  String get faqHowToAddProviderAnswer =>
      'Ao amin\'ny Mpandraharaha, tsindrio « Hanampy », soraty ny anaran\'ny mpandraharaha sy ny fifanakalozana, dia ampio ny ambaratonga (farafahakeliny, farafahabetsany ary sarany). Azonao atao koa ny mampiditra rakitra CSV.';

  @override
  String get faqHowToCalculateFees => 'Ahoana no anaovana ny kajy?';

  @override
  String get faqHowToCalculateFeesAnswer =>
      'Fidio ny mpandraharaha sy ny fifanakalozana, dia ampidiro ny vola azo ampiasaina (tafiditra ny sarany). Andramin\'i Feezer ny fitambarana rehetra ary tehiriziny izay mahazo vola betsaka indrindra. Ampitahaina amin\'ny fomba mahazatra ny valiny: misintona na mandefa ny vola betsaka indrindra azo atao isaky ny mandeha.';

  @override
  String get faqMinMaxTransactionRange =>
      'Inona no ilana ny isan\'ny fifanakalozana?';

  @override
  String get faqMinMaxTransactionRangeAnswer =>
      'Tsy voatery izy. Mametra ny isan\'ny fisintonana na fandefasana azo atao izy, ohatra « farafahabetsany 2 » raha tsy te hanao mihoatra ny roa ianao. Asehon\'i Feezer izay vidin\'io fetra io.';

  @override
  String get faqDataSecurity => 'Zaraina amin\'olona ve ny angon-drakitro?';

  @override
  String get faqDataSecurityAnswer =>
      'Tsia. Mijanona ao amin\'ny findainao ny tabilao sy ny vola; tsy misy kaonty i Feezer ary tsy mandefa na inona na inona. Rakitra ho an\'ny besinimaro ihany no alain\'ny fanavaozana ny sarany.';

  @override
  String get faqOfflineMode => 'Mila aterineto ve?';

  @override
  String get faqOfflineModeAnswer =>
      'Tsia. Ao amin\'ny findainao no anaovana ny kajy. Ny fanavaozana ny sarany ihany no mila aterineto.';

  @override
  String get faqExportData => 'Ahoana no hitahirizana ny tabilaoko?';

  @override
  String get faqExportDataAnswer =>
      'Fandrindrana › Hampiditra / hamoaka: avoahy ho rakitra CSV ny tabilaonao, dia ampidiro indray any aoriana na amin\'ny finday hafa.';

  @override
  String get website => 'Tranonkala';

  @override
  String get contactUs => 'Hifandray aminay';

  @override
  String get email => 'Email';

  @override
  String get exceedsEnteredAmount => 'Mihoatra ny vola nampidirina';

  @override
  String get optimizationBudgetTooSmall =>
      'Kely loatra ny vola hanaovana fifanakalozana amin\'ity tabilao ity.';

  @override
  String get optimizationConstraintsUnsatisfiable =>
      'Tsy misy fizarana mifanaraka amin\'io isa io ho an\'ity vola ity.';

  @override
  String get optimizationNotProven =>
      'Fikarohana lava be: tsara ity fizarana ity, saingy tsy voaporofo fa izy no tsara indrindra.';

  @override
  String feeIntervalOverlaps(String range) {
    return 'Mifanindry amin\'ny ambaratonga efa misy ($range) ity ambaratonga ity.';
  }

  @override
  String get failedToDeleteFeeIntervals => 'Tsy voafafa ny ambaratonga';

  @override
  String get failedToSaveChanges => 'Tsy nahomby ny fitehirizana ny fanovana';

  @override
  String get tabOptimize => 'Hanatsara';

  @override
  String get optimizeTitle => 'Mandoava sarany kely kokoa';

  @override
  String get optimizeSubtitle =>
      'Zarain\'i Feezer ho fifanakalozana mora indrindra ny volanao.';

  @override
  String get add => 'Hanampy';

  @override
  String get amountAvailable => 'Vola azo ampiasaina';

  @override
  String get amountHelper =>
      'Tafiditra ny sarany: ny vola rehetra hivoaka amin\'ny kaontinao.';

  @override
  String get transferCount => 'Isan\'ny fandefasana';

  @override
  String get transferCountHelp =>
      'Tsy voatery. Fetero ny isan\'ny fandefasana azo ampiasain\'ny drafitra.';

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
  String get gainVsClassic =>
      'Raha ampitahaina amin\'ny fandefasana ny vola betsaka indrindra isaky ny mandefa.';

  @override
  String feesSavedTitle(String amount) {
    return '$amount sarany voatsitsy';
  }

  @override
  String get feesSavedVsClassic =>
      'Lafo kokoa ny fomba mahazatra ho an\'io vola io ihany.';

  @override
  String get alreadyOptimalTitle => 'Ny fomba mahazatra no efa tsara indrindra';

  @override
  String get alreadyOptimalMessage =>
      'Ho an\'ity vola ity, tsy misy tombony ny fizarana.';

  @override
  String limitCost(String amount) {
    return 'Raha tsy misy io fetra io, $amount fanampiny no ho voaray.';
  }

  @override
  String get limitFree =>
      'Tsy mampandany anao na inona na inona io fetra io eto.';

  @override
  String get nearOptimalTitle => 'Vola be dia be';

  @override
  String get planTitle => 'Ny drafitra fandefasanao';

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
      'Fomba mahazatra: alefa ny vola betsaka indrindra azo atao, avy eo ny sisa.';

  @override
  String get sameAmountByHand => 'Vola mitovy voaray, fomba mahazatra';

  @override
  String sameAmountByHandDetail(String net, String fees, String total) {
    return 'Mba hahazoana $net, $fees ny sarany amin\'ny fomba mahazatra, izany hoe $total nesorina.';
  }

  @override
  String get cannotSplitByHand => 'Tsy tratran\'ny fomba mahazatra io vola io.';

  @override
  String get classicPlan => 'Drafitra mahazatra';

  @override
  String get showDetails => 'Hijery ny antsipiriany';

  @override
  String get showLess => 'Hanafina ny antsipiriany';

  @override
  String get noProvidersYet => 'Mbola tsy misy tabilao';

  @override
  String get noProvidersMessage =>
      'Havaozy ny sarany ofisialy, na ampio ny tabilaonao manokana.';

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
  String get providerNameHint => 'oh. MVola, Orange Money, ny bankiko';

  @override
  String get descriptionOptional => 'Famaritana (tsy voatery)';

  @override
  String get feeGrid => 'Tabilaon\'ny sarany';

  @override
  String get amountRange => 'Vola alefa';

  @override
  String get noIntervalsMessage =>
      'Ampio ny ambaratongan\'ity tabilao ity mba hanatsarana ny fifanakalozanao.';

  @override
  String get gridHint =>
      'Tsindrio ny ambaratonga iray raha hanova na hamafa azy.';

  @override
  String get intervalFormHelp =>
      'Ampiharina ny sarany rehefa eo anelanelan\'ny farafahakeliny sy ny farafahabetsany ny vola alefa.';

  @override
  String get downloadingFees => 'Mamaky ny tabilao navoaka…';

  @override
  String get feesDownloadFailed =>
      'Hamarino ny fifandraisanao dia andramo indray.';

  @override
  String get feesAlreadyUpToDate => 'Efa vaovao ny saranao';

  @override
  String get gridsOthersUnchanged => 'Tsy miova ireo tabilao hafa anananao.';

  @override
  String get updateAction => 'Havaozina';

  @override
  String get feesUpdatedSuccessfully => 'Voavao ny sarany';

  @override
  String get importExportSubtitle => 'Hitahiry na hizara ny tabilaonao (CSV)';

  @override
  String get replayIntroduction => 'Hijery indray ny fampidirana';

  @override
  String get faqFeeUpdate => 'Avy aiza ny sarany?';

  @override
  String get faqFeeUpdateAnswer =>
      'Isan\'andro, mamaky ny tabilao ofisialy ao amin\'ny mvola.mg sy orange.mg ny tetikasa feezer-fee-tables. Nadika tamin\'ny tanana avy amin\'ny sarany ny tabilaon\'i Airtel, satria tsy azo vakiana ho azy ny tranokalany. Ny « Havaozina » no maka ireo tabilao ireo; tsy miova ny tabilao hafa anananao.';

  @override
  String get ok => 'Eny';

  @override
  String get pasteCsv => 'Hametaka lahatsoratra CSV';

  @override
  String get chooseCsvFile => 'Hisafidy rakitra CSV';

  @override
  String get csvTemplate => 'Modely';

  @override
  String get csvTemplateDescription =>
      'Manomboha amin\'ny rakitra efa misy ireo tsanganana ilaina.';

  @override
  String get downloadTemplate => 'Haka ny modely';

  @override
  String get csvFormat => 'Endriky ny rakitra';

  @override
  String get csvFormatHelp =>
      'Andalana iray isaky ny ambaratonga. Tabilao iray ireo andalana manana anarany_mpanome sy karazana_fifanakalozana mitovy. withdrawal, transfer_same, transfer_same_app, transfer_other, transfer_microfinance na transfer_unregistered ny karazana_fifanakalozana (tsy voatery); fixed na percentage ny karazany_sara. Ekena ny faingo na ny teboka sy faingo.';

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
  String get operatorsSubtitle =>
      'Ireo tabilaon\'ny sarany ampiasaina amin\'ny kajinao.';

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
    return 'Efa misy ny tabilao $name.';
  }

  @override
  String get deleteGridTitle => 'Hamafa ny tabilao';

  @override
  String deleteGridMessage(String name) {
    return 'Ho voafafa ny tabilao $name sy ny ambaratongany.';
  }

  @override
  String get optimizeWithGrid => 'Hanatsara amin\'ity tabilao ity';

  @override
  String get moreOptions => 'Safidy hafa';

  @override
  String get officialFees => 'Sarany ofisialy';

  @override
  String feesCheckedOn(String date) {
    return 'Nohamarinina tamin\'ny tranokalan\'ny mpandraharaha ny $date';
  }

  @override
  String get feesNeverChecked =>
      'Alaivo ny sarany farany navoakan\'ny mpandraharaha.';

  @override
  String sourceOfficial(String host) {
    return 'Tabilao ofisialy · $host';
  }

  @override
  String sourceOfficialDated(String host, String date) {
    return 'Tabilao ofisialy · $host · $date';
  }

  @override
  String get sourceManual =>
      'Tabilao nadika avy amin\'ny saran\'ny mpandraharaha';

  @override
  String sourceManualDated(String date) {
    return 'Tabilao nadika avy amin\'ny saran\'ny mpandraharaha · $date';
  }

  @override
  String get sourceEdited => 'Tabilao novainao';

  @override
  String get openSource => 'Hijery ny pejy ofisialy';

  @override
  String get editPublishedGridWarning =>
      'Avy amin\'ny saran\'ny mpandraharaha ity tabilao ity. Raha havaozinao ny sarany any aoriana, hosoloina ny fanovanao.';

  @override
  String get feesSection => 'Sarany';

  @override
  String get updateFeesTitle => 'Havaozina ny sarany';

  @override
  String get feesDownloadFailedTitle => 'Tsy nahomby ny fakana';

  @override
  String get updateReviewIntro =>
      'Namoaka sarany vaovao ireo mpandraharaha. Ireto ny miova:';

  @override
  String effectiveSince(String date) {
    return 'manan-kery hatramin\'ny $date';
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
  String get withdrawalCountHelp =>
      'Tsy voatery. Fetero ny isan\'ny fisintonana azo ampiasain\'ny drafitra.';

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
  String get planTitleWithdrawal => 'Ny drafitra fisintonanao';

  @override
  String get gainVsClassicWithdrawal =>
      'Raha ampitahaina amin\'ny fisintonana ny vola betsaka indrindra isaky ny misintona.';

  @override
  String get classicExplanationWithdrawal =>
      'Fomba mahazatra: sintonina ny vola betsaka indrindra azo atao, avy eo ny sisa.';

  @override
  String get amountWithdrawn => 'Vola sintonina';

  @override
  String get noTiersYet => 'Mbola tsy misy ambaratonga';

  @override
  String get intervalFormHelpWithdrawal =>
      'Ampiharina ny sarany rehefa eo anelanelan\'ny farafahakeliny sy ny farafahabetsany ny vola sintonina.';

  @override
  String versionLabel(String version) {
    return 'Dikan-teny $version';
  }

  @override
  String get free => 'Maimaim-poana';

  @override
  String get failedToLoadData => 'Tsy voaray ny angon-drakitra';

  @override
  String get failedToOpenLink => 'Tsy nety nisokatra ny rohy';

  @override
  String get pressAgainToExit => 'Tsindrio indray mba hivoaka';
}
