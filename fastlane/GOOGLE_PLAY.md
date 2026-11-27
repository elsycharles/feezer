# Publier Feezer sur Google Play

Tout ce qu'il faut remplir dans la Play Console, formulaire par formulaire, avec
les valeurs à copier. Les textes et images sont dans
[`metadata/android/fr-FR`](metadata/android/fr-FR) (français, langue par défaut)
et [`metadata/android/en-US`](metadata/android/en-US) (anglais).

| Élément | Valeur |
| --- | --- |
| Application | Feezer 1.1.1 (code de version 3) |
| Nom du package | `com.feezer` (définitif une fois l'app créée) |
| Fichier à envoyer | `build/app/outputs/bundle/release/app-release.aab` |
| Clé d'envoi | `~/.android/keystores/feezer-release.jks` (alias `feezer`) |
| Empreinte SHA-256 | `0D:F4:2E:2B:07:D0:DF:32:84:ED:52:AE:0F:05:08:DB:EC:67:F8:45:FE:4C:EC:C6:85:79:F1:B0:98:E3:54:95` |
| Version Android visée | 36 (exigée par Google Play), minimum Android 7 (API 24) |
| Permissions | Internet uniquement |

Pour refaire le fichier : `flutter build appbundle --release`.

---

## 0. L'application existe-t-elle déjà sur Google Play ?

Cherche `com.feezer` dans **Toutes les applications**.

* **Non** : passe à l'étape 1.
* **Oui** : la clé d'envoi d'origine est perdue. Dans l'application, va dans
  **Tester et publier › Configuration › Intégrité de l'application › Signature
  de l'application** et choisis **Demander la réinitialisation de la clé
  d'importation**. Joins le certificat
  `~/.android/keystores/feezer-upload-certificate.pem`. Une fois la demande
  acceptée (quelques jours), tes utilisateurs Play Store recevront la mise à jour
  sans rien désinstaller. Passe ensuite à l'étape 2.

## 1. Créer l'application

**Toutes les applications › Créer une application**

| Champ | Valeur |
| --- | --- |
| Nom de l'application | `Feezer : frais Mobile Money` |
| Langue par défaut | Français (France) – fr-FR |
| Application ou jeu | Application |
| Gratuite ou payante | Gratuite (on ne peut plus passer en payant ensuite) |
| Déclarations | Coche les deux : règles du programme pour les développeurs, et lois américaines sur l'exportation |

## 2. Configurer l'application

**Tableau de bord › Configurer votre application**, puis **Règles et
programmes › Contenu de l'application**.

### Règles de confidentialité
URL : `https://github.com/elsycharles/feezer/blob/main/PRIVACY.md`

### Accès à l'application
**Toutes les fonctionnalités sont disponibles sans restriction d'accès.**
Feezer n'a ni compte ni connexion.

### Annonces
**Non, mon application ne contient pas d'annonces.**

### Classification du contenu
1. Adresse e-mail : `elsy.s.charles@gmail.com`
2. Catégorie : **Utilitaires, productivité, communication ou autre**
3. Réponds **Non** à toutes les questions : violence, sexualité, langage
   grossier, substances, jeux d'argent, interactions entre utilisateurs,
   partage de la position, achats numériques, navigateur web.
4. Résultat attendu : **Tout public** (PEGI 3, ESRB Everyone).

### Public cible et contenu
* Tranches d'âge : **18 ans et plus** seulement. L'app parle d'argent et ne
  vise pas les enfants ; cela évite les obligations du programme Familles.
* L'application pourrait-elle attirer les enfants ? **Non.**

### Sécurité des données
1. Votre application collecte-t-elle ou partage-t-elle des données
   utilisateur ? **Non.**
2. Comptes : **Mon application ne permet pas de créer un compte.**
3. Aperçu attendu : **Aucune donnée collectée**, **Aucune donnée partagée avec
   des tiers**.

L'app ne fait que télécharger un fichier public (les frais) et garde tout le
reste sur le téléphone : rien n'est « collecté » au sens de Google.

### Identifiant publicitaire
**Non**, l'application n'utilise pas l'identifiant publicitaire.

### Fonctionnalités financières
**Mon application ne propose aucune fonctionnalité financière.**
Feezer calcule des frais : il ne fait ni paiement, ni transfert, ni prêt, et
n'accède à aucun compte.

### Autres déclarations
| Formulaire | Réponse |
| --- | --- |
| Application d'actualités | Non |
| Santé | Mon application n'a pas de fonctionnalités liées à la santé |
| Applications gouvernementales | Non |
| Recherche des contacts / statut COVID-19 | Ce n'est pas une application de ce type |

## 3. Fiche Play Store principale

**Accroître le nombre d'utilisateurs › Présence sur le Store › Fiche Play Store
principale**

| Champ | Fichier ou valeur |
| --- | --- |
| Nom de l'application (30 max) | [`title.txt`](metadata/android/fr-FR/title.txt) : `Feezer : frais Mobile Money` (27) |
| Brève description (80 max) | [`short_description.txt`](metadata/android/fr-FR/short_description.txt) (75) |
| Description complète (4 000 max) | [`full_description.txt`](metadata/android/fr-FR/full_description.txt) (2 223) |
| Icône de l'application (512 × 512) | [`images/icon.png`](metadata/android/fr-FR/images/icon.png) |
| Image de présentation (1024 × 500) | [`images/featureGraphic.png`](metadata/android/fr-FR/images/featureGraphic.png) |
| Vidéo | facultative, voir la section 7 |
| Captures d'écran du téléphone | [`images/phoneScreenshots`](metadata/android/fr-FR/images/phoneScreenshots) : `1.png` à `7.png`, dans cet ordre |
| Tablettes 7 et 10 pouces, Chromebook | laisser vide (facultatif) |

Texte alternatif de l'image de présentation (140 max) :
`Logo Feezer sur fond bleu : payez moins de frais sur vos retraits et transferts mobile money`

**Version anglaise** : bouton **Gérer les traductions › Ajouter des
traductions › Anglais (États-Unis) – en-US**, puis mêmes champs avec les
fichiers de [`metadata/android/en-US`](metadata/android/en-US). Texte
alternatif : `Feezer logo on blue: pay less in fees on your mobile money withdrawals and transfers`

Le malgache n'est pas proposé pour les fiches Google Play : l'application reste
disponible en malgache à l'intérieur.

## 4. Paramètres du Store

**Accroître le nombre d'utilisateurs › Présence sur le Store › Paramètres du
Store**

| Champ | Valeur |
| --- | --- |
| Type d'application | Application |
| Catégorie | **Finance** |
| Tags (5 max) | choisis parmi ceux proposés les plus proches de : finances personnelles, paiements mobiles, transfert d'argent, calculatrice, budget |
| Adresse e-mail (obligatoire, publique) | `elsy.s.charles@gmail.com` |
| Site web | `https://elsycharles.github.io/` |
| Téléphone (facultatif, public) | `+261 34 84 216 34`, ou laisse vide pour éviter les appels |

## 5. Pays et prix

* **Pays/régions** : Madagascar au minimum (l'app est faite pour les opérateurs
  malgaches). Tu peux ajouter les autres pays sans risque.
* **Prix** : gratuite.

## 6. Envoyer la version

### Si ton compte développeur personnel a été créé après le 13 novembre 2023
Google exige d'abord un **test fermé** :

1. **Tester et publier › Tests › Test fermé › Créer un canal** (ou utiliser
   « Alpha »).
2. **Testeurs** : crée une liste d'au moins **12 adresses Gmail**, puis
   enregistre.
3. **Créer une version** : accepte la **signature d'application par Google
   Play**, envoie `app-release.aab`, nom de version `1.1.1 (3)`, notes de version
   : [`changelogs/3.txt`](metadata/android/fr-FR/changelogs/3.txt) (fr-FR) et
   [`changelogs/3.txt`](metadata/android/en-US/changelogs/3.txt) (en-US).
4. **Examiner la version › Lancer le déploiement**, puis envoie le lien
   d'inscription aux testeurs : ils doivent l'accepter et installer l'app.
5. Attends que **12 testeurs** soient inscrits **pendant 14 jours d'affilée**,
   puis **Tableau de bord › Demander l'accès à la production** (Google répond en
   7 jours environ).

