
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/Vector2.dart';

import 'classes.dart';

final atlas = _Atlas();

const _shadesX = 1.0;
const _shadesY = 1.0;
const _pixelSize = 8.0;

const _healthX = 2400.0;
const _healthY = 0.0;
const _healthBackgroundY = _healthY + _healthHeight;
const _healthWidth = 40.0;
const _healthWidthHalf = _healthWidth * 0.5;
const _healthHeight = 8.0;
const _healthAnchorY = 50.0;

void renderCharacterHealthBar(Character character){
  engine.mapSrc(x: _healthX, y: _healthBackgroundY, width: _healthWidth, height: 6);
  engine.mapDst(x: character.x, y: character.y, anchorX: _healthWidthHalf, anchorY: _healthAnchorY);
  engine.renderAtlas();
  engine.mapSrc(x: _healthX, y: _healthY, width: _healthWidth * character.health, height: 6);
  engine.mapDst(x: character.x, y: character.y, anchorX: _healthWidthHalf, anchorY: _healthAnchorY);
  engine.renderAtlas();
}

class _Atlas {
  final shadow = Vector2(1, 34);
  final blood = Vector2(89, 25);
  final myst = Vector2(5488, 1);
  final circle = Vector2(2410, 513);
  final particles = _Particles();
  final shades = _Shades();
  final tiles = Vector2(4543,  1);
  final rockWall = Vector2(1265, 1);
  final blockGrass = Vector2(5981.0, 0);
  final witch = _Witch();
  final archer = _Archer();
  final knight = _Knight();
  final projectiles = _Projectiles();
  final cloud = Vector2(2,  4044);
  final cloudSize = Vector2(43, 29);
  final items = _Items();
  final parts = Vector2(0, 5385);
  final orbRuby = Vector2(2306, 0);
  final orbEmerald = Vector2(2306 + 24, 0);
  final orbTopaz = Vector2(2306 + 48, 0);
}

class _Items {
  final handgun = Vector2(2,  567);
  final shotgun = Vector2(2,  632);
  final armour = Vector2(2,  1634);
  final health = Vector2(2,  1698);
  final crate = Vector2(2,  1763);
  final emerald = Vector2(2, 1836);
  final orbRed = Vector2(2, 1901);
  final orbTopaz = Vector2(2, 1966);
}

class _Witch {
  final idle = Vector2(2,  3459);
  final running = Vector2(2,  3524);
  final striking = Vector2(2,  3589);
}

class  _Archer {
  final idle = Vector2(2,  3654);
  final running = Vector2(2,  3719);
  final firing = Vector2(2,  3784);
}

class _Knight {
  final idle = Vector2(2,  3849);
  final running = Vector2(2,  3914);
  final striking = Vector2(2,  3979);
}

class _Projectiles {
  final fireball = _Item(975, 1, 32, 4);
  final arrow = Vector2(2182, 1);
  final arrowShadow = Vector2(2172, 1 );
}

class _Particles {
  final shell  = Vector2(1008, 0);
  final zombieHead = Vector2(4030, 0);
  final zombieLeg  = Vector2(2491, 1);
  final zombieArm  = Vector2(3004, 1);
  final zombieTorso  = Vector2(3517 , 1);
  final circle32 = Vector2(2410, 515);
  final flame  = Vector2(2290, 1193);
  final circleBlackSmall  = Vector2(2316, 1193);
}

class _Shades {
  final x = _shadesX;
  final y = _shadesY;
  final red1 = Vector2(_shadesX + (11 * _pixelSize), _shadesY + (3 * _pixelSize));
  final white1 = Vector2(_shadesX + (9 * _pixelSize), _shadesY + (3 * _pixelSize));
  final yellow1 = Vector2(_shadesX + (23 * _pixelSize), _shadesY + (3 * _pixelSize));
}

class _Item {
  final double x;
  final double y;
  final double size;
  final int frames;

  _Item(this.x, this.y, this.size, this.frames);
}