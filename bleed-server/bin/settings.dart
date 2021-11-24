
import '../bin/common/Weapons.dart';
import 'maths.dart';

Settings settings = Settings();

_Radius get radius => settings.radius;

_CoolDown get coolDown => settings.coolDown;

_Accuracy get _accuracy => settings.accuracy;

_Damage get _damage => settings.damage;

_Range get _range => settings.range;

_BulletSpeed _bulletSpeed = settings.bulletSpeed;

double getBulletSpeed(Weapon weapon) {
  switch (weapon) {
    case Weapon.HandGun:
      return _bulletSpeed.handgun;
    case Weapon.Shotgun:
      return _bulletSpeed.shotgun;
    case Weapon.SniperRifle:
      return _bulletSpeed.sniperRifle;
    case Weapon.AssaultRifle:
      return _bulletSpeed.assaultRifle;
    default:
      throw Exception("no range found for $weapon");
  }
}

double getWeaponAccuracy(Weapon weapon){
  switch (weapon){
    case Weapon.HandGun:
      return _accuracy.handgun;
    case Weapon.Shotgun:
      return _accuracy.shotgun;
    case Weapon.SniperRifle:
      return _accuracy.sniperRifle;
    case Weapon.AssaultRifle:
      return _accuracy.assaultRifle;
    default:
      throw Exception("No accuracy found for $weapon");
  }
}

int getWeaponDamage(Weapon weapon){
  switch (weapon){
    case Weapon.HandGun:
      return _damage.handgun;
    case Weapon.Shotgun:
      return _damage.shotgun;
    case Weapon.SniperRifle:
      return _damage.sniperRifle;
    case Weapon.AssaultRifle:
      return _damage.assaultRifle;
    default:
      throw Exception("No accuracy found for $weapon");
  }
}

double getWeaponRange(Weapon weapon) {
  switch (weapon) {
    case Weapon.HandGun:
      return _range.handgun;
    case Weapon.Shotgun:
      return _range.shotgun;
    case Weapon.SniperRifle:
      return _range.sniperRifle;
    case Weapon.AssaultRifle:
      return _range.assaultRifle;
    default:
      throw Exception("no range found for $weapon");
  }
}

class Settings {
  final host = '0.0.0.0';
  final port = 8080;

  final _Radius radius = _Radius();
  final _Accuracy accuracy = _Accuracy();
  final _CoolDown coolDown = _CoolDown();
  final _Damage damage = _Damage();
  final _Range range = _Range();
  final _Health health = _Health();
  final _BulletSpeed bulletSpeed = _BulletSpeed();
  final _Duration duration = _Duration();
  final _NpcSettings npc = _NpcSettings();
  final _MaxClips maxClips = _MaxClips();
  final _Pickup pickup = _Pickup();
  final _ReloadDuration reloadDuration = _ReloadDuration();
  final _PointsEarned pointsEarned = _PointsEarned();
  final double zombieSpeed = 2;
  final double playerSpeed = 2.75;
  final double machineGunBulletSpeed = 18;
  final int crateDeactiveDuration = 1000;
  final double knifeHitAcceleration = 5;
  final double itemCollectRadius = 10;
  final double chanceOfDropItem = goldenRatioInverse;
  final int itemDuration = 500;
  final double grenadeGravity = 0.06;
  final int maxZombies = 2500;
  final int deathMatchMaxPlayers = 32;
  final int itemReactivationInSeconds = 60;
  final int maxGrenades = 3;
  final int maxMeds = 3;
  final int collectCreditAmount = 25;
  final int staminaRefreshRate = 2;
  final int gameStartingCountDown = 400;
  final int casualGameMaxPlayers = 16;

  final int playerDisconnectFrames = 300;

  final double minVelocity = 0.005;
  final double velocityFriction = 0.88;
  final double zombieChaseRange = 600;
  final double npcChaseRange = 600;
  final double weaponRangeVariation = 10.0;
  final double playerStartRadius = 50;

  final int shotgunBulletsPerShot = 5;
  final double particleShellSpeed = 3;
  final double bulletImpactVelocityTransfer = 0.25;

  final int generateTilesX = 32;
  final int generateTilesY = 32;

  final int grenadeDuration = 800;
  final double grenadeExplosionRadius = 75;
  final double grenadeSpeed = 18;
  final double grenadeFriction = 0.98;

  final double minStamina = 60;

}

class _Duration {
  final int knifeStrike = 15;
}

class _Pickup {
  final int handgun = 10;
  final int shotgun = 5;
  final int sniperRifle = 5;
  final int assaultRifle = 15;
}

class _MaxClips {
  final int handgun = 3;
  final int shotgun = 3;
  final int sniperRifle = 3;
  final int assaultRifle = 3;
}

class _ReloadDuration {
  final int handgun = 20;
  final int shotgun = 20;
  final int sniperRifle = 20;
  final int assaultRifle = 20;
}

class _PointsEarned {
  final int zombieKilled = 5;
  final int zombieHit = 1;
  final int playerKilled = 20;
}

class _Radius {
  final double spawnPoint = 20;
  final double item = 15;
  final double crate = 22;
  final double character = 20;
  final double interact = 60;
  final double zombieSpawnVariation = 5;
}

class _Accuracy {
  final double handgun = 0.05;
  final double sniperRifle = 0;
  final double shotgun = 0.15;
  final double assaultRifle = 0.1;
}

class _CoolDown {
  final int handgun = 14;
  final int shotgun = 30;
  final int sniperRifle = 45;
  final int assaultRifle = 5;
  final int clipEmpty = 14;
}

class _Damage {
  final int knife = 12;
  final int zombieStrike = 7;
  final int grenade = 15;
  final int handgun = 10;
  final int shotgun = 8;
  final int sniperRifle = 35;
  final int assaultRifle = 8;
}

class _Range {
  final double knife = 15;
  final double handgun = 320;
  final double shotgun = 180;
  final double sniperRifle = 600;
  final double assaultRifle = 450;
  final double zombieStrike = 20;
}

class _BulletSpeed {
  final double fireball = 4.0;
  final double handgun = 12.0;
  final double shotgun = 12.0;
  final double sniperRifle = 28;
  final double assaultRifle = 18;
}

class _NpcSettings {
  final double destinationRadius = 15.0;
  final double viewRange = 300;
}

class _Health {
  final int player = 100;
  final int zombie = 25;
}