### Ensuite (ou directement, pour un compte plus ancien)
**Tester et publier › Production › Créer une version** : même fichier, mêmes
notes, puis **Examiner la version › Envoyer pour examen**. Le premier examen
prend généralement quelques jours.

## 7. Vidéo (facultative)

Une vidéo de 20 à 30 secondes montrant l'app dès les 10 premières secondes :
choisir MVola › Retrait, taper un montant, toucher Optimiser, montrer le gain.

1. Mets-la sur YouTube en **Public** ou **Non répertoriée**, sans monétisation
   (pas de publicités), pas réservée aux adultes.
2. Colle l'adresse de la vidéo (pas d'une playlist, sans paramètre de temps)
   dans le champ **Vidéo** de la fiche.

## 8. Référencement (ASO)

* Les mots recherchés sont placés dans le nom (« frais », « Mobile Money »), la
  brève description (« retirez », « envoyez », « argent mobile », « frais ») et
  la description (MVola, Yas, Telma, Orange Money, Airtel Money, Madagascar,
  retrait, transfert, microfinance), sans répétition excessive : Google
  sanctionne le bourrage de mots-clés.
* Aucune formule interdite (« meilleur », « n° 1 », « gratuit », « téléchargez
  maintenant ») dans les textes ni sur les images.
* Réponds aux avis et mets la fiche à jour à chaque nouvelle fonction.

## 9. Mises à jour suivantes

1. Augmente la version dans `pubspec.yaml` (par exemple `1.1.1+3` : le nombre
   après `+` doit toujours augmenter).
2. `flutter build appbundle --release`, puis envoie le fichier dans une nouvelle
   version.
3. Ajoute les notes dans `metadata/android/<langue>/changelogs/<code>.txt`.
4. Pour refaire les images :
   ```sh
   flutter test tool/store_screenshots_test.dart
   python3 tool/store/compose_store_assets.py
   ```

**Ne perds jamais la clé** `~/.android/keystores/feezer-release.jks` ni ses mots
de passe (dans `android/key.properties`) : garde-en une copie hors de ce Mac.
