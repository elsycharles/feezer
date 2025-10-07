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
      'Ahena ho azy ny sara mifototra amin\'ny elanelana efa voafaritra.';

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
  String get createInterval => 'Mamorona Elanelana';

  @override
  String get optimize => 'Atsikafo';

  @override
  String get amount => 'Vola';

  @override
  String get provider => 'Mpanome tolotra';

  @override
  String get minTransactions => 'Fifampiraharahana Kely';

  @override
  String get maxTransactions => 'Fifampiraharahana Be';

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
  String get feeIntervals => 'Elanelana Sara';

  @override
  String get newFeeInterval => 'Elanelana Sara Vaovao';

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
  String get optimizationResults => 'Valin\'ny Fanatsarana';

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
}
