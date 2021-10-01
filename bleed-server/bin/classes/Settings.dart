class Settings {
  final host = '0.0.0.0';
  final port = 8080;

  final Radius radius = Radius();
  final Accuracy accuracy = Accuracy();
  final CoolDown coolDown = CoolDown();
  final Damage damage = Damage();
  final Range range = Range();
  final NpcSettings npc = NpcSettings();
  final _MapRounds maxRounds = _MapRounds();
  final _MaxClips maxClips = _MaxClips();
  final _Pickup pickup = _Pickup();
  final _ReloadDuration reloadDuration = _ReloadDuration();
  final _PointsEarned pointsEarned = _PointsEarned();
  final double zombieSpeed = 2;
  final double playerSpeed = 4;
  final double machineGunBulletSpeed = 18;
  final int crateDeactiveDuration = 1000;
  final double knifeRange = 15;
  final double knifeHitAcceleration = 5;
  final int knifeAttackDuration = 15;
  final double itemCollectRadius = 10;
  final double chanceOfDropItem = 0.25;
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

  final int playerDisconnectFrames = 300;

  final double velocityFriction = 0.88;
  final double zombieChaseRange = 600;
  final double weaponRangeVariation = 10.0;
  final double settingsNpcRoamRange = 100;
  final int settingsPlayerStartHealth = 5;
  final double playerStartRadius = 50;

  final int settingsHandgunReloadDuration = 20;
  final int settingsShotgunReloadDuration = 22;
  final double settingsWeaponBulletSpeedHandGun = 14.0;
  final double settingsWeaponBulletSpeedShotGun = 12.0;
  final double settingsWeaponBulletSpeedSniperRifle = 24.0;
  final int settingsClipEmptyCooldown = 14;
  final int settingsShotgunBulletsPerShot = 5;
  final double settingsParticleShellSpeed = 3;
  final double bulletImpactVelocityTransfer = 0.25;

  final int tilesX = 32;
  final int tilesY = 32;

  final int settingsGrenadeDuration = 800;
  final double settingsGrenadeExplosionRadius = 75;
  final double settingsGrenadeSpeed = 18;
  final double settingsGrenadeFriction = 0.98;

  final double minStamina = 60;

}

class _MapRounds {
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
  final double character = 20;
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

class Damage {
  final int knife = 10;
  final int zombieStrike = 1;
  final int grenade = 15;
  final int handgun = 5;
  final int shotgun = 3;
  final int sniperRifle = 35;
  final int assaultRifle = 4;
}

class Range {
  final double handgun = 320;
  final double shotgun = 180;
  final double sniperRifle = 600;
  final double assaultRifle = 450;
  final double zombieStrike = 20;
}

class NpcSettings {
  final double destinationRadius = 15.0;
  final double viewRange = 300;
}
