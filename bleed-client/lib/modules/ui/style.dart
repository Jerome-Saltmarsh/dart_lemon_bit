
import 'package:golden_ratio/constants.dart';

class UIStyle {
  final layoutPadding = 16.0;
  final font = _FontSize();
}

class _FontSize {
  get veryLarge => large * goldenRatio_1381;
  get large => regular * goldenRatio_1381;
  final regular = 18.0;
  get small => regular * goldenRatio_0618;
  get verySmall => regular * goldenRatio_0381;
}