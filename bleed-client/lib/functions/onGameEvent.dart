
import 'package:lemon_math/give_or_take.dart';
import 'package:lemon_math/randomBool.dart';
import 'package:lemon_math/randomInt.dart';
import 'package:lemon_math/random_between.dart';

import '../audio.dart';
import '../common/GameEventType.dart';
import '../spawn.dart';
import 'spawnBulletHole.dart';
import 'spawners/spawnArm.dart';
import 'spawners/spawnBlood.dart';
import 'spawners/spawnHead.dart';
import 'spawners/spawnOrgan.dart';
import 'spawners/spawnShell.dart';
import 'spawners/spawnShotSmoke.dart';
import 'spawners/spawnShrapnel.dart';

void onGameEvent(GameEventType type, double x, double y, double xv, double yv) {
  switch (type) {
    case GameEventType.Handgun_Fired:
      playAudioHandgunShot(x, y);
      spawnShell(x, y);
      // render.gunShotFlashes.add(GunShotFlash(x: x, y: y, rotation: radians(xv, yv)));
      break;
    case GameEventType.Shotgun_Fired:
      playAudioShotgunShot(x, y);
      spawnShell(x, y);
      spawnShotSmoke(x, y, xv, yv);
      break;
    case GameEventType.SniperRifle_Fired:
      playAudioSniperShot(x, y);
      spawnShell(x, y);
      break;
    case GameEventType.MachineGun_Fired:
      playAudioAssaultRifleShot(x, y);
      spawnShell(x, y);
      // spawnShotSmoke(x, y, xv, yv);
      break;
    case GameEventType.Zombie_Hit:
      if (randomBool()) {
        playAudioZombieHit(x, y);
      }
      double s = 0.1;
      double r = 1;
      for (int i = 0; i < randomInt(2, 5); i++) {
        spawnBlood(x, y, 0.3,
            xv: xv * s + giveOrTake(r),
            yv: yv * s + giveOrTake(r),
            zv: randomBetween(0, 0.07));
      }
      break;
    case GameEventType.Player_Hit:
      if (randomBool()) {
        playAudioPlayerHurt(x, y);
      }
      double s = 0.1;
      double r = 1;
      for (int i = 0; i < randomInt(2, 5); i++) {
        spawnBlood(x, y, 0.3,
            xv: xv * s + giveOrTake(r),
            yv: yv * s + giveOrTake(r),
            zv: randomBetween(0, 0.07));
      }
      break;
    case GameEventType.Zombie_Killed:
      playAudioZombieDeath(x, y);
      double s = 0.15;
      double r = 1;
      for (int i = 0; i < randomInt(2, 5); i++) {
        spawnBlood(x, y, 0.3,
            xv: xv * s + giveOrTake(r),
            yv: yv * s + giveOrTake(r),
            zv: randomBetween(0, 0.07));
      }
      // spawnFloatingText(x, y, constants.points.zombieKilled);
      break;
    case GameEventType.Zombie_killed_Explosion:
      playAudioZombieDeath(x, y);
      double s = 0.15;
      double r = 1;
      for (int i = 0; i < randomInt(2, 5); i++) {
        spawnBlood(x, y, 0.3,
            xv: xv * s + giveOrTake(r),
            yv: yv * s + giveOrTake(r),
            zv: randomBetween(0, 0.07));
      }
      spawnHead(x, y, 0.3,
          xv: xv * s + giveOrTake(r), yv: yv * s + giveOrTake(r));
      spawnArm(x, y, 0.3,
          xv: xv * s + giveOrTake(r), yv: yv * s + giveOrTake(r));
      spawnArm(x, y, 0.3,
          xv: xv * s + giveOrTake(r), yv: yv * s + giveOrTake(r));
      spawnOrgan(x, y, 0.3,
          xv: xv * s + giveOrTake(r), yv: yv * s + giveOrTake(r));

      // spawnFloatingText(x, y, constants.points.zombieKilled);
      break;
    case GameEventType.Zombie_Target_Acquired:
      playAudioZombieTargetAcquired(x, y);
      break;
    case GameEventType.Bullet_Hole:
      spawnBulletHole(x.toDouble(), y.toDouble());
      break;
    case GameEventType.Zombie_Strike:
      playAudioZombieBite(x, y);
      double r = 1;
      double s = 0.15;
      for (int i = 0; i < randomInt(2, 4); i++) {
        spawnBlood(x, y, 0.3,
            xv: xv * s + giveOrTake(r),
            yv: yv * s + giveOrTake(r),
            zv: randomBetween(0, 0.07));
      }
      break;
    case GameEventType.Player_Death:
      playPlayerDeathAudio(x, y);
      break;
    case GameEventType.Explosion:
      spawnExplosion(x.toDouble(), y.toDouble());
      break;
    case GameEventType.Clip_Empty:
      playAudioClipEmpty(x, y);
      return;
    case GameEventType.Reloaded:
      playAudioReloadHandgun(x, y);
      return;
    case GameEventType.Use_MedKit:
      playAudioUseMedkit(x, y);
      break;
    case GameEventType.Throw_Grenade:
      playAudioThrowGrenade(x, y);
      break;
    case GameEventType.Item_Acquired:
      playAudioAcquireItem(x, y);
      break;
    case GameEventType.Knife_Strike:
      playAudioKnifeStrike(x, y);
      break;
    case GameEventType.Health_Acquired:
      playAudioHeal(x, y);
      break;
    case GameEventType.Crate_Breaking:
      for (int i = 0; i < randomInt(4, 10); i++) {
        spawnShrapnel(x, y);
      }
      playAudioCrateBreaking(x, y);
      break;
    case GameEventType.Ammo_Acquired:
      playAudioGunPickup(x, y);
      break;
    case GameEventType.Credits_Acquired:
      playAudioCollectStar(x, y);
      break;
  }
}
