import 'package:lemon_math/golden_ratio.dart';

final _Style style = _Style();

const _buttonWidth = 190.0;

class _Style {
  final buttonWidth = _buttonWidth;
  final buttonHeight = _buttonWidth * goldenRatioInverseB;
}