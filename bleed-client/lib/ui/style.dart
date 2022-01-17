

import 'package:golden_ratio/constants.dart';

final _Style style = _Style();

class _Style {
  final dialogTitleSize = 30;
  final buttonWidth = 200.0;
  get buttonHeight => style.buttonWidth * goldenRatio_0381;

  final dialogHeightMedium = 390.0;
  get dialogWidthMedium => style.dialogHeightMedium * goldenRatio_1381;

  get dialogHeightVerySmall => style.dialogHeightMedium * goldenRatio_0381;
  get dialogHeightSmall => style.dialogHeightMedium * goldenRatio_0618;
  get dialogWidthSmall => style.dialogWidthMedium * goldenRatio_0618;

  get dialogHeightLarge => style.dialogHeightMedium * goldenRatio_1381;
  get dialogWidthLarge => style.dialogWidthMedium * goldenRatio_1618;

  final _FontSize fontSize = _FontSize();
}

class _FontSize {
    final int large = 25;
    final int normal = 18;
    final int small = 15;
}