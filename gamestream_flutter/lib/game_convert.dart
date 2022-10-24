
import 'package:bleed_common/library.dart';
import 'package:lemon_engine/engine.dart';

class GameConvert {
  static int distanceToShade(int distance, {
    int maxBrightness = Shade.Very_Bright
  }) =>
      Engine.clamp(distance - 1, maxBrightness, Shade.Pitch_Black);
}