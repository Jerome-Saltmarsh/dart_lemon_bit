
import 'package:lemon_math/Vector2.dart';

final _Atlas atlas = _Atlas();

const _shadesX = 1.0;
const _shadesY = 534.0;
const _pixelSize = 8.0;

class _Atlas {
  final Vector2 star = Vector2(560, 515);
  final Vector2 starSize = Vector2(128, 128);
  final Vector2 myst = Vector2(2410, 1);
  final Vector2  circle = Vector2(2410, 513);
  final _Zombie zombie = _Zombie();
  final _Particles particles = _Particles();
  final _Pixels pixels = _Pixels();
  final Vector2 tiles = Vector2(1, 2977);
  final Vector2 rockWall = Vector2(2217, 1222);
  final Vector2 arrow = Vector2(517, 534);
  final _Human human = _Human();
  final _Witch witch = _Witch();
  final _Archer archer = _Archer();
  final _Knight knight = _Knight();
  final _Projectiles projectiles = _Projectiles();

  final Vector2 cloud = Vector2(1, 4044);
  final Vector2 cloudSize = Vector2(43, 29);
  final _Fish fish = _Fish();

  final _Items items = _Items();
}

class _Items {
  final Vector2 handgun = Vector2(1, 567);
  final Vector2 shotgun = Vector2(1, 632);
  final Vector2 armour = Vector2(1, 1634);
  final Vector2 health = Vector2(1, 1698);
  final Vector2 crate = Vector2(1, 1763);
  final Vector2 emerald = Vector2(2, 1836);
  final Vector2 orbRed = Vector2(2, 1901);
  final Vector2 orbTopaz = Vector2(2, 1966);
}

class _Fish {
  final Vector2 swimming = Vector2(1, 1544);
}

class _Human {
  final _Unarmed unarmed = _Unarmed();
  final _Handgun handgun = _Handgun();
  final _Shotgun shotgun = _Shotgun();
  final Vector2 striking = Vector2(631, 2977);
  final Vector2 firingBow = Vector2(1, 3218);
  final Vector2 changing = Vector2(1, 1479);
  final Vector2 dying = Vector2(1, 1736);
  final Vector2 punching  = Vector2(1, 66);

}

class _Unarmed {
  final Vector2 idle = Vector2(1538, 1);
  final Vector2 running = Vector2(0, 2206);
}

class _Handgun {
  final Vector2 idle = Vector2(1538, 66);
  final Vector2 walking = Vector2(1, 195);
  final Vector2 firing = Vector2(1, 66 );
}

class _Shotgun {
  final Vector2 idle = Vector2(1538, 130);
  final Vector2 walking = Vector2(1, 260);
  final Vector2 firing = Vector2(1, 1);
}

class  _Witch {
  final Vector2 idle = Vector2(1, 3459);
  final Vector2 running = Vector2(1, 3524);
  final Vector2 striking = Vector2(1, 3589);
}

class  _Archer {
  final Vector2 idle = Vector2(1, 3654);
  final Vector2 running = Vector2(1, 3719);
  final Vector2 firing = Vector2(1, 3784);
}

class  _Knight {
  final Vector2 idle = Vector2(1, 3849);
  final Vector2 running = Vector2(1, 3914);
  final Vector2 striking = Vector2(1, 3979);
}

class _Zombie {
  final Vector2 striking = Vector2(1, 2463);
  final Vector2 idle  = Vector2(1026, 2463);
  final Vector2 running  = Vector2(1, 2720);
}

class _Projectiles {
  final _Item fireball = _Item(2324, 1193, 32, 4);
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

class _Pixels {
  final double x = 1 ;
  final double y = 534;
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