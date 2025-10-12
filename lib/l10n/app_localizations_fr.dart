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
  String get onboardingTitle1 =>
      'Arrêtez de perdre de l\'argent avec les frais bancaires';

  @override
  String get onboardingDescription1 =>
      'Les frais bancaires peuvent s\'accumuler rapidement. Feezer vous aide à minimiser les coûts sur chaque transaction.';

  @override
  String get onboardingTitle2 => 'Optimisation intelligente des transactions';

  @override
  String get onboardingDescription2 =>
      'Calculez automatiquement le moyen le plus rentable de gérer vos virements et paiements.';

  @override
  String get onboardingTitle3 => 'Économisez plus, gardez plus';

  @override
  String get onboardingDescription3 =>
      'Obtenez des stratégies d\'optimisation des frais personnalisées et regardez vos économies croître à chaque transaction.';

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
  String get transactionDetails => 'Détails de Transaction';

  @override
  String get currencySymbol => 'Ar';

  @override
  String get totalAmount => 'Montant Total';

  @override
  String get netAmount => 'Montant Net';

  @override
  String get totalFees => 'Frais Totaux';

  @override
  String get efficiency => 'Efficacité';

  @override
  String get operations => 'Opérations';

  @override
  String get remaining => 'Restant';

  @override
  String get noOptimizationResultsFound =>
      'Aucun résultat d\'optimisation trouvé. Veuillez vérifier vos paramètres d\'entrée.';

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
  String get deleteProviderWarning =>
      'Cela supprimera également tous les intervalles de frais associés.';

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
  String get termsIntroductionTitle => 'Introduction';

  @override
  String get termsIntroductionContent =>
      'Bienvenue sur Feezer ! Ces Conditions d\'utilisation régissent votre utilisation de notre application mobile conçue pour vous aider à minimiser les frais bancaires. En utilisant Feezer, vous acceptez d\'être lié par ces conditions. Veuillez les lire attentivement avant d\'utiliser notre service.';

  @override
  String get termsAcceptanceTitle => 'Acceptation des Conditions';

  @override
  String get termsAcceptanceContent =>
      'En accédant et utilisant Feezer, vous acceptez et vous engagez à respecter les termes et dispositions de cet accord. Si vous n\'acceptez pas de vous conformer aux conditions ci-dessus, veuillez ne pas utiliser ce service.';

  @override
  String get termsResponsibilitiesTitle => 'Responsabilités de l\'Utilisateur';

  @override
  String get termsResponsibilitiesContent =>
      'Vous êtes responsable du maintien de la confidentialité des informations de votre compte et de toutes les activités qui se déroulent sous votre compte. Vous acceptez de fournir des informations exactes et complètes lors de l\'utilisation de notre service et de mettre à jour ces informations si nécessaire.';

  @override
  String get termsServiceTitle => 'Description du Service';

  @override
  String get termsServiceContent =>
      'Feezer est un outil de minimisation des frais qui vous aide à calculer et optimiser les coûts des transactions bancaires. Notre service fournit des calculs de frais, des suggestions d\'optimisation des transactions et du contenu éducatif sur les frais bancaires. Nous nous efforçons de fournir des informations exactes, mais tous les calculs sont des estimations et doivent être vérifiés auprès de vos établissements financiers.';

  @override
  String get termsPrivacyTitle => 'Confidentialité et Protection des Données';

  @override
  String get termsPrivacyContent =>
      'Votre confidentialité est importante pour nous. Feezer collecte un minimum d\'informations personnelles nécessaires pour fournir notre service. Nous ne vendons, n\'échangeons ni ne transférons vos informations personnelles à des tiers sans votre consentement, sauf comme décrit dans notre Politique de Confidentialité. Nous mettons en œuvre des mesures de sécurité appropriées pour protéger vos données.';

  @override
  String get termsLiabilityTitle => 'Limitation de Responsabilité';

  @override
  String get termsLiabilityContent =>
      'Feezer fournit des services de calcul de frais à des fins d\'information uniquement. Nous ne sommes pas responsables des pertes financières, dommages ou décisions prises sur la base des informations fournies par notre application. Les utilisateurs doivent toujours vérifier les calculs auprès de leurs établissements financiers et consulter des conseillers financiers pour les décisions financières importantes.';

  @override
  String get termsTerminationTitle => 'Résiliation';

  @override
  String get termsTerminationContent =>
      'Nous nous réservons le droit de résilier ou suspendre votre compte et l\'accès à notre service à notre seule discrétion, sans préavis, pour un comportement que nous croyons violer ces Conditions d\'utilisation ou nuisible aux autres utilisateurs, à nous ou à des tiers, ou pour toute autre raison.';

  @override
  String get termsGoverningLawTitle => 'Loi Applicable';

  @override
  String get termsGoverningLawContent =>
      'Ces Conditions d\'utilisation sont régies et interprétées conformément aux lois de la juridiction dans laquelle notre service opère. Tout différend découlant de ces conditions sera résolu par arbitrage obligatoire conformément aux règles de l\'association d\'arbitrage appropriée.';

  @override
  String get termsContactTitle => 'Informations de Contact';

  @override
  String get termsContactContent =>
      'Si vous avez des questions concernant ces Conditions d\'utilisation, veuillez nous contacter via la section support de l\'application ou par email à elsy.s.charles@gmail.com. Nous répondrons à vos demandes aussi rapidement que possible.';

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

  @override
  String get deleteCurrencies => 'Supprimer les devises';

  @override
  String get currencyDeletedSuccessfully => 'Devise supprimée avec succès';

  @override
  String get currencies => 'Devises';

  @override
  String get searchCurrencies => 'Rechercher des devises...';

  @override
  String get noCurrenciesFound => 'Aucune devise trouvée';

  @override
  String get centralizeCurrencies =>
      'Centralisez vos devises en un seul endroit';

  @override
  String get addNewCurrency => 'Ajouter une nouvelle devise';

  @override
  String get newCurrency => 'Nouvelle devise';

  @override
  String get createNewCurrency => 'Créer une nouvelle devise';

  @override
  String get currencyCode => 'Code de la devise';

  @override
  String get currencyName => 'Nom de la devise';

  @override
  String get currencySymbolLabel => 'Symbole de la devise';

  @override
  String get exchangeRate => 'Taux de change';

  @override
  String get currencyCreatedSuccessfully => 'Devise créée avec succès';

  @override
  String get manageYourCurrencies => 'Gérez vos devises';

  @override
  String get totalCurrencies => 'Total des devises';

  @override
  String get activeCurrencies => 'Devises actives';

  @override
  String get editCurrency => 'Modifier la devise';

  @override
  String get currencyUpdatedSuccessfully => 'Devise mise à jour avec succès';

  @override
  String get addNewCurrencyDescription =>
      'Ajoutez une nouvelle devise à votre collection';

  @override
  String get currencyCodeMustBe3Characters =>
      'Le code de devise doit contenir exactement 3 caractères';

  @override
  String get currencyCodeMustContainOnlyUppercase =>
      'Le code de devise ne doit contenir que des lettres majuscules';

  @override
  String get pleaseEnterValidPositiveRate =>
      'Veuillez saisir un taux positif valide';

  @override
  String get failedToCreateCurrency => 'Échec de la création de la devise';

  @override
  String get failedToUpdateCurrency => 'Échec de la mise à jour de la devise';

  @override
  String get codeMustBe3Characters => 'Le code doit contenir 3 caractères';

  @override
  String get invalidRate => 'Taux invalide';

  @override
  String get rateLabel => 'Taux :';

  @override
  String confirmDeleteCurrencies(int count) {
    return 'Êtes-vous sûr de vouloir supprimer $count devises ?';
  }

  @override
  String operationCount(int count) {
    return '$count opérations';
  }

  @override
  String get optimizationFailedNoValidSolution =>
      'Optimisation échouée : Aucune solution valide trouvée';

  @override
  String optimizationIncomplete(String percentage) {
    return 'Optimisation incomplète : Seulement $percentage% du montant couvert. Envisagez d\'ajuster les limites de transaction ou les intervalles de frais.';
  }

  @override
  String amountExceedsMaximumLimit(String amount, String currency) {
    return 'Le montant dépasse la limite maximale ($amount $currency)';
  }

  @override
  String get failedToCalculateOptimization =>
      'Échec du calcul de l\'optimisation';

  @override
  String get amountExceedsMaximumAllowedLimit =>
      'Le montant dépasse la limite maximale autorisée';

  @override
  String get invalidTransactionRangeConstraints =>
      'Contraintes de plage de transaction invalides';

  @override
  String get noValidFeeIntervalsAvailable =>
      'Aucun intervalle de frais valide disponible';

  @override
  String get amountMustBePositive => 'Le montant doit être positif';

  @override
  String get amountTooHigh => 'Montant trop élevé';

  @override
  String get noOptionsAvailable => 'Aucune option disponible';

  @override
  String get maxOperationsMustBePositive => 'maxOperations doit être >= 0';

  @override
  String get minOperationsMustBePositive => 'minOperations doit être >= 0';

  @override
  String get minOperationsCannotBeGreaterThanMaxOperations =>
      'minOperations ne peut pas être supérieur à maxOperations';

  @override
  String get importExportData => 'Import/Export de données';

  @override
  String get csvImportExportInfo => 'Gestion des données CSV';

  @override
  String get csvImportExportDescription =>
      'Importez ou exportez vos fournisseurs et intervalles de frais via des fichiers CSV';

  @override
  String get importData => 'Importer des données';

  @override
  String get exportData => 'Exporter des données';

  @override
  String get templates => 'Modèles CSV';

  @override
  String get exportCombined => 'Exporter combiné';

  @override
  String get exportCombinedDescription =>
      'Exporter les fournisseurs avec leurs intervalles de frais';

  @override
  String get downloadProviderTemplate => 'Modèle fournisseurs';

  @override
  String get csvTemplateForProviders =>
      'Télécharger le modèle CSV pour importer des fournisseurs';

  @override
  String get downloadFeeTemplate => 'Modèle intervalles de frais';

  @override
  String get csvTemplateForFees =>
      'Télécharger le modèle CSV pour importer des frais';

  @override
  String get downloadCombinedTemplate => 'Modèle combiné';

  @override
  String get csvTemplateForCombined =>
      'Télécharger le modèle CSV pour l\'import combiné';

  @override
  String get importSuccessful => 'Import réussi';

  @override
  String importFailed(String error) {
    return 'Échec de l\'importation : $error';
  }

  @override
  String get exportSuccessful => 'Exportation réussie';

  @override
  String exportFailed(String error) {
    return 'Échec de l\'exportation : $error';
  }

  @override
  String get templateDownloaded => 'Modèle téléchargé';

  @override
  String get failedToDownloadTemplate => 'Échec du téléchargement du modèle';

  @override
  String get failedToReadFile => 'Impossible de lire le fichier';

  @override
  String providersImported(int count) {
    return '$count fournisseur(s) importé(s)';
  }

  @override
  String feeIntervalsImported(int count) {
    return '$count intervalle(s) de frais importé(s)';
  }

  @override
  String errorsEncountered(int count) {
    return '$count erreur(s) rencontrée(s)';
  }

  @override
  String get dataManagement => 'Gestion des données';

  @override
  String get backup => 'Sauvegarde';

  @override
  String get backupYourData => 'Sauvegarder vos fournisseurs et frais';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get clearAllData => 'Effacer toutes les données';

  @override
  String get confirmReset => 'Confirmer la réinitialisation';

  @override
  String get resetWarningMessage =>
      'Ceci supprimera définitivement tous vos fournisseurs et intervalles de frais. Cette action est irréversible.';

  @override
  String get dataResetSuccessful => 'Données réinitialisées avec succès';

  @override
  String get resetFailed => 'Échec de la réinitialisation';

  @override
  String get csvManagement => 'Gestion CSV';

  @override
  String get previewTemplate => 'Aperçu du modèle';

  @override
  String get preview => 'Aperçu';

  @override
  String get download => 'Télécharger';

  @override
  String get templatePreview => 'Aperçu du modèle';

  @override
  String get close => 'Fermer';

  @override
  String get importDataDescription =>
      'Importer des fournisseurs et intervalles de frais depuis un fichier CSV. Le système détectera automatiquement le type de données selon les colonnes.';

  @override
  String get exportDataDescription =>
      'Exporter tous les fournisseurs et leurs intervalles de frais vers un fichier CSV combiné.';

  @override
  String get csvContentCannotBeEmpty => 'Le contenu CSV ne peut pas être vide';

  @override
  String get clickImportToSelectFile =>
      'Cliquez pour séléctionner un fichier csv';

  @override
  String get copy => 'Copier';

  @override
  String get copiedToClipboard => 'Copié dans le presse-papiers';

  @override
  String get chooseWhereToSave => 'Choisir où enregistrer le fichier';

  @override
  String get fileSavedSuccessfully => 'Fichier enregistré avec succès';

  @override
  String get failedToSaveFile => 'Échec de l\'enregistrement du fichier';

  @override
  String get file => 'Fichier';

  @override
  String get text => 'Texte';

  @override
  String get pasteCsvContentHere => 'Collez votre contenu CSV ici...';

  @override
  String get fileSelected => 'Fichier sélectionné';

  @override
  String get csvFilesOnly => 'Fichiers CSV uniquement';

  @override
  String get csvContentPreview => 'Aperçu du contenu CSV :';

  @override
  String get failedToSelectFile => 'Échec de la sélection du fichier';

  @override
  String get failedToPreviewTemplate => 'Échec de l\'aperçu du modèle';

  @override
  String get csvFileIsEmpty => 'Le fichier CSV est vide';

  @override
  String get noDataRowsFound => 'Aucune ligne de données trouvée';

  @override
  String rowProviderNameRequired(int rowNumber) {
    return 'Ligne $rowNumber : Le nom du fournisseur est requis';
  }

  @override
  String rowProviderAlreadyExists(int rowNumber, String name) {
    return 'Ligne $rowNumber : Le fournisseur \"$name\" existe déjà';
  }

  @override
  String rowGenericError(int rowNumber, String error) {
    return 'Ligne $rowNumber : $error';
  }

  @override
  String rowProviderNameRequiredFee(int rowNumber) {
    return 'Ligne $rowNumber : Le nom du fournisseur est requis';
  }

  @override
  String rowProviderNotFound(int rowNumber, String providerName) {
    return 'Ligne $rowNumber : Fournisseur \"$providerName\" introuvable';
  }

  @override
  String rowIntervalOverlaps(int rowNumber, String overlap) {
    return 'Ligne $rowNumber : L\'intervalle chevauche un intervalle existant ($overlap)';
  }

  @override
  String rowInvalidAmounts(
    int rowNumber,
    String minStr,
    String maxStr,
    String feeStr,
  ) {
    return 'Ligne $rowNumber : Montants invalides (min : $minStr, max : $maxStr, frais : $feeStr)';
  }

  @override
  String rowMinAmountGreaterThanMax(int rowNumber, String min, String max) {
    return 'Ligne $rowNumber : Le montant min ($min) doit être inférieur au montant max ($max)';
  }

  @override
  String rowFeeMustBePositive(int rowNumber) {
    return 'Ligne $rowNumber : Les frais doivent être positifs';
  }

  @override
  String importedProvidersAndFees(int providersCount, int feesCount) {
    return '$providersCount fournisseur(s) et $feesCount intervalle(s) de frais importé(s)';
  }

  @override
  String providerInvalidProviderId(String providerName) {
    return 'Fournisseur \"$providerName\" : ID de fournisseur invalide';
  }

  @override
  String providerNoFeeIntervals(String providerName) {
    return 'Fournisseur \"$providerName\" : Aucun intervalle de frais trouvé';
  }

  @override
  String providerImportError(String providerName, String error) {
    return 'Fournisseur \"$providerName\" : $error';
  }

  @override
  String rowIntervalOverlapsCombined(int rowNumber, String overlap) {
    return 'Ligne $rowNumber : L\'intervalle chevauche un intervalle existant ($overlap)';
  }

  @override
  String get noDataToExport => 'Aucune donnée à exporter';

  @override
  String get providerNameColumnNotFound =>
      'Colonne du nom du fournisseur introuvable';

  @override
  String get pullToRefresh => 'Tirez vers le bas pour actualiser';

  @override
  String get refreshing => 'Actualisation...';

  @override
  String get feeType => 'Type de frais';

  @override
  String get fixedAmount => 'Montant fixe';

  @override
  String get percentage => 'Pourcentage';

  @override
  String get enterPercentage => 'Entrez le pourcentage';

  @override
  String get percentageMustBeBetween0And100 =>
      'Le pourcentage doit être entre 0 et 100';

  @override
  String get invalidAmount => 'Montant invalide';

  @override
  String get pleaseEnterPercentage => 'Veuillez entrer le pourcentage';

  @override
  String get pleaseEnterValidPercentage =>
      'Veuillez entrer un pourcentage valide';

  @override
  String get percentageCannotExceed100 =>
      'Le pourcentage ne peut pas dépasser 100';

  @override
  String get searchHelpTopics => 'Rechercher des sujets d\'aide...';

  @override
  String get faq => 'FAQ';

  @override
  String get contact => 'Contact';

  @override
  String get faqWhatIsFeeMinimizer =>
      'Qu\'est-ce que Feezer ou Fee Minimizer ?';

  @override
  String get faqWhatIsFeeMinimizerAnswer =>
      'Feezer ou Fee Minimizer est une application mobile qui aide les utilisateurs à calculer et optimiser les frais de transaction auprès de différents fournisseurs financiers. Elle analyse vos détails de transaction et suggère les options les plus rentables pour minimiser les frais bancaires.';

  @override
  String get faqHowToAddProvider => 'Comment ajouter un nouveau fournisseur ?';

  @override
  String get faqHowToAddProviderAnswer =>
      'Pour ajouter un nouveau fournisseur, allez à l\'écran Fournisseurs et appuyez sur le bouton \'+\'. Remplissez les détails du fournisseur incluant le nom, la description et la structure des frais. Vous pouvez également importer des données de fournisseur en utilisant des fichiers CSV. Il n\'y a pas de fournisseurs favoris - vous avez un contrôle total pour ajouter et supprimer des fournisseurs selon vos besoins.';

  @override
  String get faqHowToCalculateFees =>
      'Comment fonctionne le calcul des frais ?';

  @override
  String get faqHowToCalculateFeesAnswer =>
      'Entrez le montant de votre transaction et sélectionnez un fournisseur. L\'application calculera tous les frais applicables incluant les frais fixes, les frais en pourcentage et les frais minimum/maximum. Elle vous montre ensuite le coût total et suggère des optimisations.';

  @override
  String get faqDataSecurity => 'Mes données sont-elles sécurisées ?';

  @override
  String get faqDataSecurityAnswer =>
      'Vos données financières sont stockées localement sur votre appareil sans cryptage ni mesures de sécurité supplémentaires. Cette application ne fournit pas de fonctionnalités de sécurité de niveau bancaire. Toutes les données restent sur votre appareil et ne sont transmises nulle part.';

  @override
  String get faqOfflineMode => 'L\'application fonctionne-t-elle hors ligne ?';

  @override
  String get faqOfflineModeAnswer =>
      'Oui, Feezer ou Fee Minimizer fonctionne complètement hors ligne. Toutes vos données et calculs sont stockés localement sur votre appareil. Vous pouvez utiliser toutes les fonctionnalités sans connexion internet.';

  @override
  String get faqCurrencyRates => 'Comment fonctionnent les taux de change ?';

  @override
  String get faqCurrencyRatesAnswer =>
      'L\'application ne met pas à jour automatiquement les taux de change des devises. Vous avez un contrôle total et pouvez définir manuellement vos propres taux de change pour une personnalisation complète. Cela vous donne une flexibilité totale pour utiliser les taux qui conviennent à vos besoins, et fonctionne parfaitement hors ligne.';

  @override
  String get faqExportData => 'Comment exporter mes données ?';

  @override
  String get faqExportDataAnswer =>
      'Allez dans Paramètres > Gestion des données > Gestion CSV. Vous pouvez exporter les fournisseurs, devises et intervalles de frais sous forme de fichiers CSV. Ceux-ci peuvent être utilisés pour la sauvegarde ou l\'importation dans d\'autres instances de l\'application.';

  @override
  String get emailSupport => 'Support par email';

  @override
  String get phoneSupport => 'Support téléphonique';

  @override
  String get website => 'Site web';

  @override
  String get responseTime => 'Temps de réponse';

  @override
  String get responseTimeDescription =>
      'Nous répondons généralement aux demandes de support dans les 24 heures pendant les jours ouvrables.';

  @override
  String get gettingStarted => 'Premiers pas';

  @override
  String get gettingStartedDescription =>
      'Apprenez les bases de l\'utilisation de Feezer ou Fee Minimizer';

  @override
  String get providerManagement => 'Gestion des fournisseurs';

  @override
  String get providerManagementDescription =>
      'Comment ajouter, modifier et gérer les fournisseurs financiers';

  @override
  String get feeCalculation => 'Calcul des frais';

  @override
  String get feeCalculationDescription =>
      'Comprendre comment les frais sont calculés et optimisés';

  @override
  String get dataManagementDescription =>
      'Importer, exporter et sauvegarder vos données';

  @override
  String get videoTutorials => 'Tutoriels vidéo';

  @override
  String get videoTutorialsDescription =>
      'Regardez des guides vidéo étape par étape pour maîtriser Feezer ou Fee Minimizer';

  @override
  String get watchTutorials => 'Voir les tutoriels';

  @override
  String get shareYourThoughts => 'Partagez vos pensées';

  @override
  String get feedbackDescription =>
      'Aidez-nous à améliorer Feezer ou Fee Minimizer en partageant vos commentaires et suggestions';

  @override
  String get contactUs => 'Contactez-nous';

  @override
  String get contactDescription =>
      'Entrez en contact avec notre équipe de support pour obtenir de l\'aide sur vos questions ou problèmes.';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Téléphone';

  @override
  String get faqQuestion1 => 'Comment minimiser les frais de transaction ?';

  @override
  String get faqAnswer1 =>
      'Notre application calcule automatiquement la manière la plus rentable de gérer vos transactions en comparant différents fournisseurs et méthodes de paiement.';

  @override
  String get faqQuestion2 => 'Quelles devises sont prises en charge ?';

  @override
  String get faqAnswer2 =>
      'Nous prenons en charge toutes les principales devises mondiales incluant USD, EUR, GBP, JPY, et bien d\'autres. L\'application gère automatiquement les taux de conversion des devises.';

  @override
  String get faqQuestion3 => 'Mes données financières sont-elles sécurisées ?';

  @override
  String get faqAnswer3 =>
      'Oui, nous utilisons un cryptage et des mesures de sécurité de niveau bancaire. Vos données ne sont jamais stockées sur nos serveurs et tous les calculs sont effectués localement sur votre appareil.';

  @override
  String get faqQuestion4 => 'Comment mettre à jour les taux de change ?';

  @override
  String get faqAnswer4 =>
      'Les taux de change sont automatiquement mis à jour en temps réel à partir de fournisseurs de données financières fiables. Vous pouvez également actualiser manuellement les taux dans les paramètres.';

  @override
  String get faqQuestion5 => 'Puis-je sauvegarder mes fournisseurs préférés ?';

  @override
  String get faqAnswer5 =>
      'Oui, vous pouvez sauvegarder vos fournisseurs bancaires et méthodes de paiement préférés pour un accès rapide lors de nouveaux calculs.';

  @override
  String get faqQuestion6 => 'Comment ajouter un nouveau fournisseur ?';

  @override
  String get faqAnswer6 =>
      'Appuyez sur le bouton \'+\' dans l\'écran de liste des fournisseurs. Saisissez le nom du fournisseur, la description, et choisissez une icône. Vous pouvez ensuite ajouter des intervalles de frais pour différents montants de transaction.';

  @override
  String get faqQuestion7 => 'Qu\'est-ce que les intervalles de frais ?';

  @override
  String get faqAnswer7 =>
      'Les intervalles de frais définissent la structure de coût pour chaque fournisseur. Vous pouvez définir des frais fixes (ex. : 2,50 €) ou des frais en pourcentage (ex. : 1,5 %) pour différentes plages de montants de transaction.';

  @override
  String get faqQuestion8 => 'Comment fonctionne l\'optimisation ?';

  @override
  String get faqAnswer8 =>
      'Feezer analyse toutes les structures de frais de vos fournisseurs et calcule la manière optimale de diviser votre transaction en plusieurs opérations pour minimiser les frais totaux tout en respectant vos contraintes.';
}
