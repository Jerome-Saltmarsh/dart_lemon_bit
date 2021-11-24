
import 'package:bleed_client/common/classes/Vector2.dart';

final _Atlas atlas = _Atlas();

class _Atlas {
  final Vector2 myst = Vector2(2410, 1);
  final Vector2 circle = Vector2(2410, 513);
  final _Zombie zombie = _Zombie();
  final _Particles particles = _Particles();
}

class _Zombie {
  final Vector2 striking = Vector2(1, 2463);
  final Vector2 idle  = Vector2(1026, 2463);
}

class _Particles {
  final Vector2 blood = Vector2(2366, 633);
  final Vector2 zombieHead = Vector2(2397, 633);
  final Vector2 shell  = Vector2(2228, 1199);
  final Vector2 zombieArm  = Vector2(1052, 1479);
  final Vector2 zombieLeg  = Vector2(1539, 2463);
  final Vector2 zombieTorso  = Vector2(1538, 1736);
  final Vector2 circle32 = Vector2(2410, 515);
}