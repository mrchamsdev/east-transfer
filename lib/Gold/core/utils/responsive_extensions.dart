import 'screen_utility.dart';

extension ResponsiveNum on num {
  /// Percentage of screen width. e.g. 5.w → 5% of screenWidth
  double get w => ScreenUtility.screenWidth * (toDouble() / 100);

  /// Percentage of screen height. e.g. 10.h → 10% of screenHeight
  double get h => ScreenUtility.screenHeight * (toDouble() / 100);

  /// Radius scaled to screen width. e.g. 8.r → 8 / 375 * screenWidth
  double get r => ScreenUtility.screenWidth * (toDouble() / 375);

  /// Font size scaled to screen width. e.g. 14.sp → 14 / 375 * screenWidth
  double get sp => ScreenUtility.screenWidth * (toDouble() / 375);
}
