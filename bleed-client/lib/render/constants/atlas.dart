
import 'package:bleed_client/common/classes/Vector2.dart';

final _Atlas atlas = _Atlas();

const _shadesX = 1.0;
const _shadesY = 534.0;
const _pixelSize = 8.0;

class _Atlas {
  final Vector2 myst = Vector2(2410, 1);
  final Vector2 circle = Vector2(2410, 513);
  final _Zombie zombie = _Zombie();
  final _Particles particles = _Particles();
  final _Pixels pixels = _Pixels();
  final Vector2 tiles = Vector2(1, 2977);
  final _Human human = _Human();
  final Vector2 rockWall = Vector2(2217, 1222);
}

class _Human {
  final Vector2 striking = Vector2(631, 2977);
}

class _Zombie {
  final Vector2 striking = Vector2(1, 2463);
  final Vector2 idle  = Vector2(1026, 2463);
}

class _Particles {
  final Vector2 blood = Vector2(2366, 633);
  final Vector2 zombieHead = Vector2(2397, 633);
  final Vector2 shell  = Vector2(2072, 1623);
  final Vector2 zombieArm  = Vector2(1052, 1479);
  final Vector2 zombieLeg  = Vector2(1539, 2463);
  final Vector2 zombieTorso  = Vector2(1538, 1736);
  final Vector2 circle32 = Vector2(2410, 515);
}

class _Pixels {
  final double x = _shadesX;
  final double y = _shadesY;
  final Vector2 red1 = Vector2(_shadesX + (11 * _pixelSize), _shadesY + (3 * _pixelSize));
  final Vector2 white1 = Vector2(_shadesX + (9 * _pixelSize), _shadesY + (3 * _pixelSize));
  final Vector2 yellow1 = Vector2(_shadesX + (23 * _pixelSize), _shadesY + (3 * _pixelSize));
}