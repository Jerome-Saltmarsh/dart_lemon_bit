
import 'package:lemon_math/Vector2.dart';

final _Atlas atlas = _Atlas();

const _shadesX = 1.0;
const _shadesY = 1.0;
const _pixelSize = 8.0;

class _Atlas {
  final shadow = Vector2(1, 34);
  final blood = Vector2(89, 25);
  final star = Vector2(560, 515);
  final starSize = Vector2(128, 128);
  final myst = Vector2(2410, 1);
  final circle = Vector2(2410, 513);
  final zombieY = 4532;
  final zombie = _Zombie();
  final particles = _Particles();
  final shades = _Shades();
  final tiles = Vector2(2,  2977);
  final rockWall = Vector2(2217, 1222);
  final human = _Human();
  final witch = _Witch();
  final archer = _Archer();
  final knight = _Knight();
  final projectiles = _Projectiles();
  final cloud = Vector2(2,  4044);
  final cloudSize = Vector2(43, 29);
  final fish = _Fish();
  final items = _Items();
  final parts = Vector2(0, 5385);
}

class _Items {
  final Vector2 handgun = Vector2(2,  567);
  final Vector2 shotgun = Vector2(2,  632);
  final Vector2 armour = Vector2(2,  1634);
  final Vector2 health = Vector2(2,  1698);
  final Vector2 crate = Vector2(2,  1763);
  final Vector2 emerald = Vector2(2, 1836);
  final Vector2 orbRed = Vector2(2, 1901);
  final Vector2 orbTopaz = Vector2(2, 1966);
}

class _Fish {
  final Vector2 swimming = Vector2(2,  1544);
}

class _Human {
  final _Unarmed unarmed = _Unarmed();
  final _Handgun handgun = _Handgun();
  final _Shotgun shotgun = _Shotgun();
  final Vector2 striking = Vector2(2, 196);
  final Vector2 changing = Vector2(2,  131);
  final Vector2 dying = Vector2(2,  1736);
}

class _Unarmed {
  final Vector2 idle = Vector2(1538, 1);
  final Vector2 running = Vector2(2,  391);
}

class _Handgun {
  final Vector2 idle = Vector2(1538, 65);
  final Vector2 running = Vector2(2,  521);
  final Vector2 firing = Vector2(2,  66);
}

class _Shotgun {
  final Vector2 idle = Vector2(1538, 130);
  final Vector2 running = Vector2(2,  456);
  final Vector2 firing = Vector2(2,  753);
}

class _Witch {
  final Vector2 idle = Vector2(2,  3459);
  final Vector2 running = Vector2(2,  3524);
  final Vector2 striking = Vector2(2,  3589);
}

class  _Archer {
  final Vector2 idle = Vector2(2,  3654);
  final Vector2 running = Vector2(2,  3719);
  final Vector2 firing = Vector2(2,  3784);
}

class _Knight {
  final Vector2 idle = Vector2(2,  3849);
  final Vector2 running = Vector2(2,  3914);
  final Vector2 striking = Vector2(2,  3979);
}

class _Zombie {
  final Vector2 striking = Vector2(2,  2463);
  final Vector2 idle  = Vector2(1026, 2463);
  final Vector2 running  = Vector2(2,  2720);
}

class _Projectiles {
  final _Item fireball = _Item(2324, 1193, 32, 4);
  final Vector2 arrow = Vector2(2297, 1308);
  final Vector2 arrowShadow = Vector2(2279, 1310);
}

class _Particles {
  final Vector2 blood = Vector2(2366, 633);
  final Vector2 zombieHead = Vector2(770, 3218);
  final Vector2 shell  = Vector2(2072, 1623);
  final Vector2 zombieArm  = Vector2(1052, 1479);
  final Vector2 zombieLeg  = Vector2(1539, 2463);
  final Vector2 zombieTorso  = Vector2(1538, 1736);
  final Vector2 circle32 = Vector2(2410, 515);
  final Vector2 flame  = Vector2(2290, 1193);
  final Vector2 circleBlackSmall  = Vector2(2316, 1193);
}

class _Shades {
  final double x = _shadesX;
  final double y = _shadesY;
  final Vector2 red1 = Vector2(_shadesX + (11 * _pixelSize), _shadesY + (3 * _pixelSize));
  final Vector2 white1 = Vector2(_shadesX + (9 * _pixelSize), _shadesY + (3 * _pixelSize));
  final Vector2 yellow1 = Vector2(_shadesX + (23 * _pixelSize), _shadesY + (3 * _pixelSize));
}

class _Item {
  final double x;
  final double y;
  final double size;
  final int frames;

  _Item(this.x, this.y, this.size, this.frames);
}