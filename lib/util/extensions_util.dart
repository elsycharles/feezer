import 'package:flutter/material.dart';

/// Extensions for BuildContext to simplify common operations
extension BuildContextExtensions on BuildContext {
  /// Quick access to ThemeData
  ThemeData get theme => Theme.of(this);

  /// Quick access to ColorScheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Quick access to TextTheme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Quick access to MediaQuery
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Quick access to screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Quick access to screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Quick access to screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Check if keyboard is visible
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;

  /// Pop current route using Navigator
  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  /// Push new route using Navigator path
  Future<T?> push<T>(String path, {Object? extra}) => Navigator.of(this).pushNamed<T>(path, arguments: extra);
}

/// Extensions for String to simplify common operations
extension StringExtensions on String {
  /// Check if string is empty or null
  bool get isNullOrEmpty => trim().isEmpty;

  /// Capitalize first letter
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';

  /// Truncate string with ellipsis
  String truncate(int length) =>
      this.length <= length ? this : '${substring(0, length)}...';
}

/// Extensions for Widget to simplify common operations
extension WidgetExtensions on Widget {
  /// Add padding to widget
  Widget padding(EdgeInsetsGeometry padding) =>
      Padding(padding: padding, child: this);

  /// Add margin to widget using Container
  Widget margin(EdgeInsetsGeometry margin) =>
      Container(margin: margin, child: this);

  /// Center widget
  Widget get center => Center(child: this);

  /// Expand widget
  Widget get expanded => Expanded(child: this);

  /// Add flex to widget
  Widget flex(int flex) => Expanded(flex: flex, child: this);

  /// Add visibility to widget
  Widget visible(bool visible) => Visibility(visible: visible, child: this);

  /// Add opacity to widget
  Widget opacity(double opacity) => Opacity(opacity: opacity, child: this);
}

/// Extensions for List of Widget to simplify common operations
extension WidgetListExtensions on List<Widget> {
  /// Add gaps between widgets
  List<Widget> separated(Widget separator) {
    if (isEmpty) return this;

    final result = <Widget>[];
    for (int i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) {
        result.add(separator);
      }
    }
    return result;
  }

  /// Convert to Column
  Widget get column => Column(children: this);

  /// Convert to Row
  Widget get row => Row(children: this);

  /// Convert to Wrap
  Widget get wrap => Wrap(children: this);
}
