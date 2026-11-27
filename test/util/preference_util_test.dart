import 'package:feezer/util/preference_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'amounts are rounded to the hundred by default, until turned off',
    () async {
      SharedPreferences.setMockInitialValues({});
      expect(await PreferenceUtil.amountStep(withdrawal: true), 100);
      expect(await PreferenceUtil.amountStep(withdrawal: false), 100);

      await PreferenceUtil.setAmountStep(0, withdrawal: false);
      expect(await PreferenceUtil.amountStep(withdrawal: false), 0);
      expect(await PreferenceUtil.amountStep(withdrawal: true), 100);
    },
  );
}
