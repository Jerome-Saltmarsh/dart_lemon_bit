import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/common/functions/diff.dart';
import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/state.dart';

final double _light = 100;
final double _medium = 250;
final double _dark = 400;

Shading calculateShadeAt(double x, double y) {
  Shading shading = Shading.Dark;

  for (Character player in compiledGame.humans) {
    double xDiff = diff(x, player.x);
    if (xDiff > _dark) continue;
    double yDiff = diff(y, player.y);
    if (yDiff > _dark) continue;
    double total = xDiff + yDiff;

    if (total < _light) {
      return Shading.Bright;
    }
    if (total < _medium) {
      shading = Shading.Medium;
    }
  }
  return shading;
}
