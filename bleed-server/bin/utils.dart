import 'classes.dart';
import 'classes/Block.dart';
import 'common/Tile.dart';
import 'common/classes/Vector2.dart';
import 'constants.dart';
import 'enums.dart';
import 'common/Weapons.dart';
import 'instances/settings.dart';
import 'maths.dart';
import 'settings.dart';

const double halfTileSize = 24;

double bulletDistanceTravelled(Bullet bullet) {
  return distance(bullet.x, bullet.y, bullet.xStart, bullet.yStart);
}

double clamp(double value, double min, double max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

int clampInt(int value, int min, int max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

void setDirection(Character character, Direction value) {
  if (value == Direction.None) return;
  if (character.firing) return;
  if (character.dead) return;
  character.direction = value;
}

bool withinViewRange(Npc npc, GameObject target) {
  return distanceBetween(npc, target) < zombieViewRange;
}

bool arrivedAtPath(Npc npc) {
  if (diff(npc.x, npc.path[0].x) > destinationArrivedDistance) return false;
  if (diff(npc.y, npc.path[0].y) > destinationArrivedDistance) return false;
  return true;
}

void setVelocity(GameObject gameObject, double rotation, double speed) {
  gameObject.xv = velX(rotation, speed);
  gameObject.yv = velY(rotation, speed);
}

double objectDistanceFrom(GameObject gameObject, double x, double y) {
  return distance(gameObject.x, gameObject.y, x, y);
}

void characterFace(Character character, double x, double y) {
  setDirection(
      character, convertAngleToDirection(radiansBetween2(character, x, y)));
}

void characterFaceObject(Character character, GameObject target) {
  characterFace(character, target.x, target.y);
}

double getShotAngle(Character character) {
  return character.aimAngle + giveOrTake(character.accuracy * 0.5);
}

void faceAimDirection(Character character) {
  setDirection(character, convertAngleToDirection(character.aimAngle));
}

Direction convertAngleToDirection(double angle) {
  if (angle < piEighth) {
    return Direction.Up;
  }
  if (angle < piEighth + (piQuarter)) {
    return Direction.UpRight;
  }
  if (angle < piEighth + (piQuarter * 2)) {
    return Direction.Right;
  }
  if (angle < piEighth + (piQuarter * 3)) {
    return Direction.DownRight;
  }
  if (angle < piEighth + (piQuarter * 4)) {
    return Direction.Down;
  }
  if (angle < piEighth + (piQuarter * 5)) {
    return Direction.DownLeft;
  }
  if (angle < piEighth + (piQuarter * 6)) {
    return Direction.Left;
  }
  if (angle < piEighth + (piQuarter * 7)) {
    return Direction.UpLeft;
  }
  return Direction.Up;
}

double tilesTopX = 0;
double tilesTopY = 0;
double tilesRightX = 0;
double tilesRightY = 0;
double tilesBottomX = 0;
double tilesBottomY = 0;
double tilesLeftX = 0;
double tilesLeftY = 0;

List<List<Tile>> generateTiles() {
  List<List<Tile>> tiles = [];
  for (int x = 0; x < tilesX; x++) {
    List<Tile> column = [];
    tiles.add(column);
    for (int y = 0; y < tilesY; y++) {
      column.add(Tile.Grass);
    }
  }
  tilesLeftX = -24 * tilesX.toDouble();
  tilesLeftY = 24 * tilesY.toDouble();
  tilesRightX = 24 * tilesX.toDouble();
  tilesRightY = 24 * tilesY.toDouble();
  tilesBottomY = 48 * tilesY.toDouble();
  return tiles;
}

double getWeaponDamage(Weapon weapon) {
  switch (weapon) {
    case Weapon.HandGun:
      return settingsWeaponDamageHandgun;
    case Weapon.Shotgun:
      return settingsWeaponDamageShotgun;
    case Weapon.SniperRifle:
      return settingsWeaponDamageSniperRifle;
    case Weapon.AssaultRifle:
      return settings.machineGunDamage;
    default:
      throw Exception("no range found for $weapon");
  }
}

double getWeaponRange(Weapon weapon) {
  switch (weapon) {
    case Weapon.HandGun:
      return settingsWeaponRangeHandgun;
    case Weapon.Shotgun:
      return settingsWeaponRangeShotgun;
    case Weapon.SniperRifle:
      return settingsWeaponRangeSniperRifle;
    case Weapon.AssaultRifle:
      return settings.machineGunRange;
    default:
      throw Exception("no range found for $weapon");
  }
}

double getWeaponBulletSpeed(Weapon weapon) {
  switch (weapon) {
    case Weapon.HandGun:
      return settingsWeaponBulletSpeedHandGun;
    case Weapon.Shotgun:
      return settingsWeaponBulletSpeedShotGun;
    case Weapon.SniperRifle:
      return settingsWeaponBulletSpeedSniperRifle;
    case Weapon.AssaultRifle:
      return settings.machineGunBulletSpeed;
    default:
      throw Exception("no range found for $weapon");
  }
}

void applyMovement(GameObject gameObject) {
  gameObject.x += gameObject.xv;
  gameObject.y += gameObject.yv;
  gameObject.z += gameObject.zv;
}

void applyFriction(GameObject gameObject, double value) {
  gameObject.xv *= value;
  gameObject.yv *= value;
}

bool npcWithinStrikeRange(Npc npc, GameObject target) {
  if (diff(npc.x, npc.target.x) > settingsZombieStrikeRange) return false;
  if (diff(npc.y, npc.target.y) > settingsZombieStrikeRange) return false;
  return true;
}

void sortBlocks(List<Block> blocks) {
  blocks.sort((a, b) => a.leftX < b.leftX ? -1 : 1);
}

Vector2 getTilePosition(int row, int column) {
  return Vector2(
      perspectiveProjectX(row * halfTileSize, column * halfTileSize),
      perspectiveProjectY(row * halfTileSize, column * halfTileSize) +
          halfTileSize);
}

double getTilePositionX(int row, int column){
  return perspectiveProjectX(row * halfTileSize, column * halfTileSize);
}

double getTilePositionY(int row, int column){
  return perspectiveProjectY(row * halfTileSize, column * halfTileSize) +
      halfTileSize;
}

double perspectiveProjectX(double x, double y) {
  return -y + x;
}

double perspectiveProjectY(double x, double y) {
  return x + y;
}
