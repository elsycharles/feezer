/// Validation helpers for form fields
class ValidationUtil {
  ValidationUtil._(); // Private constructor

  /// Validates required fields
  static String? required(String? value, [String? fieldName]) =>
      value?.trim().isEmpty == true 
          ? '${fieldName ?? 'This field'} is required' 
          : null;

  /// Validates email format
  static String? email(String? value) {
    if (value?.trim().isEmpty == true) return 'Email is required';
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(value!) ? null : 'Enter a valid email';
  }

  /// Validates minimum length
  static String? minLength(String? value, int minLength) {
    if (value?.trim().isEmpty == true) return 'This field is required';
    
    return value!.trim().length >= minLength 
        ? null 
        : 'Must be at least $minLength characters';
  }

  /// Validates maximum length
  static String? maxLength(String? value, int maxLength) {
    if (value?.trim().isEmpty == true) return null; // Allow empty
    
    return value!.trim().length <= maxLength 
        ? null 
        : 'Must be less than $maxLength characters';
  }

  /// Validates numeric values
  static String? numeric(String? value, [String? fieldName]) {
    if (value?.trim().isEmpty == true) {
      return '${fieldName ?? 'This field'} is required';
    }
    
    return double.tryParse(value!) != null 
        ? null 
        : 'Enter a valid number';
  }

  /// Validates positive numbers
  static String? positiveNumber(String? value, [String? fieldName]) {
    final numericResult = numeric(value, fieldName);
    if (numericResult != null) return numericResult;
    
    final number = double.parse(value!);
    return number > 0 ? null : 'Must be greater than 0';
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