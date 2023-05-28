

import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/lemon_engine.dart';

final style = _Style();


class _Style {
  final buttonWidth = 200.0;
  get buttonHeight => style.buttonWidth * goldenRatio_0381;
  final dialogHeightMedium = 390.0;
  get dialogWidthMedium => style.dialogHeightMedium * goldenRatio_1381;
  get dialogHeightVerySmall => style.dialogHeightMedium * goldenRatio_0381;
  get dialogHeightSmall => style.dialogHeightMedium * goldenRatio_0618;
  get dialogWidthSmall => style.dialogWidthMedium * goldenRatio_0618;
  get dialogHeightLarge => style.dialogHeightMedium * goldenRatio_1381;
  get dialogWidthLarge => style.dialogWidthMedium * goldenRatio_1618;
}

class FontSize {
  static const VerySmall = Regular * Engine.GoldenRatio_0_381;
  static const Small = Regular * Engine.GoldenRatio_0_618;
  static const Regular = 18.0;
  static const Large = Regular * Engine.GoldenRatio_1_381;
  static const VeryLarge = Large * Engine.GoldenRatio_1_618;
}