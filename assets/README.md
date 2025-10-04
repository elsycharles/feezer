# Assets Directory

This directory contains all the assets for the Fee Minimizer Flutter application.

## Structure

```
assets/
├── images/          # Application images (logos, backgrounds, etc.)
├── icons/           # Custom icons and graphics
└── fonts/           # Custom fonts (if any)
```

## Usage

### Images
Place your images in the `images/` directory. Examples:
- `assets/images/logo.png`
- `assets/images/splash_logo.png`
- `assets/images/background.jpg`

### Icons
Place custom icons in the `icons/` directory. Examples:
- `assets/icons/custom_icon.svg`
- `assets/icons/fee_icon.png`

### Fonts
Place custom fonts in the `fonts/` directory and configure them in `pubspec.yaml`. Examples:
- `assets/fonts/CustomFont-Regular.ttf`
- `assets/fonts/CustomFont-Bold.ttf`

## Adding New Assets

1. Place your asset files in the appropriate directory
2. The `pubspec.yaml` is already configured to include all files from `assets/images/` and `assets/icons/`
3. For fonts, uncomment and configure the fonts section in `pubspec.yaml`
4. Run `flutter pub get` after adding new assets
5. Use `flutter analyze` to check for any issues

## Asset Usage in Code

```dart
// Images
Image.asset('assets/images/logo.png')

// Icons (for PNG/JPG icons)
Image.asset('assets/icons/custom_icon.png')

// For SVG icons, you'll need to add flutter_svg dependency
```