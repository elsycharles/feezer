// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Feezer';

  @override
  String get onboardingTitle1 => 'Planifiez et économisez sur les frais';

  @override
  String get onboardingDescription1 =>
      'Calculez le moyen le plus rentable de gérer votre argent.';

  @override
  String get onboardingTitle2 => 'Optimisez vos transactions';

  @override
  String get onboardingDescription2 =>
      'Minimisez automatiquement les frais basés sur des intervalles prédéfinis.';

  @override
  String get onboardingTitle3 => 'Économisez intelligemment, dépensez mieux';

  @override
  String get onboardingDescription3 =>
      'Obtenez des recommandations personnalisées et prenez des décisions financières éclairées instantanément.';

  @override
  String get next => 'Suivant';

  @override
  String get skip => 'Ignorer';

  @override
  String get getStarted => 'Commencer';

  @override
  String get back => 'Retour';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get create => 'Créer';

  @override
  String get confirm => 'Confirmer';

  @override
  String get optimizeFee => 'Optimiser les Frais';

  @override
  String get providers => 'Fournisseurs';

  @override
  String get settings => 'Paramètres';

  @override
  String get createInterval => 'Créer l\'intervalle';

  @override
  String get optimize => 'Optimiser';

  @override
  String get amount => 'Montant';

  @override
  String get provider => 'Fournisseur';

  @override
  String get minTransactions => 'Transactions min';

  @override
  String get maxTransactions => 'Transactions max';

  @override
  String get pleaseEnterValidAmount => 'Veuillez saisir un montant valide';

  @override
  String get pleaseSelectProvider => 'Veuillez sélectionner un fournisseur';

  @override
  String get invalidTransactionRange =>
      'Les transactions min doivent être inférieures aux transactions max';

  @override
  String get mvola => 'MVola';

  @override
  String get orangeMoney => 'Orange Money';

  @override
  String get airtelMoney => 'Airtel Money';

  @override
  String get mobileFinancialServices => 'Services financiers mobiles';

  @override
  String get appearance => 'Apparence';

  @override
  String get theme => 'Thème';

  @override
  String get language => 'Langue';

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Français';

  @override
  String get malagasy => 'Malgache';

  @override
  String get system => 'Système';

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String get comingSoon => 'Bientôt Disponible';

  @override
  String get thisFeatureWillBeAvailableSoon =>
      'Cette fonctionnalité sera bientôt disponible !';

  @override
  String get feeIntervals => 'Intervalles de frais';

  @override
  String get newFeeInterval => 'Nouvel intervalle de frais';

  @override
  String get minAmount => 'Montant Min';

  @override
  String get maxAmount => 'Montant Max';

  @override
  String get feePercentage => 'Pourcentage de Frais';

  @override
  String get fixedFee => 'Frais Fixes';

  @override
  String get pleaseEnterMinAmount => 'Veuillez saisir le montant minimum';

  @override
  String get pleaseEnterMaxAmount => 'Veuillez saisir le montant maximum';

  @override
  String get pleaseEnterValidFeePercentage =>
      'Veuillez saisir un pourcentage de frais valide';

  @override
  String get maxAmountMustBeGreaterThanMinAmount =>
      'Le montant maximum doit être supérieur au montant minimum';

  @override
  String get optimizationResults => 'Résultats d\'optimisation';

  @override
  String get interval => 'Intervalle';

  @override
  String get fee => 'Frais';

  @override
  String get count => 'Nombre';

  @override
  String get total => 'Total';

  @override
  String get noResultsYet => 'Aucun résultat pour l\'instant';

  @override
  String get tapOptimizeToSeeResults =>
      'Appuyez sur \'Optimiser\' pour voir les résultats';

  @override
  String get error => 'Erreur';

  @override
  String screenNotFound(String route) {
    return 'Écran $route introuvable';
  }

  @override
  String get goHome => 'Accueil';

  @override
  String get noProvidersFound => 'Aucun fournisseur trouvé';

  @override
  String get searchProviders => 'Rechercher des fournisseurs...';

  @override
  String get manageYourProviders => 'Gérer vos fournisseurs';

  @override
  String get centralizeProviders =>
      'Centralisez les partenaires bancaires et de mobile money en un seul endroit.';

  @override
  String get activeProvider => 'Fournisseur actif';

  @override
  String get activeProviders => 'Fournisseurs actifs';

  @override
  String get deleteThisProvider => 'Supprimer ce fournisseur ?';

  @override
  String deleteProvidersCount(int count) {
    return 'Supprimer $count fournisseurs ?';
  }

  @override
  String get deleteProvider => 'Supprimer le fournisseur';

  @override
  String get deleteProviders => 'Supprimer les fournisseurs';

  @override
  String providerDeletedSuccessfully(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fournisseurs supprimés avec succès',
      one: '1 fournisseur supprimé avec succès',
    );
    return '$_temp0';
  }

  @override
  String get editProvider => 'Modifier le fournisseur';

  @override
  String get providerName => 'Nom du fournisseur';

  @override
  String get description => 'Description';

  @override
  String get newProvider => 'Nouveau fournisseur';

  @override
  String get createNewProvider => 'Créer un nouveau fournisseur';

  @override
  String get enterProviderName => 'Saisissez le nom du fournisseur';

  @override
  String get providerCreatedSuccessfully => 'Fournisseur créé avec succès';

  @override
  String get systemDefault => 'Par défaut du système';

  @override
  String get general => 'Général';

  @override
  String get about => 'À propos';

  @override
  String get version => 'Version';

  @override
  String get faqAndContact => 'FAQ et contact';

  @override
  String get termsOfUse => 'Conditions d\'utilisation';

  @override
  String get termsAndPrivacyPolicy =>
      'Conditions et politique de confidentialité';

  @override
  String get featureComingNextVersion =>
      'Fonctionnalité disponible dans la prochaine version';

  @override
  String get financialProvider => 'Fournisseur financier';

  @override
  String get chooseProviderToAnalyze =>
      'Choisissez le fournisseur que vous souhaitez analyser';

  @override
  String get amountToOptimize => 'Montant à optimiser';

  @override
  String get enterTransactionAmountToOptimize =>
      'Saisissez le montant de transaction que vous souhaitez optimiser';

  @override
  String get transactionRange => 'Plage de transactions';

  @override
  String get defineMinMaxTransactions =>
      'Définissez le nombre minimum et maximum de transactions';

  @override
  String get readyToOptimize => 'Prêt à optimiser';

  @override
  String get clickOptimizeButtonToAnalyze =>
      'Cliquez sur le bouton Optimiser pour analyser la meilleure structure de frais pour vos transactions';

  @override
  String get providerDetails => 'Détails du fournisseur';

  @override
  String get noFeeIntervalsFound => 'Aucun intervalle de frais trouvé';

  @override
  String get feeInterval => 'Intervalle de frais';

  @override
  String get searchByFeeRange => 'Rechercher par plage de frais';

  @override
  String get addFeeInterval => 'Ajouter un intervalle de frais';

  @override
  String get minFee => 'Frais min';

  @override
  String get maxFee => 'Frais max';

  @override
  String get deleteFeeIntervals => 'Supprimer les intervalles de frais';

  @override
  String get createNewFeeInterval => 'Créer un nouvel intervalle de frais';

  @override
  String get defineNewFeeStructure =>
      'Définir une nouvelle structure de frais pour les montants de transaction';

  @override
  String get enterMinimumAmount => 'Saisissez le montant minimum';

  @override
  String get enterMaximumAmount => 'Saisissez le montant maximum';

  @override
  String get enterFeeAmount => 'Saisissez le montant des frais';

  @override
  String get maxAmountMustBeGreater =>
      'Le montant max doit être supérieur au montant min';

  @override
  String get feeIntervalCreatedSuccessfully =>
      'Intervalle de frais créé avec succès';

  @override
  String get addNewFinancialServiceProvider =>
      'Ajouter un nouveau fournisseur de services financiers à votre liste';

  @override
  String get enterDescription => 'Saisissez la description';

  @override
  String get createProvider => 'Créer le fournisseur';

  @override
  String get clearSelection => 'Effacer la sélection';

  @override
  String get selectAll => 'Tout sélectionner';

  @override
  String get icon => 'Icône';

  @override
  String get tapToSelectIcon => 'Appuyez pour sélectionner l\'icône';

  @override
  String get clearSearch => 'Effacer la recherche';

  @override
  String get selectIcon => 'Sélectionner l\'icône';

  @override
  String get thisFieldIsRequired => 'Ce champ est obligatoire';

  @override
  String get pressAgainToExit => 'Appuyez à nouveau pour quitter';

  @override
  String get providerUpdatedSuccessfully =>
      'Fournisseur mis à jour avec succès';

  @override
  String get feeIntervalUpdatedSuccessfully =>
      'Intervalle de frais mis à jour avec succès';

  @override
  String feeIntervalDeletedSuccessfully(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString intervalles de frais supprimés avec succès',
      one: '1 intervalle de frais supprimé avec succès',
    );
    return '$_temp0';
  }

  @override
  String get editFeeInterval => 'Modifier l\'intervalle de frais';

  @override
  String get minTransactionsCannotBeGreaterThanMax =>
      'Le minimum de transactions ne peut pas être supérieur au maximum';

  @override
  String get pleaseEnterValidFee => 'Veuillez saisir des frais valides';

  @override
  String mustBeAtLeastNCharacters(int count) {
    return 'Doit contenir au moins $count caractères';
  }

  @override
  String get enterValidNumber => 'Saisissez un nombre valide';

  @override
  String get pleaseEnterFeeAmount => 'Veuillez saisir le montant des frais';

  @override
  String get details => 'Détails';

  @override
  String get minimumAmount => 'Montant minimum';

  @override
  String get maximumAmount => 'Montant maximum';

  @override
  String get feeAmount => 'Montant des frais';

  @override
  String get traditionalBanking => 'Banque traditionnelle';

  @override
  String get mobileMoney => 'Mobile money';

  @override
  String get selected => 'sélectionnés';

  @override
  String get feeOptimizer => 'Optimiseur de frais';

  @override
  String get totalFeeIntervals => 'Total des intervalles de frais';

  @override
  String get helpAndSupport => 'Aide et support';

  @override
  String get addNewProvider => 'Ajouter un nouveau fournisseur';

  @override
  String get tryAdjustingYourSearchRange =>
      'Essayez d\'ajuster votre plage de recherche';

  @override
  String get chooseTheme => 'Choisir le thème';

  @override
  String get alwaysUseLightTheme => 'Toujours utiliser le thème clair';

  @override
  String get alwaysUseDarkTheme => 'Toujours utiliser le thème sombre';

  @override
  String get followSystemSettings => 'Suivre les paramètres système';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get minimumAmountAr => 'Montant minimum (Ar)';

  @override
  String get maximumAmountAr => 'Montant maximum (Ar)';

  @override
  String get feeAr => 'Frais (Ar)';

  @override
  String confirmDeleteIntervals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return 'Êtes-vous sûr de vouloir supprimer $count intervalle$_temp0 sélectionné$_temp1 ?';
  }

  @override
  String fieldIsRequired(String fieldName) {
    return '$fieldName est requis';
  }

  @override
  String get mustBeGreaterThanZero => 'Doit être supérieur à 0';

  @override
  String mustBeLessThanNCharacters(int count) {
    return 'Doit contenir moins de $count caractères';
  }
}
