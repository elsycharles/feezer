import 'package:fee_minimizer/model/onboarding_model.dart';

class OnboardingUtil {
  static const List<OnboardingItem> items = [
    OnboardingItem(
      title: 'Plan ahead and save on fees',
      description: 'Calculate the most cost-efficient way to handle your money.',
      imagePath: 'assets/images/onboarding_1.png',
    ),
    OnboardingItem(
      title: 'Optimize your transactions',
      description: 'Minimize fees automatically based on predefined intervals.',
      imagePath: 'assets/images/onboarding_2.png',
    ),
    OnboardingItem(
      title: 'Save smart, spend better',
      description: 'Get personalized recommendations and make informed financial decisions instantly.',
      imagePath: 'assets/images/onboarding_3.png',
    ),
  ];
}