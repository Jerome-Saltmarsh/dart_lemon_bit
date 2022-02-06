
import 'package:lemon_math/Vector2.dart';

final _Atlas atlas = _Atlas();

const _shadesX = 1.0;
const _shadesY = 1.0;
const _pixelSize = 8.0;

class _Atlas {
  final Vector2 star = Vector2(560, 515);
  final Vector2 starSize = Vector2(128, 128);
  final Vector2 myst = Vector2(2410, 1);
  final Vector2  circle = Vector2(2410, 513);
  final _Zombie zombie = _Zombie();
  final _Particles particles = _Particles();
  final _Shades shades = _Shades();
  final Vector2 tiles = Vector2(2,  2977);
  final Vector2 rockWall = Vector2(2217, 1222);
  final _Human human = _Human();
  final _Witch witch = _Witch();
  final _Archer archer = _Archer();
  final _Knight knight = _Knight();
  final _Projectiles projectiles = _Projectiles();
  final Vector2 cloud = Vector2(2,  4044);
  final Vector2 cloudSize = Vector2(43, 29);
  final _Fish fish = _Fish();

  final _Plain plain = _Plain();


  final _Items items = _Items();
  final _Weapons weapons = _Weapons();
}

class _Plain {
  final torso = _PlainTorso();
  final legs = _PlainLegs();
  final head = _PlainHead();
}

class _PlainLegs {
  final Vector2 idle = Vector2(0,  4345);
  final Vector2 running = Vector2(0,  4410);
}

class _PlainTorso {
  final Vector2 idle = Vector2(0,  4085);
  final Vector2 running = Vector2(0,  4150 );
  final Vector2 striking = Vector2(0,  4215);
  final Vector2 changing = Vector2(0,  4280);
}

class _PlainHead {
  final Vector2 idle = Vector2(0,  4475);
  final Vector2 running  = Vector2(0,  4540);
  final Vector2 striking  = Vector2(0,  4605);
}

class _Weapons {
  final _SwordSteel swordSteel = _SwordSteel();
  final _SwordWooden swordWooden = _SwordWooden();
  final _BowWooden bowWooden = _BowWooden();
}

class _SwordSteel {
  final Vector2 idle = Vector2(2,  883);
  final Vector2 striking = Vector2(515,  883);
  final Vector2 running = Vector2(2,  1013);
}

class _BowWooden {
  final Vector2 idle = Vector2(2, 1143);
  final Vector2 firing = Vector2(2, 1208);
  final Vector2 running = Vector2(2, 1273 );
}

class _SwordWooden {
  final Vector2 idle = Vector2(2, 948);
  final Vector2 striking = Vector2(515, 948);
  final Vector2 running = Vector2(1, 1078);
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

class  _Witch {
  final Vector2 idle = Vector2(2,  3459);
  final Vector2 running = Vector2(2,  3524);
  final Vector2 striking = Vector2(2,  3589);
}

class  _Archer {
  final Vector2 idle = Vector2(2,  3654);
  final Vector2 running = Vector2(2,  3719);
  final Vector2 firing = Vector2(2,  3784);
}

class  _Knight {
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
  final Vector2 arrow = Vector2(2295, 1306);
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