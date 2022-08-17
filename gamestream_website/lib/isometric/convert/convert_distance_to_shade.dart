import 'package:lemon_math/library.dart';
import 'package:bleed_common/Shade.dart';

int convertDistanceToShade(int distance, {int maxBrightness = Shade.Very_Bright}){
  // if (distance > Shade.Pitch_Black + 2) {
  //   return Shade.Pitch_Black;
  // }
  // return clamp(distance - 1, maxBrightness, Shade.Very_Dark);
  return clamp(distance - 1, maxBrightness, Shade.Pitch_Black);
}

