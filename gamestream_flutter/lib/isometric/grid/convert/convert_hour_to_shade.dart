import 'package:bleed_common/Shade.dart';

int convertHourToShade(int hour){
  if (hour < 2) return Shade.Pitch_Black;
  if (hour < 3) return Shade.Very_Dark;
  if (hour < 5) return Shade.Dark;
  if (hour < 7) return Shade.Medium;
  if (hour < 9) return Shade.Bright;
  if (hour < 16) return Shade.Very_Bright;
  if (hour < 18) return Shade.Bright;
  if (hour < 20) return Shade.Medium;
  if (hour < 21) return Shade.Dark;
  if (hour < 23) return Shade.Very_Dark;
  return Shade.Pitch_Black;
}
