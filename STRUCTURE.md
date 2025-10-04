# 🎨 Structure CSS-like pour Fee Minimizer

## 📁 Structure finale

```
lib/
├── model/
│   ├── fee_interval_model.dart
│   └── provider_model.dart
├── screen/
│   ├── home/home_screen.dart
│   └── splash/splash_screen.dart
├── styles/
│   ├── global.dart      <- 🌐 Styles globaux (comme CSS global)
│   └── styles.dart      <- 📦 Export principal
├── util/
│   ├── constante_util.dart    <- 📊 Vraies constantes métier
│   ├── route_util.dart        <- 🛣️ Configuration routing
│   └── theme_util.dart        <- 🎨 Thèmes Material
├── widget/
│   ├── animated_logo.dart
│   ├── app_logo.dart
│   ├── app_title.dart
│   └── widgets.dart     <- 📦 Export widgets
└── main.dart

assets/                  <- 📁 Assets organisés comme CSS
├── fonts/
├── images/
│   ├── providers/
│   ├── onboarding/
│   ├── states/
│   └── flags/
├── icons/
│   ├── ui/
│   ├── navigation/
│   └── actions/
├── animations/
└── README.md
```

## 🚀 Usage

### Import du style global
```dart
import 'package:fee_minimizer/styles/global.dart';

// Utilisation
Container(
  padding: Global.padMd,
  margin: Global.marginLg,
  decoration: BoxDecoration(
    borderRadius: Global.borderMd,
    boxShadow: [Global.shadowSm],
  ),
  child: Text(
    Global.appName,
    style: TextStyle(fontSize: Global.fontXl),
  ),
)
```

### Spacing et tailles disponibles
- `Global.spacingXs` (4px) à `Global.spacingXxl` (48px)
- `Global.fontSm` (12px) à `Global.fontDisplay` (32px)
- `Global.radiusSm` à `Global.radiusXl`
- `Global.elevationSm` à `Global.elevationLg`

### Shortcuts disponibles
- `Global.padMd`, `Global.marginLg`, etc.
- `Global.borderSm`, `Global.gapXl`, etc.
- `Global.shadowSm`, `Global.shadowMd`, `Global.shadowLg`

## ✨ Avantages de cette structure

✅ **Organisation CSS-like** - Structure familière aux développeurs web
✅ **Séparation claire** - Styles vs constantes vs assets
✅ **Facile à maintenir** - Un seul fichier global.dart pour tous les styles
✅ **Performance optimisée** - Constantes compilées
✅ **Assets organisés** - Structure logique par type de ressource