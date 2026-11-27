// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get onboardingTitle1 => 'Payez moins de frais';

  @override
  String get onboardingTitle2 => 'En 3 étapes';

  @override
  String get next => 'Suivant';

  @override
  String get getStarted => 'Commencer';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get settings => 'Paramètres';

  @override
  String get createInterval => 'Ajouter le palier';

  @override
  String get optimize => 'Optimiser';

  @override
  String get pleaseEnterValidAmount => 'Montant invalide';

  @override
  String get pleaseSelectProvider => 'Choisissez un opérateur';

  @override
  String get appearance => 'Apparence';

  @override
  String get language => 'Langue';

  @override
  String get system => 'Système';

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String get newFeeInterval => 'Nouveau palier';

  @override
  String get maxAmountMustBeGreaterThanMinAmount => 'Doit dépasser le minimum';

  @override
  String get fee => 'Frais';

  @override
  String get noOptimizationResultsFound => 'Aucun résultat';

  @override
  String get about => 'À propos';

  @override
  String get termsOfUse => 'Conditions d\'utilisation';

  @override
  String get termsServiceTitle => 'Le service';

  @override
  String get termsServiceContent =>
      'Feezer calcule comment découper un retrait ou un transfert pour payer le moins de frais, d\'après les grilles des opérateurs.';

  @override
  String get termsPrivacyTitle => 'Vos données';

  @override
  String get termsPrivacyContent =>
      'Aucun compte, aucune donnée collectée. Vos grilles et vos calculs restent sur votre téléphone.';

  @override
  String get termsLiabilityTitle => 'Responsabilité';

  @override
  String get termsLiabilityContent =>
      'Les résultats sont indicatifs : les opérateurs peuvent changer leurs frais. Vérifiez-les avant chaque opération.';

  @override
  String get termsContactTitle => 'Contact';

  @override
  String get noFeeIntervalsFound => 'Cette grille n\'a aucun palier';

  @override
  String get addFeeInterval => 'Ajouter un palier';

  @override
  String get deleteFeeIntervals => 'Supprimer le palier';

  @override
  String get feeIntervalCreatedSuccessfully => 'Palier ajouté';

  @override
  String get icon => 'Icône';

  @override
  String get thisFieldIsRequired => 'Obligatoire';

  @override
  String get feeIntervalUpdatedSuccessfully => 'Palier modifié';

  @override
  String feeIntervalDeletedSuccessfully(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count paliers supprimés',
      one: 'Palier supprimé',
    );
    return '$_temp0';
  }

  @override
  String get editFeeInterval => 'Modifier le palier';

  @override
  String get minTransactionsCannotBeGreaterThanMax => 'Minimum > maximum';

  @override
  String get pleaseEnterValidFee => 'Frais invalides';

  @override
  String get helpAndSupport => 'Aide et support';

  @override
  String get addNewProvider => 'Ajouter un opérateur';

  @override
  String get saveChanges => 'Enregistrer';

  @override
  String confirmDeleteIntervals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ces $count paliers seront retirés de la grille.',
      one: 'Ce palier sera retiré de la grille.',
    );
    return '$_temp0';
  }

  @override
  String get failedToCalculateOptimization => 'Échec du calcul';

  @override
  String get importExportData => 'Import / export';

  @override
  String get importData => 'Importer';

  @override
  String get exportData => 'Exporter';

  @override
  String get importSuccessful => 'Import terminé';

  @override
  String importFailed(String error) {
    return 'Échec de l\'import : $error';
  }

  @override
  String exportFailed(String error) {
    return 'Échec de l\'export : $error';
  }

  @override
  String errorsEncountered(int count) {
    return '$count erreur(s)';
  }

  @override
  String get csvContentCannotBeEmpty => 'Texte vide';

  @override
  String get chooseWhereToSave => 'Enregistrer le fichier';

  @override
  String get fileSavedSuccessfully => 'Fichier enregistré';

  @override
  String get failedToSaveFile => 'Échec de l\'enregistrement';

  @override
  String get csvFileIsEmpty => 'Fichier vide';

  @override
  String get noDataRowsFound => 'Aucune ligne trouvée';

  @override
  String rowProviderNameRequired(int rowNumber) {
    return 'Ligne $rowNumber : opérateur manquant';
  }

  @override
  String rowProviderAlreadyExists(int rowNumber, String name) {
    return 'Ligne $rowNumber : « $name » existe déjà';
  }

  @override
  String rowIntervalOverlaps(int rowNumber, String overlap) {
    return 'Ligne $rowNumber : chevauche $overlap';
  }

  @override
  String rowInvalidAmounts(
    int rowNumber,
    String minStr,
    String maxStr,
    String feeStr,
  ) {
    return 'Ligne $rowNumber : montants invalides ($minStr, $maxStr, $feeStr)';
  }

  @override
  String rowMinAmountGreaterThanMax(int rowNumber, String min, String max) {
    return 'Ligne $rowNumber : min $min > max $max';
  }

  @override
  String rowFeeMustBePositive(int rowNumber) {
    return 'Ligne $rowNumber : frais négatifs';
  }

  @override
  String rowFeePercentageInvalid(int rowNumber, String fee) {
    return 'Ligne $rowNumber : pourcentage hors de 0–100 ($fee)';
  }

  @override
  String importedProvidersAndFees(int providersCount, int feesCount) {
    return '$providersCount grille(s), $feesCount palier(s)';
  }

  @override
  String get noDataToExport => 'Aucune grille à exporter';

  @override
  String get providerNameColumnNotFound => 'Colonne opérateur introuvable';

  @override
  String get fixedAmount => 'Montant fixe';

  @override
  String get percentage => 'Pourcentage';

  @override
  String get percentageMustBeBetween0And100 => 'Entre 0 et 100';

  @override
  String get faq => 'FAQ';

  @override
  String get faqExportData => 'Comment sauvegarder mes grilles ?';

  @override
  String get faqExportDataAnswer =>
      'Dans Paramètres › Import / export, exportez-les en fichier CSV, puis importez-le sur un autre téléphone.';

  @override
  String get website => 'Site web';

  @override
  String get contactUs => 'Nous contacter';

  @override
  String get email => 'Email';

  @override
  String get optimizationBudgetTooSmall =>
      'Montant trop faible pour cette grille';

  @override
  String get optimizationConstraintsUnsatisfiable =>
      'Impossible avec cette limite';

  @override
  String feeIntervalOverlaps(String range) {
    return 'Chevauche le palier $range';
  }

  @override
  String get failedToDeleteFeeIntervals => 'Suppression impossible';

  @override
  String get failedToSaveChanges => 'Échec de l\'enregistrement';

  @override
  String get tabOptimize => 'Optimiser';

  @override
  String get add => 'Ajouter';

  @override
  String get amountAvailable => 'Montant disponible';

  @override
  String get amountHelper => 'Frais compris';

  @override
  String get transferCount => 'Nombre d\'envois';

  @override
  String get transferCountFree => 'Sans limite';

  @override
  String transferCountExactly(int count) {
    return 'Exactement $count';
  }

  @override
  String transferCountRange(int min, int max) {
    return 'Entre $min et $max';
  }

  @override
  String transferCountAtLeast(int count) {
    return 'Au moins $count';
  }

  @override
  String transferCountAtMost(int count) {
    return 'Au plus $count';
  }

  @override
  String get minimumShort => 'Minimum';

  @override
  String get maximumShort => 'Maximum';

  @override
  String get anyCount => 'Libre';

  @override
  String get recipientReceives => 'Le destinataire reçoit';

  @override
  String get bestSplit => 'Optimal';

  @override
  String get goodSplit => 'Très bon';

  @override
  String transferCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count envois',
      one: '1 envoi',
    );
    return '$_temp0';
  }

  @override
  String get feesLabel => 'Frais';

  @override
  String get debitedLabel => 'Débité';

  @override
  String get leftLabel => 'Reste';

  @override
  String gainTitle(String amount) {
    return '+$amount reçus en plus';
  }

  @override
  String feesSavedTitle(String amount) {
    return '$amount de frais économisés';
  }

  @override
  String get alreadyOptimalTitle => 'Méthode habituelle déjà optimale';

  @override
  String limitCost(String amount) {
    return 'Votre limite coûte $amount';
  }

  @override
  String get planTitle => 'Plan d\'envoi';

  @override
  String sendAmount(String amount) {
    return 'Envoyer $amount';
  }

  @override
  String feePerTransfer(String amount) {
    return 'frais $amount par envoi';
  }

  @override
  String get compareTitle => 'Comparaison';

  @override
  String get optimizedColumn => 'Optimisé';

  @override
  String get classicColumn => 'Habituel';

  @override
  String get receivedLabel => 'Reçu';

  @override
  String get transfersLabel => 'Envois';

  @override
  String get classicExplanation =>
      'Habituel : envoyer le maximum, puis le reste';

  @override
  String get classicPlan => 'Plan habituel';

  @override
  String get showDetails => 'Voir le détail';

  @override
  String get showLess => 'Masquer le détail';

  @override
  String get noProvidersYet => 'Aucune grille';

  @override
  String tierCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count paliers',
      one: '1 palier',
      zero: 'Aucun palier',
    );
    return '$_temp0';
  }

  @override
  String feesFrom(String amount) {
    return 'frais dès $amount';
  }

  @override
  String get providerNameHint => 'ex. MVola, ma banque';

  @override
  String get descriptionOptional => 'Description (facultatif)';

  @override
  String get feeGrid => 'Grille de frais';

  @override
  String get amountRange => 'Montant envoyé';

  @override
  String get downloadingFees => 'Téléchargement…';

  @override
  String get feesDownloadFailed => 'Vérifiez votre connexion';

  @override
  String get feesAlreadyUpToDate => 'Vos frais sont à jour';

  @override
  String get updateAction => 'Mettre à jour';

  @override
  String get feesUpdatedSuccessfully => 'Frais mis à jour';

  @override
  String get replayIntroduction => 'Revoir la présentation';

  @override
  String get faqFeeUpdate => 'D\'où viennent les frais ?';

  @override
  String get faqFeeUpdateAnswer =>
      'Des tarifs officiels de MVola, Orange Money et Airtel Money. Touchez « Mettre à jour » pour avoir les derniers.';

  @override
  String get ok => 'OK';

  @override
  String get pasteCsv => 'Coller du texte CSV';

  @override
  String get chooseCsvFile => 'Choisir un fichier CSV';

  @override
  String get csvTemplate => 'Modèle';

  @override
  String get downloadTemplate => 'Télécharger le modèle';

  @override
  String get csvFormat => 'Format du fichier';

  @override
  String get opWithdrawal => 'Retrait';

  @override
  String get opTransferSame => 'Transfert';

  @override
  String get opTransferSameApp => 'Transfert via l\'appli';

  @override
  String get opTransferOther => 'Vers un autre opérateur';

  @override
  String get opTransferMicrofinance => 'Vers une microfinance';

  @override
  String get opTransferUnregistered => 'Vers un non-abonné';

  @override
  String get opCustom => 'Autre';

  @override
  String get operators => 'Opérateurs';

  @override
  String get operatorLabel => 'Opérateur';

  @override
  String get operationLabel => 'Opération';

  @override
  String get operatorName => 'Nom de l\'opérateur';

  @override
  String gridCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count grilles',
      one: '1 grille',
    );
    return '$_temp0';
  }

  @override
  String get customGrids => 'Ajoutées par vous';

  @override
  String get editedTag => 'modifiée';

  @override
  String get newGrid => 'Nouvelle grille';

  @override
  String get editGrid => 'Modifier la grille';

  @override
  String get createGrid => 'Créer la grille';

  @override
  String get gridCreated => 'Grille créée';

  @override
  String get gridUpdated => 'Grille modifiée';

  @override
  String get gridDeleted => 'Grille supprimée';

  @override
  String gridAlreadyExists(String name) {
    return '$name existe déjà';
  }

  @override
  String get deleteGridTitle => 'Supprimer la grille';

  @override
  String deleteGridMessage(String name) {
    return '$name et ses paliers seront supprimés.';
  }

  @override
  String get optimizeWithGrid => 'Optimiser avec cette grille';

  @override
  String get moreOptions => 'Plus d\'options';

  @override
  String get officialFees => 'Frais officiels';

  @override
  String feesCheckedOn(String date) {
    return 'Vérifiés le $date';
  }

  @override
  String get feesNeverChecked => 'Pas encore vérifiés';

  @override
  String sourceOfficial(String host) {
    return 'Grille officielle · $host';
  }

  @override
  String sourceOfficialDated(String host, String date) {
    return 'Grille officielle · $host · $date';
  }

  @override
  String get sourceManual => 'Tarifs de l\'opérateur';

  @override
  String sourceManualDated(String date) {
    return 'Tarifs de l\'opérateur · $date';
  }

  @override
  String get sourceEdited => 'Modifiée par vous';

  @override
  String get editPublishedGridWarning =>
      'Une mise à jour des frais annulera ce changement.';

  @override
  String get feesSection => 'Frais';

  @override
  String get updateFeesTitle => 'Mettre à jour les frais';

  @override
  String get feesDownloadFailedTitle => 'Téléchargement impossible';

  @override
  String get updateReviewIntro => 'Nouveaux frais publiés :';

  @override
  String effectiveSince(String date) {
    return 'depuis le $date';
  }

  @override
  String get newTag => 'Nouvelle';

  @override
  String get updatedTag => 'Mise à jour';

  @override
  String get later => 'Plus tard';

  @override
  String get retry => 'Réessayer';

  @override
  String get withdrawalCount => 'Nombre de retraits';

  @override
  String get cashYouReceive => 'Vous recevez en espèces';

  @override
  String withdrawalCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count retraits',
      one: '1 retrait',
    );
    return '$_temp0';
  }

  @override
  String get withdrawalsLabel => 'Retraits';

  @override
  String withdrawAmount(String amount) {
    return 'Retirer $amount';
  }

  @override
  String feePerWithdrawal(String amount) {
    return 'frais $amount par retrait';
  }

  @override
  String get planTitleWithdrawal => 'Plan de retrait';

  @override
  String get classicExplanationWithdrawal =>
      'Habituel : retirer le maximum, puis le reste';

  @override
  String get amountWithdrawn => 'Montant retiré';

  @override
  String get noTiersYet => 'Aucun palier';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get free => 'Gratuit';

  @override
  String get failedToLoadData => 'Chargement impossible';

  @override
  String get failedToOpenLink => 'Impossible d\'ouvrir le lien';

  @override
  String get pressAgainToExit => 'Appuyez encore pour quitter';

  @override
  String get optimizationStepTooLarge =>
      'Désactivez l\'arrondi pour cette grille';

  @override
  String get roundToHundred => 'Arrondir à la centaine';

  @override
  String get roundToHundredOff => 'Montants exacts';

  @override
  String get faqHowItWorks => 'Comment ça marche ?';

  @override
  String get faqHowItWorksAnswer =>
      'Choisissez l\'opérateur, l\'opération et le montant disponible. Feezer trouve le découpage qui coûte le moins de frais.';

  @override
  String get faqRounding => 'Pourquoi arrondir à la centaine ?';

  @override
  String get faqRoundingAnswer =>
      'Les points de retrait ne donnent que des billets : impossible de retirer 10 040. Vous pouvez désactiver l\'arrondi à tout moment.';

  @override
  String get faqPrivacy => 'Mes données sont-elles partagées ?';

  @override
  String get faqPrivacyAnswer =>
      'Non. Feezer ne demande aucun compte et rien ne quitte votre téléphone.';

  @override
  String get onboardingText1 => 'Feezer découpe vos retraits et transferts.';

  @override
  String onboardingExample(String amount) {
    return 'Exemple : $amount sur votre compte';
  }

  @override
  String get onboardingOneGo => 'En une fois';

  @override
  String get onboardingWithFeezer => 'Avec Feezer';

  @override
  String get onboardingStep1 => 'Choisissez l\'opérateur';

  @override
  String get onboardingStep2 => 'Entrez le montant';

  @override
  String get onboardingStep3 => 'Suivez le plan';

  @override
  String roundToHundredOn(String example, String wrong) {
    return '$example, jamais $wrong';
  }

  @override
  String get vsUsualWay => 'Par rapport à la méthode habituelle';

  @override
  String get csvFormatRows =>
      'Une ligne par palier ; virgule ou point-virgule.';

  @override
  String get faqInternet => 'Faut-il internet ?';

  @override
  String get faqInternetAnswer =>
      'Non. Les calculs se font sur votre téléphone ; internet sert seulement à mettre à jour les frais.';

  @override
  String get termsIndependenceTitle => 'Indépendance';

  @override
  String get termsIndependenceContent =>
      'Feezer n\'est affilié à aucun opérateur et n\'est pas responsable des frais facturés.';

  @override
  String get termsAcceptance =>
      'En utilisant Feezer, vous acceptez ces conditions.';
}
