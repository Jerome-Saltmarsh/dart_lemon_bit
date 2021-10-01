class Settings {
  final Radius radius = Radius();
  final Accuracy accuracy = Accuracy();
  final CoolDown coolDown = CoolDown();
  final double machineGunRange = 400;
  final int machineGunDamage = 1;
  final double machineGunBulletSpeed = 18;

  final int crateDeactiveDuration = 1000;

  final double knifeRange = 15;
  final double knifeHitAcceleration = 5;
  final int knifeDamage = 1;
  final double characterRadius = 20;
  final int knifeAttackDuration = 15;
  final double itemCollectRadius = 10;

  final double chanceOfDropItem = 0.25;
  final int itemDuration = 500;

  final _ClipSize clipSize = _ClipSize();
  final _MaxClips maxClips = _MaxClips();
  final _Pickup pickup = _Pickup();

  final _ReloadDuration reloadDuration = _ReloadDuration();
  final _PointsEarned pointsEarned = _PointsEarned();

  final double grenadeGravity = 0.06;

  final int maxZombies = 2500;
  final int deathMatchMaxPlayers = 32;
  final int itemReactivationInSeconds = 60;
  final int maxGrenades = 3;
  final int maxMeds = 3;
  final int collectCreditAmount = 25;
  final int staminaRefreshRate = 2;
  final int gameStartingCountDown = 400;

  final int playerDisconnectFrames = 300;
}

class _ClipSize {
  final int handgun = 50;
  final int shotgun = 20;
  final int sniperRifle = 15;
  final int assaultRifle = 175;
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

class Radius {
  final double item = 15;
  final double crate = 22;
}

class Accuracy {
  final double handgun = 0.05;
  final double sniperRifle = 0;
  final double shotgun = 0.15;
  final double assaultRifle = 0.1;
}

class CoolDown {
  final int handgun = 14;
  final int shotgun = 20;
  final int sniperRifle = 45;
  final int assaultRifle = 5;
}