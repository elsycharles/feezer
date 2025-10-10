import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Validation helpers for form fields
class ValidationUtil {
  ValidationUtil._(); // Private constructor

  /// Validates required fields
  static String? required(
    String? value,
    BuildContext context, [
    String? fieldName,
  ]) {
    if (value?.trim().isEmpty != true) return null;

    if (fieldName != null) {
      return AppLocalizations.of(context).fieldIsRequired(fieldName);
    }
    return AppLocalizations.of(context).thisFieldIsRequired;
  }

  /// Validates email format (deprecated - app has no email fields)
  static String? email(String? value, BuildContext context) {
    if (value?.trim().isEmpty == true) {
      return AppLocalizations.of(context).thisFieldIsRequired;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(value!)
        ? null
        : AppLocalizations.of(context).enterValidNumber;
  }

  /// Validates minimum length
  static String? minLength(String? value, int minLength, BuildContext context) {
    if (value?.trim().isEmpty == true) {
      return AppLocalizations.of(context).thisFieldIsRequired;
    }

    return value!.trim().length >= minLength
        ? null
        : AppLocalizations.of(context).mustBeAtLeastNCharacters(minLength);
  }

  /// Validates maximum length
  static String? maxLength(String? value, int maxLength, BuildContext context) {
    if (value?.trim().isEmpty == true) return null; // Allow empty

    return value!.trim().length <= maxLength
        ? null
        : AppLocalizations.of(context).mustBeLessThanNCharacters(maxLength);
  }

  /// Validates numeric values
  static String? numeric(
    String? value,
    BuildContext context, [
    String? fieldName,
  ]) {
    if (value?.trim().isEmpty == true) {
      if (fieldName != null) {
        return AppLocalizations.of(context).fieldIsRequired(fieldName);
      }
      return AppLocalizations.of(context).thisFieldIsRequired;
    }

    return double.tryParse(value!) != null
        ? null
        : AppLocalizations.of(context).enterValidNumber;
  }

  /// Validates positive numbers
  static String? positiveNumber(
    String? value,
    BuildContext context, [
    String? fieldName,
  ]) {
    final numericResult = numeric(value, context, fieldName);
    if (numericResult != null) return numericResult;

    final number = double.parse(value!);
    return number > 0
        ? null
        : AppLocalizations.of(context).mustBeGreaterThanZero;
  }

  /// Validates non-negative numbers (allows 0)
  static String? nonNegativeNumber(
    String? value,
    BuildContext context, [
    String? fieldName,
  ]) {
    final numericResult = numeric(value, context, fieldName);
    if (numericResult != null) return numericResult;

    final number = double.parse(value!);
    return number >= 0
        ? null
        : AppLocalizations.of(context).mustBeGreaterThanZero;
  }

  /// Combines multiple validators
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) => (value) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) return result;
    }
    return null;
  };
}
