import 'package:bleed_common/Shade.dart';
import 'package:lemon_math/library.dart';

int convertDistanceToShade(int distance, {
  int maxBrightness = Shade.Very_Bright
}) =>
    clamp(distance - 1, maxBrightness, Shade.Pitch_Black);

