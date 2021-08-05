
import 'dart:math';

const host = '0.0.0.0';
const port = 8080;
const int expiration = 200;
const double bulletSpeed = 14.0;
const int maxZombies = 5;
const double spawnRadius = 500;
const double zombieSpeed = 2;
const double playerSpeed = 3;
const int playerHealth = 3;
const double velocityFriction = 0.88;
const double zombieViewRange = 300;
const double settingsZombieStrikeRange = 20;
const double destinationArrivedDistance = 5.0;
const double startingAccuracy = 3.14 * 0.1;
const double settingsWeaponRangeVariation = 5.0;
const int pistolCoolDown = 8;
const int shotgunCoolDown = 20;
const int compilePositionDecimals = 0;
const Duration npcDeathVanishDuration = Duration(seconds: 5);
const double settingsNpcRoamRange = 50;
const double settingsPlayerStartHealth = 5;
const int settingsPlayerDisconnectFrames = 300;
const double settingsPlayerStartRadius = 50;
const double settingsWeaponRangeHandgun = 320;
const double settingsWeaponRangeShotgun = 180;
const double settingsWeaponAccuracyHandgun = 0;
const double settingsWeaponAccurayShotgun = pi * 0.06;
const int settingsShotgunBulletsPerShot = 5;
const double settingsParticleShellSpeed = 8;

const int tilesX = 40;
const int tilesY = 40;