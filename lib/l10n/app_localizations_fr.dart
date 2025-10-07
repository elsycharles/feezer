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
  String get createInterval => 'Créer un Intervalle';

  @override
  String get optimize => 'Optimiser';

  @override
  String get amount => 'Montant';

  @override
  String get provider => 'Fournisseur';

  @override
  String get minTransactions => 'Transactions Min';

  @override
  String get maxTransactions => 'Transactions Max';

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
  String get feeIntervals => 'Intervalles de Frais';

  @override
  String get newFeeInterval => 'Nouvel Intervalle de Frais';

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
      'Le montant max doit être supérieur au montant min';

  @override
  String get optimizationResults => 'Résultats d\'Optimisation';

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
  String get currency => 'Ar';

  @override
  String get demo => 'Démo';

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
}
