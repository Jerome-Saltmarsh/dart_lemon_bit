

import 'package:golden_ratio/constants.dart';

final _Style style = _Style();

class _Style {
  final dialogTitleSize = 30;
  final buttonWidth = 200.0;
  get buttonHeight => style.buttonWidth * goldenRatio_0381;

  final dialogMediumHeight = 400.0;
  get dialogMediumWidth => style.dialogMediumHeight * goldenRatio_1381;

  get dialogSmallHeight => style.dialogMediumHeight * goldenRatio_0618;
  get dialogSmallWidth => style.dialogMediumWidth * goldenRatio_0618;
}