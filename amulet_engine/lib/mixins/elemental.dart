
import 'package:amulet_engine/packages/isometric_engine/packages/lemon_math/src/functions/get_hue.dart';

mixin Elemental {
  // red
  var elementFire = 0;
  // green
  var elementElectricity = 0;
  // blue
  var elementWater = 0;

  int get r  => elementFire;
  int get g  => elementElectricity;
  int get b => elementWater;

  int get hue => getHue(
      r,
      g,
      b,
  );

  double get saturation => (r + g + b) / 100.0;



}