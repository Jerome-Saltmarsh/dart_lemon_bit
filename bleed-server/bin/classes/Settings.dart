class Settings {
  final int machineGunCoolDown = 5;
  final double machineGunRange = 400;
  final double machineGunAccuracy = 0.1;
  final double machineGunDamage = 0.7;
  final double machineGunBulletSpeed = 18;

  final double handgunAccuracy = 0.05;
  final double sniperRifleAccuracy = 0;
  final double shotgunAccuracy = 0.15;
  final double itemCollectRadius = 10;

  final double chanceOfDropItem = 0.25;
  final int itemDuration = 500;

  final _ClipSize clipSize = _ClipSize();
  final _MaxClips maxClips = _MaxClips();
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
}

class _ClipSize {
  final int handgun = 24;
  final int shotgun = 20;
  final int sniperRifle = 15;
  final int assaultRifle = 150;
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