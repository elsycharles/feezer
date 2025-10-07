// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malagasy (`mg`).
class AppLocalizationsMg extends AppLocalizations {
  AppLocalizationsMg([String locale = 'mg']) : super(locale);

  @override
  String get appTitle => 'Feezer';

  @override
  String get onboardingTitle1 =>
      'Mihevitra mialoha ary mitahiry vola amin\'ny sara';

  @override
  String get onboardingDescription1 =>
      'Kajy ny fomba mahomby indrindra hitantanana ny volanao.';

  @override
  String get onboardingTitle2 => 'Atsikafo ny fifampiraharahanao';

  @override
  String get onboardingDescription2 =>
      'Ahena ho azy ny sara mifototra amin\'ny elanelana efa voafarit';

  @override
  String get onboardingTitle3 => 'Mitahiry am-pahendrena, mandany tsara kokoa';

  @override
  String get onboardingDescription3 =>
      'Mahazo soso-kevitra manokana ary manaova fanapahan-kevitra ara-bola tsara niaraka tamin\'izay.';

  @override
  String get next => 'Manaraka';

  @override
  String get skip => 'Dingana';

  @override
  String get getStarted => 'Hanomboka';

  @override
  String get back => 'Hiverina';

  @override
  String get cancel => 'Aoka ihany';

  @override
  String get save => 'Tahiry';

  @override
  String get delete => 'Fafao';

  @override
  String get edit => 'Ovay';

  @override
  String get create => 'Mamorona';

  @override
  String get confirm => 'Hamafy';

  @override
  String get optimizeFee => 'Hanatsara ny Sara';

  @override
  String get providers => 'Mpanome tolotra';

  @override
  String get settings => 'Fandrindrana';

  @override
  String get createInterval => 'Mamorona elanelana';

  @override
  String get optimize => 'Atsikafo';

  @override
  String get amount => 'Vola';

  @override
  String get provider => 'Mpanome tolotra';

  @override
  String get minTransactions => 'Fifampiraharahana faran\'izay kely';

  @override
  String get maxTransactions => 'Fifampiraharahana faran\'izay lehibe';

  @override
  String get pleaseEnterValidAmount => 'Ampidiro ny vola manan-kery azafady';

  @override
  String get pleaseSelectProvider => 'Fidio ny mpanome tolotra azafady';

  @override
  String get invalidTransactionRange =>
      'Ny fifampiraharahana kely dia tsy maintsy latsaky ny fifampiraharahana be';

  @override
  String get mvola => 'MVola';

  @override
  String get orangeMoney => 'Orange Money';

  @override
  String get airtelMoney => 'Airtel Money';

  @override
  String get mobileFinancialServices => 'Serivisy ara-bola finday';

  @override
  String get appearance => 'Fisehoana';

  @override
  String get theme => 'Loko';

  @override
  String get language => 'Fiteny';

  @override
  String get english => 'Anglisy';

  @override
  String get french => 'Frantsay';

  @override
  String get malagasy => 'Malagasy';

  @override
  String get system => 'Rafitra';

  @override
  String get light => 'Mazava';

  @override
  String get dark => 'Maizina';

  @override
  String get comingSoon => 'Ho Avy Tsy Ho Ela';

  @override
  String get thisFeatureWillBeAvailableSoon =>
      'Ho avy tsy ho ela io endri-javatra io!';

  @override
  String get feeIntervals => 'Elanelam-para';

  @override
  String get newFeeInterval => 'Elanelam-para vaovao';

  @override
  String get minAmount => 'Vola Kely';

  @override
  String get maxAmount => 'Vola Be';

  @override
  String get feePercentage => 'Isan-jaton\'ny Sara';

  @override
  String get fixedFee => 'Sara Raikitra';

  @override
  String get pleaseEnterMinAmount => 'Ampidiro ny vola kely azafady';

  @override
  String get pleaseEnterMaxAmount => 'Ampidiro ny vola be azafady';

  @override
  String get pleaseEnterValidFeePercentage =>
      'Ampidiro ny isan-jaton\'ny sara manan-kery azafady';

  @override
  String get maxAmountMustBeGreaterThanMinAmount =>
      'Ny vola be dia tsy maintsy mihoatra ny vola kely';

