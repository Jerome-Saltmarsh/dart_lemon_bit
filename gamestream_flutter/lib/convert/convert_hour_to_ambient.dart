import 'package:bleed_common/Shade.dart';

int convertHourToAmbient(int hour){
   if (hour < 2) return Shade.Pitch_Black;
   if (hour < 3) return Shade.Very_Dark;
   if (hour < 4) return Shade.Dark;
   if (hour < 6) return Shade.Medium;
   if (hour < 9) return Shade.Bright;
   if (hour < 15) return Shade.Very_Bright;
   if (hour < 15) return Shade.Bright;
   if (hour < 18) return Shade.Medium;
   if (hour < 20) return Shade.Dark;
   if (hour < 23) return Shade.Very_Dark;
   return Shade.Pitch_Black;
}