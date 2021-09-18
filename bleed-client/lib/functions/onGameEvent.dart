import 'package:bleed_client/classes/FloatingText.dart';
import 'package:bleed_client/classes/GunshotFlash.dart';
import 'package:bleed_client/classes/RenderState.dart';
import 'package:bleed_client/common/constants.dart';
import 'package:bleed_client/instances/settings.dart';
import 'package:bleed_client/spawners/spawnBlood.dart';
import 'package:bleed_client/spawners/spawnHead.dart';
import 'package:bleed_client/spawners/spawnOrgan.dart';
import 'package:bleed_client/spawners/spawnShell.dart';
import 'package:bleed_client/spawners/spawnShotSmoke.dart';

import '../audio.dart';
import '../common/GameEventType.dart';
import '../maths.dart';
import '../spawn.dart';
import '../spawners/spawnArm.dart';
import '../utils.dart';
import 'spawnBulletHole.dart';

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
      spawnShotSmoke(x, y, xv, yv);
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
      spawnFloatingText(x, y, constants.pointsEarnedZombieKilled);
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


      spawnFloatingText(x, y, constants.pointsEarnedZombieKilled);
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
  }
}