  @override
  String get optimizationResults => 'Valin\'ny fanatsiana';

  @override
  String get interval => 'Elanelana';

  @override
  String get fee => 'Sara';

  @override
  String get count => 'Isa';

  @override
  String get total => 'Totalin\'ny';

  @override
  String get noResultsYet => 'Mbola tsy misy valiny';

  @override
  String get tapOptimizeToSeeResults =>
      'Tsindrio ny \'Atsikafo\' hahitana ny valiny';

  @override
  String get error => 'Diso';

  @override
  String screenNotFound(String route) {
    return 'Tsy hita ny écran $route';
  }

  @override
  String get goHome => 'Hody';

  @override
  String get currency => 'Ar';

  @override
  String get demo => 'Demo';

  @override
  String get noProvidersFound => 'Tsy misy mpanome tolotra hita';

  @override
  String get searchProviders => 'Mitady mpanome tolotra...';

  @override
  String get manageYourProviders => 'Mitantana ny mpanome tolotra';

  @override
  String get centralizeProviders =>
      'Atambaro eo amin\'ny toerana iray ny mpiara-miasa banky sy mobile money.';

  @override
  String get activeProvider => 'Mpanome tolotra mavitrika';

  @override
  String get activeProviders => 'Mpanome tolotra mavitrika';

  @override
  String get deleteThisProvider => 'Hofafana ve ity mpanome tolotra ity?';

  @override
  String deleteProvidersCount(int count) {
    return 'Hofafana ve ny mpanome tolotra $count?';
  }

  @override
  String get deleteProvider => 'Mamafa mpanome tolotra';

  @override
  String get deleteProviders => 'Mamafa mpanome tolotra';

