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
  String get onboardingDescription1 =>
      'Entrez un montant : Feezer le découpe en opérations qui coûtent le moins de frais possible.';

  @override
  String get onboardingTitle2 => 'Les vrais frais des opérateurs';

  @override
  String get onboardingDescription2 =>
      'MVola, Orange Money, Airtel Money : les grilles viennent des tarifs officiels des opérateurs et se mettent à jour en un geste.';

  @override
  String get onboardingTitle3 => 'Retraits et transferts';

  @override
  String get onboardingDescription3 =>
      'Choisissez l\'opérateur et l\'opération. Vos données restent sur votre téléphone, même sans internet.';

  @override
  String get next => 'Suivant';

  @override
  String get skip => 'Passer';

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
  String get pleaseEnterValidAmount => 'Veuillez saisir un montant valide';

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
  String get maxAmountMustBeGreaterThanMinAmount =>
      'Le montant maximum doit être supérieur au montant minimum';

  @override
  String get fee => 'Frais';

  @override
  String get noOptimizationResultsFound =>
      'Aucun résultat. Vérifiez le montant et la grille choisie.';

  @override
  String get about => 'À propos';

  @override
  String get faqAndContact => 'FAQ et contact';

  @override
  String get termsOfUse => 'Conditions d\'utilisation';

  @override
  String get termsIntroductionTitle => 'Introduction';

  @override
  String get termsIntroductionContent =>
      'Ces conditions s\'appliquent à l\'application Feezer, qui aide à réduire les frais d\'argent mobile. En utilisant Feezer, vous les acceptez.';

  @override
  String get termsAcceptanceTitle => 'Acceptation';

  @override
  String get termsAcceptanceContent =>
      'Si vous n\'acceptez pas ces conditions, n\'utilisez pas l\'application. Elles peuvent évoluer avec les nouvelles versions de Feezer.';

  @override
  String get termsServiceTitle => 'Le service';

  @override
  String get termsServiceContent =>
      'À partir de grilles de frais, Feezer calcule comment découper un retrait ou un transfert pour payer moins de frais. Les grilles officielles sont lues sur les sites des opérateurs et peuvent changer à tout moment : vérifiez toujours les frais auprès de votre opérateur.';

  @override
  String get termsPrivacyTitle => 'Confidentialité';

  @override
  String get termsPrivacyContent =>
      'Feezer ne demande aucun compte et ne collecte aucune donnée personnelle. Vos grilles et vos calculs restent sur votre téléphone. La mise à jour des frais télécharge un fichier public, sans envoyer vos données.';

  @override
  String get termsLiabilityTitle => 'Responsabilité';

  @override
  String get termsLiabilityContent =>
      'Les résultats sont donnés à titre indicatif. Feezer n\'est affilié à aucun opérateur et n\'est pas responsable des frais réellement facturés, ni des décisions prises à partir de ses calculs.';

  @override
  String get termsTerminationTitle => 'Arrêt';

  @override
  String get termsTerminationContent =>
      'Vous pouvez arrêter d\'utiliser Feezer à tout moment : désinstaller l\'application efface ses données de votre téléphone.';

  @override
  String get termsGoverningLawTitle => 'Droit applicable';

  @override
  String get termsGoverningLawContent =>
      'Ces conditions sont régies par les lois applicables là où Feezer est utilisé. Tout litige sera traité par les voies légales prévues par ces lois.';

  @override
  String get termsContactTitle => 'Contact';

  @override
  String get termsContactContent =>
      'Une question ? Écrivez-nous depuis Aide et support, ou à elsy.s.charles@gmail.com.';

  @override
  String get noFeeIntervalsFound =>
      'Cette grille n\'a encore aucun palier. Ajoutez-les dans l\'onglet Opérateurs.';

  @override
  String get addFeeInterval => 'Ajouter un palier';

  @override
  String get deleteFeeIntervals => 'Supprimer le palier';

  @override
  String get feeIntervalCreatedSuccessfully => 'Palier ajouté';

  @override
  String get icon => 'Icône';

  @override
  String get thisFieldIsRequired => 'Ce champ est obligatoire';

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
  String get minTransactionsCannotBeGreaterThanMax =>
      'Le minimum de transactions ne peut pas être supérieur au maximum';

  @override
  String get pleaseEnterValidFee => 'Veuillez saisir des frais valides';

  @override
  String get minimumAmount => 'Montant minimum';

  @override
  String get maximumAmount => 'Montant maximum';

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
  String get failedToCalculateOptimization =>
      'Échec du calcul de l\'optimisation';

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
    return 'Échec de l\'importation : $error';
  }

  @override
  String exportFailed(String error) {
    return 'Échec de l\'exportation : $error';
  }

  @override
  String providersImported(int count) {
    return '$count grille(s) importée(s)';
  }

  @override
  String feeIntervalsImported(int count) {
    return '$count palier(s) importé(s)';
  }

  @override
  String errorsEncountered(int count) {
    return '$count erreur(s) rencontrée(s)';
  }

  @override
  String get importDataDescription =>
      'Ajoutez des grilles depuis un fichier CSV (une ligne par palier).';

  @override
  String get exportDataDescription =>
      'Enregistrez toutes vos grilles et leurs paliers dans un fichier CSV.';

  @override
  String get csvContentCannotBeEmpty => 'Le contenu CSV ne peut pas être vide';

  @override
  String get chooseWhereToSave => 'Choisir où enregistrer le fichier';

  @override
  String get fileSavedSuccessfully => 'Fichier enregistré avec succès';

  @override
  String get failedToSaveFile => 'Échec de l\'enregistrement du fichier';

  @override
  String get csvFileIsEmpty => 'Le fichier CSV est vide';

  @override
  String get noDataRowsFound => 'Aucune ligne de données trouvée';

  @override
  String rowProviderNameRequired(int rowNumber) {
    return 'Ligne $rowNumber : le nom de l\'opérateur est obligatoire';
  }

  @override
  String rowProviderAlreadyExists(int rowNumber, String name) {
    return 'Ligne $rowNumber : la grille « $name » existe déjà';
  }

  @override
  String rowIntervalOverlaps(int rowNumber, String overlap) {
    return 'Ligne $rowNumber : ce palier chevauche un palier existant ($overlap)';
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
  String rowFeePercentageInvalid(int rowNumber, String fee) {
    return 'Ligne $rowNumber : Les frais en pourcentage doivent être entre 0 et 100 ($fee%)';
  }

  @override
  String importedProvidersAndFees(int providersCount, int feesCount) {
    return '$providersCount grille(s) et $feesCount palier(s) importés';
  }

  @override
  String get noDataToExport => 'Aucune donnée à exporter';

  @override
  String get providerNameColumnNotFound =>
      'Colonne du nom de l\'opérateur introuvable';

  @override
  String get fixedAmount => 'Montant fixe';

  @override
  String get percentage => 'Pourcentage';

  @override
  String get percentageMustBeBetween0And100 =>
      'Le pourcentage doit être entre 0 et 100';

  @override
  String get faq => 'FAQ';

  @override
  String get faqWhatIsFeeMinimizer => 'Qu\'est-ce que Feezer ?';

  @override
  String get faqWhatIsFeeMinimizerAnswer =>
      'Feezer calcule comment découper un retrait ou un transfert d\'argent mobile pour payer le moins de frais possible, à partir des grilles officielles des opérateurs.';

  @override
  String get faqHowToAddProvider => 'Comment ajouter une grille ?';

  @override
  String get faqHowToAddProviderAnswer =>
      'Dans l\'onglet Opérateurs, touchez « Ajouter », donnez le nom de l\'opérateur et l\'opération, puis ajoutez les paliers (minimum, maximum et frais). Vous pouvez aussi importer un fichier CSV.';

  @override
  String get faqHowToCalculateFees => 'Comment se fait le calcul ?';

  @override
  String get faqHowToCalculateFeesAnswer =>
      'Choisissez l\'opérateur et l\'opération, puis entrez le montant disponible (frais compris). Feezer essaie toutes les combinaisons de paliers et garde celle qui fait recevoir le plus. Le résultat est comparé à la méthode habituelle : retirer ou envoyer le plus gros montant possible à chaque fois.';

  @override
  String get faqMinMaxTransactionRange =>
      'À quoi sert le nombre d\'opérations ?';

  @override
  String get faqMinMaxTransactionRangeAnswer =>
      'C\'est facultatif. Il limite le nombre de retraits ou d\'envois du découpage, par exemple « au plus 2 » si vous ne voulez pas en faire plus de deux. Feezer indique ce que cette limite vous coûte.';

  @override
  String get faqDataSecurity => 'Mes données sont-elles partagées ?';

  @override
  String get faqDataSecurityAnswer =>
      'Non. Vos grilles et vos montants restent sur votre téléphone ; Feezer n\'a pas de compte et n\'envoie rien. La mise à jour des frais télécharge seulement un fichier public.';

  @override
  String get faqOfflineMode => 'Faut-il internet ?';

  @override
  String get faqOfflineModeAnswer =>
      'Non. Les calculs se font sur votre téléphone. Internet ne sert qu\'à mettre à jour les frais.';

  @override
  String get faqExportData => 'Comment sauvegarder mes grilles ?';

  @override
  String get faqExportDataAnswer =>
      'Paramètres › Import / export : exportez vos grilles dans un fichier CSV, puis importez-le plus tard ou sur un autre téléphone.';

  @override
  String get website => 'Site web';

  @override
  String get contactUs => 'Nous contacter';

  @override
  String get email => 'Email';

  @override
  String get exceedsEnteredAmount => 'Dépasse le montant saisi';

  @override
  String get optimizationBudgetTooSmall =>
      'Le montant est trop faible pour une opération avec cette grille.';

  @override
  String get optimizationConstraintsUnsatisfiable =>
      'Aucun découpage ne respecte ce nombre d\'opérations pour ce montant.';

  @override
  String get optimizationNotProven =>
      'Recherche très longue : ce découpage est excellent, mais n\'a pas pu être prouvé comme le meilleur.';

  @override
  String feeIntervalOverlaps(String range) {
    return 'Ce palier chevauche un palier existant ($range).';
  }

  @override
  String get failedToDeleteFeeIntervals => 'Impossible de supprimer le palier';

  @override
  String get failedToSaveChanges =>
      'Échec de l\'enregistrement des modifications';

  @override
  String get tabOptimize => 'Optimiser';

  @override
  String get optimizeTitle => 'Payez moins de frais';

  @override
  String get optimizeSubtitle =>
      'Feezer découpe votre montant en opérations qui coûtent le moins de frais.';

  @override
  String get add => 'Ajouter';

  @override
  String get amountAvailable => 'Montant disponible';

  @override
  String get amountHelper =>
      'Frais compris : le total qui sortira de votre compte.';

  @override
  String get transferCount => 'Nombre d\'envois';

  @override
  String get transferCountHelp =>
      'Facultatif. Limitez le nombre d\'envois que le plan peut utiliser.';

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
  String get gainVsClassic =>
      'Par rapport à l\'envoi du plus gros montant possible à chaque fois.';

  @override
  String feesSavedTitle(String amount) {
    return '$amount de frais économisés';
  }

  @override
  String get feesSavedVsClassic =>
      'La méthode habituelle coûterait plus cher pour le même montant.';

  @override
  String get alreadyOptimalTitle =>
      'La méthode habituelle est déjà la meilleure';

  @override
  String get alreadyOptimalMessage =>
      'Pour ce montant, découper n\'apporte rien de plus.';

  @override
  String limitCost(String amount) {
    return 'Sans cette limite, $amount de plus seraient reçus.';
  }

  @override
  String get limitFree => 'Cette limite ne vous coûte rien ici.';

  @override
  String get nearOptimalTitle => 'Montant très élevé';

  @override
  String get planTitle => 'Votre plan d\'envoi';

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
      'Méthode habituelle : envoyer le plus gros montant possible, puis le reste.';

  @override
  String get sameAmountByHand => 'Même montant reçu, méthode habituelle';

  @override
  String sameAmountByHandDetail(String net, String fees, String total) {
    return 'Pour obtenir $net, la méthode habituelle coûte $fees de frais, soit $total débités.';
  }

  @override
  String get cannotSplitByHand =>
      'La méthode habituelle ne permet pas d\'obtenir ce montant.';

  @override
  String get classicPlan => 'Plan habituel';

  @override
  String get showDetails => 'Voir le détail';

  @override
  String get showLess => 'Masquer le détail';

  @override
  String get noProvidersYet => 'Aucune grille pour l\'instant';

  @override
  String get noProvidersMessage =>
      'Mettez à jour les frais officiels ou ajoutez votre propre grille.';

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
  String get providerNameHint => 'ex. MVola, Orange Money, ma banque';

  @override
  String get descriptionOptional => 'Description (facultatif)';

  @override
  String get feeGrid => 'Grille de frais';

  @override
  String get amountRange => 'Montant envoyé';

  @override
  String get noIntervalsMessage =>
      'Ajoutez les paliers de cette grille pour optimiser vos opérations.';

  @override
  String get gridHint => 'Touchez un palier pour le modifier ou le supprimer.';

  @override
  String get intervalFormHelp =>
      'Les frais s\'appliquent quand le montant envoyé est entre le minimum et le maximum (inclus).';

  @override
  String get downloadingFees => 'Lecture des grilles publiées…';

  @override
  String get feesDownloadFailed => 'Vérifiez votre connexion puis réessayez.';

  @override
  String get feesAlreadyUpToDate => 'Vos frais sont à jour';

  @override
  String get gridsOthersUnchanged => 'Vos autres grilles ne changent pas.';

  @override
  String get updateAction => 'Mettre à jour';

  @override
  String get feesUpdatedSuccessfully => 'Frais mis à jour';

  @override
  String get importExportSubtitle =>
      'Sauvegarder ou partager vos grilles (CSV)';

  @override
  String get replayIntroduction => 'Revoir la présentation';

  @override
  String get faqFeeUpdate => 'D\'où viennent les frais ?';

  @override
  String get faqFeeUpdateAnswer =>
      'Chaque jour, le projet public feezer-fee-tables lit les grilles officielles sur mvola.mg et orange.mg. La grille Airtel est recopiée à la main depuis ses tarifs, car son site ne peut pas être lu automatiquement. « Mettre à jour » télécharge ces grilles ; vos autres grilles ne changent pas.';

  @override
  String get ok => 'OK';

  @override
  String get pasteCsv => 'Coller du texte CSV';

  @override
  String get chooseCsvFile => 'Choisir un fichier CSV';

  @override
  String get csvTemplate => 'Modèle';

  @override
  String get csvTemplateDescription =>
      'Partez d\'un fichier prêt avec les colonnes attendues.';

  @override
  String get downloadTemplate => 'Télécharger le modèle';

  @override
  String get csvFormat => 'Format du fichier';

  @override
  String get csvFormatHelp =>
      'Une ligne par palier. Les lignes ayant le même nom_fournisseur et le même type_operation forment une grille. type_operation vaut withdrawal, transfer_same, transfer_same_app, transfer_other, transfer_microfinance ou transfer_unregistered (facultatif) ; type_frais vaut fixed ou percentage. Virgules ou points-virgules acceptés.';

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
  String get operatorsSubtitle =>
      'Les grilles de frais utilisées pour vos calculs.';

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
    return 'La grille $name existe déjà.';
  }

  @override
  String get deleteGridTitle => 'Supprimer la grille';

  @override
  String deleteGridMessage(String name) {
    return 'La grille $name et ses paliers seront supprimés.';
  }

  @override
  String get optimizeWithGrid => 'Optimiser avec cette grille';

  @override
  String get moreOptions => 'Plus d\'options';

  @override
  String get officialFees => 'Frais officiels';

  @override
  String feesCheckedOn(String date) {
    return 'Vérifiés sur les sites des opérateurs le $date';
  }

  @override
  String get feesNeverChecked =>
      'Téléchargez les derniers frais publiés par les opérateurs.';

  @override
  String sourceOfficial(String host) {
    return 'Grille officielle · $host';
  }

  @override
  String sourceOfficialDated(String host, String date) {
    return 'Grille officielle · $host · $date';
  }

  @override
  String get sourceManual => 'Grille recopiée des tarifs de l\'opérateur';

  @override
  String sourceManualDated(String date) {
    return 'Grille recopiée des tarifs de l\'opérateur · $date';
  }

  @override
  String get sourceEdited => 'Grille modifiée par vous';

  @override
  String get openSource => 'Voir la page officielle';

  @override
  String get editPublishedGridWarning =>
      'Cette grille vient des tarifs de l\'opérateur. Si vous mettez à jour les frais plus tard, votre modification sera remplacée.';

  @override
  String get feesSection => 'Frais';

  @override
  String get updateFeesTitle => 'Mettre à jour les frais';

  @override
  String get feesDownloadFailedTitle => 'Téléchargement impossible';

  @override
  String get updateReviewIntro =>
      'Les opérateurs ont publié de nouveaux frais. Voici ce qui change :';

  @override
  String effectiveSince(String date) {
    return 'en vigueur depuis le $date';
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
  String get withdrawalCountHelp =>
      'Facultatif. Limitez le nombre de retraits que le plan peut utiliser.';

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
  String get planTitleWithdrawal => 'Votre plan de retrait';

  @override
  String get gainVsClassicWithdrawal =>
      'Par rapport au retrait du plus gros montant possible à chaque fois.';

  @override
  String get classicExplanationWithdrawal =>
      'Méthode habituelle : retirer le plus gros montant possible, puis le reste.';

  @override
  String get amountWithdrawn => 'Montant retiré';

  @override
  String get noTiersYet => 'Aucun palier pour l\'instant';

  @override
  String get intervalFormHelpWithdrawal =>
      'Les frais s\'appliquent quand le montant retiré est entre le minimum et le maximum (inclus).';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get free => 'Gratuit';

  @override
  String get failedToLoadData => 'Impossible de charger les données';

  @override
  String get failedToOpenLink => 'Impossible d\'ouvrir le lien';

  @override
  String get pressAgainToExit => 'Appuyez encore pour quitter';

  @override
  String onlyOperation(String operation, String operator) {
    return 'Seule l\'opération « $operation » est disponible pour $operator.';
  }

  @override
  String amountStepMultiples(String amount) {
    return 'Multiples de $amount';
  }

  @override
  String optimizationStepTooLarge(String amount) {
    return 'Aucun palier de cette grille n\'accepte des montants multiples de $amount. Désactivez l\'arrondi.';
  }

  @override
  String get roundToHundred => 'Arrondir à la centaine';

  @override
  String roundToHundredOnWithdrawal(String example, String wrong) {
    return 'Chaque retrait est un multiple de 100 : $example, jamais $wrong.';
  }

  @override
  String roundToHundredOnTransfer(String example, String wrong) {
    return 'Chaque envoi est un multiple de 100 : $example, jamais $wrong.';
  }

  @override
  String get roundToHundredOff => 'Montants exacts, à l\'ariary près.';
}
