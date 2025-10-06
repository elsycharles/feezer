/// Immutable onboarding item model
class OnboardingItem {
  const OnboardingItem({
    required this.title,
    required this.description,
    required this.imagePath,
  });

  final String title;
  final String description;
  final String imagePath;

  /// Creates a copy with updated values
  OnboardingItem copyWith({
    String? title,
    String? description,
    String? imagePath,
  }) => OnboardingItem(
    title: title ?? this.title,
    description: description ?? this.description,
    imagePath: imagePath ?? this.imagePath,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingItem &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          description == other.description &&
          imagePath == other.imagePath;

  @override
  int get hashCode => Object.hash(title, description, imagePath);

  @override
  String toString() => 'OnboardingItem(title: $title)';
}