  @override
  String providerDeletedSuccessfully(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mpanome tolotra $count voafafa',
      one: 'Mpanome tolotra 1 voafafa',
    );
    return '$_temp0';
  }

  @override
  String get editProvider => 'Manova mpanome tolotra';

  @override
  String get providerName => 'Anaran\'ny mpanome tolotra';

  @override
  String get description => 'Famaritana';

  @override
  String get newProvider => 'Mpanome tolotra vaovao';

  @override
  String get createNewProvider => 'Mamorona mpanome tolotra vaovao';

  @override
  String get enterProviderName => 'Ampidiro ny anaran\'ny mpanome tolotra';

  @override
  String get providerCreatedSuccessfully => 'Mpanome tolotra voaforona';

  @override
  String get systemDefault => 'Tsy miova amin\'ny rafitra';

  @override
  String get general => 'Ankapobeny';

  @override
  String get about => 'Momba';

  @override
  String get version => 'Dikan-kevitra';

  @override
  String get faqAndContact => 'Fanontaniana sy fifandraisana';

  @override
  String get termsOfUse => 'Fepetra fampiasana';

  @override
  String get termsAndPrivacyPolicy =>
      'Fepetra sy politikan\'ny fiainana manokana';

  @override
  String get featureComingNextVersion =>
      'Endri-javatra ho avy amin\'ny dikan-kevitra manaraka';

  @override
  String get financialProvider => 'Mpanome tolotra ara-bola';

  @override
  String get chooseProviderToAnalyze =>
      'Safidio ny mpanome tolotra tianao hamakafaka';

  @override
  String get amountToOptimize => 'Vola hamatsiana';

  @override
  String get enterTransactionAmountToOptimize =>
      'Ampidiro ny volan\'ny fifampiraharahana tianao hamatsiana';

  @override
  String get transactionRange => 'Elanelam-pifampiraharahana';

  @override
  String get defineMinMaxTransactions =>
      'Farito ny isan\'ny fifampiraharahana faran\'izay kely sy lehibe';

  @override
  String get readyToOptimize => 'Vonona hamatsiana';

  @override
  String get clickOptimizeButtonToAnalyze =>
      'Tsindrio ny bokotra Hamatsiana mba hamakafaka ny firafitry ny sara tsara indrindra ho an\'ny fifampiraharahanao';

  @override
  String get providerDetails => 'Antsipirian\'ny mpanome tolotra';

  @override
  String get noFeeIntervalsFound => 'Tsy misy elanelam-para hita';

  @override
  String get feeInterval => 'Elanelam-para';

  @override
  String get searchByFeeRange => 'Mitady amin\'ny elanelam-para';

  @override
  String get addFeeInterval => 'Manampy elanelam-para';

  @override
  String get minFee => 'Sara faran\'izay kely';

  @override
  String get maxFee => 'Sara faran\'izay lehibe';

  @override
  String get deleteFeeIntervals => 'Mamafa elanelam-para';

  @override
  String get createNewFeeInterval => 'Mamorona elanelam-para vaovao';

  @override
  String get defineNewFeeStructure =>
      'Mamaritra firafitra sara vaovao ho an\'ny volan\'ny fifampiraharahana';

  @override
  String get enterMinimumAmount => 'Ampidiro ny vola faran\'izay kely';

  @override
  String get enterMaximumAmount => 'Ampidiro ny vola faran\'izay lehibe';

  @override
  String get enterFeeAmount => 'Ampidiro ny volan\'ny sara';

  @override
  String get maxAmountMustBeGreater =>
      'Ny vola lehibe dia tsy maintsy mihoatra ny vola kely';

  @override
  String get feeIntervalCreatedSuccessfully => 'Elanelam-para voaforona';

  @override
  String get addNewFinancialServiceProvider =>
      'Manampy mpanome serivisy ara-bola vaovao amin\'ny lisitrao';

  @override
  String get enterDescription => 'Ampidiro ny famaritana';

  @override
  String get createProvider => 'Mamorona mpanome tolotra';

  @override
  String get clearSelection => 'Mamafa ny fifantenana';

  @override
  String get selectAll => 'Fidio daholo';

  @override
  String get icon => 'Sary';

  @override
  String get tapToSelectIcon => 'Tsindrio mba hisafidy sary';

  @override
  String get clearSearch => 'Mamafa ny fikarohana';

  @override
  String get selectIcon => 'Misafidy sary';

  @override
  String get thisFieldIsRequired => 'Ilaina ity saha ity';

  @override
  String get pressAgainToExit => 'Tsindrio indray mba hivoaka';

  @override
  String get providerUpdatedSuccessfully =>
      'Mpamatsy nohavaozina soa aman-tsara';

  @override
  String get feeIntervalUpdatedSuccessfully =>
      'Elanelana sara nohavaozina soa aman-tsara';

  @override
  String feeIntervalDeletedSuccessfully(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Elanelana sara $countString voafafa soa aman-tsara',
      one: 'Elanelana sara 1 voafafa soa aman-tsara',
    );
    return '$_temp0';
  }

  @override
  String get minimumAmount => 'Vola faran\'izay kely';

  @override
  String get maximumAmount => 'Vola faran\'izay lehibe';

  @override
  String get feeAmount => 'Volan\'ny sara';

  @override
  String get traditionalBanking => 'Banky nentim-paharazana';

  @override
  String get mobileMoney => 'Vola finday';

  @override
  String get selected => 'voafidy';

  @override
  String get feeOptimizer => 'Mpampandroso sara';

  @override
  String get totalFeeIntervals => 'Totaly ny elan-toeran\'ny sara';

  @override
  String get helpAndSupport => 'Fanampiana sy fanohanana';

  @override
  String get addNewProvider => 'Hanampy mpanome tolotra vaovao';

  @override
  String get tryAdjustingYourSearchRange =>
      'Andramo ny fanovana ny sahan-tsikarananao';

  @override
  String get chooseTheme => 'Misafidy endrika';

  @override
  String get alwaysUseLightTheme => 'Mampiasa endrika mazava foana';

  @override
  String get alwaysUseDarkTheme => 'Mampiasa endrika maizina foana';

  @override
  String get followSystemSettings => 'Manaraka ny firafitry ny rafitra';

  @override
  String get saveChanges => 'Tehirizo ny fanovana';

  @override
  String get minimumAmountAr => 'Vola faran\'ny kely (Ar)';

  @override
  String get maximumAmountAr => 'Vola faran\'ny be (Ar)';

  @override
  String get feeAr => 'Sara (Ar)';

  @override
  String confirmDeleteIntervals(int count) {
    return 'Tena te-hamafa ny elan-toera $count voafidy ve ianao?';
  }
}
