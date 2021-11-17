import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/state/game.dart';
import 'package:lemon_math/diff.dart';

final double _light = 100;
final double _medium = 250;
final double _dark = 400;

Shade calculateShadeAt(double x, double y) {
  Shade shading = Shade.Dark;

  for (Character player in game.humans) {
    double xDiff = diff(x, player.x);
    if (xDiff > _dark) continue;
    double yDiff = diff(y, player.y);
    if (yDiff > _dark) continue;
    double total = xDiff + yDiff;

    if (total < _light) {
      return Shade.Bright;
    }
    if (total < _medium) {
      shading = Shade.Medium;
    }
  }
  return shading;
}
