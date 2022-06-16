import 'dart:math';

import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/state/particles.dart';
import 'package:lemon_math/library.dart';
import 'package:gamestream_flutter/isometric/classes/explosion.dart';
import 'package:gamestream_flutter/isometric/audio.dart';

void onGameEvent(int type, double x, double y, double angle) {
  switch (type) {
    case GameEventType.Handgun_Fired:
      audio.handgunShot(x, y);
      const distance = 12.0;
      final xForward = getAdjacent(angle, distance);
      final yForward = getOpposite(angle, distance);
      spawnParticleShell(x: x + xForward, y: y + yForward);
      break;
    case GameEventType.Shotgun_Fired:
      audio.shotgunShot(x, y);
      spawnParticleShell(x: x, y: y);
      break;
    case GameEventType.SniperRifle_Fired:
      audio.sniperShot(x, y);
      spawnParticleShell(x: x, y: y);
      break;
    case GameEventType.MachineGun_Fired:
      audio.assaultRifleShot(x, y);
      spawnParticleShell(x: x, y: y);
      break;
    case GameEventType.Player_Hit:
      if (randomBool()) {
        audio.humanHurt(x, y);
      }
      break;
    case GameEventType.Zombie_Killed:
      spawnParticleHeadZombie(x: x, y: y, z: 0.5, angle: angle, speed: 4.0);
      spawnParticleArm(x: x, y: y, z: 0.5, angle: angle + giveOrTake(0.5), speed: 4.0 + giveOrTake(0.5));
      spawnParticleArm(x: x, y: y, z: 0.5, angle: angle + giveOrTake(0.5), speed: 4.0 + giveOrTake(0.5));
      spawnParticleLegZombie(x: x, y: y, z: 0.5, angle: angle + giveOrTake(0.5), speed: 4.0 + giveOrTake(0.5));
      spawnParticleLegZombie(x: x, y: y, z: 0.5, angle: angle + giveOrTake(0.5), speed: 4.0 + giveOrTake(0.5));
      spawnParticleOrgan(x: x, y: y, z: 0.5, angle: angle + giveOrTake(0.5), speed: 4.0 + giveOrTake(0.5), zv: 0.1);
      audio.zombieDeath(x, y);
      break;

    case GameEventType.Zombie_Target_Acquired:
      audio.zombieTargetAcquired(x, y);
      break;
    case GameEventType.Bullet_Hole:
      // actions.spawnBulletHole(x.toDouble(), y.toDouble());
      break;
    case GameEventType.Zombie_Strike:
      audio.zombieBite(x, y);
      break;
    case GameEventType.Player_Death:
      // actions.emitPixelExplosion(x, y);
      break;
    case GameEventType.Explosion:
      spawnExplosion(x, y);
      break;

    case GameEventType.FreezeCircle:
      freezeCircle(x: x, y: y,);
      break;
    case GameEventType.Teleported:
      // actions.emitPixelExplosion(x, y);
      audio.magicalSwoosh(x, y);
      break;
    case GameEventType.Blue_Orb_Fired:
      audio.sciFiBlaster1(x, y);
      break;
    case GameEventType.Arrow_Hit:
      audio.arrowImpact(x, y);
      break;
    case GameEventType.Draw_Bow:
      audio.drawBow(x, y);
      break;
    case GameEventType.Release_Bow:
      audio.releaseBow(x, y);
      break;
    case GameEventType.Sword_Woosh:
      audio.swordWoosh(x, y);
      break;
    case GameEventType.Objective_Reached:
      // actions.emitPixelExplosion(x, y);
      break;
    case GameEventType.EnemyTargeted:
      // actions.emitPixelExplosion(x, y);
      break;
    case GameEventType.Arrow_Fired:
      audio.arrowFlyingPast6(x, y);
      break;
    case GameEventType.Clip_Empty:
      audio.dryShot2(x, y);
      return;
    case GameEventType.Reloaded:
      audio.magIn2(x, y);
      return;
    case GameEventType.Use_MedKit:
      audio.medkit(x, y);
      break;
    case GameEventType.Throw_Grenade:
      audio.playAudioThrowGrenade(x, y);
      break;
    case GameEventType.Item_Acquired:
      audio.itemAcquired(x, y);
      break;
    case GameEventType.Knife_Strike:
      audio.playAudioKnifeStrike(x, y);
      break;
    case GameEventType.Health_Acquired:
      audio.playAudioHeal(x, y);
      break;
    case GameEventType.Crate_Breaking:
      audio.crateBreaking(x, y);
      break;
    case GameEventType.Ammo_Acquired:
      audio.gunPickup(x, y);
      break;
    case GameEventType.Credits_Acquired:
      audio.collectStar4(x, y);
      break;

    case GameEventType.Object_Destroyed_Pot:
      for (var i = 0; i < 8; i++) {
        spawnParticlePotShard(x, y);
      }
      audio.potBreaking(x, y);
      break;


    case GameEventType.Object_Destroyed_Rock:
      for (var i = 0; i < 8; i++) {
        spawnParticleRockShard(x, y);
      }
      audio.rockBreaking(x, y);
      break;

    case GameEventType.Object_Destroyed_Tree:
      for (var i = 0; i < 8; i++) {
        spawnParticleTreeShard(x, y);
      }
      audio.treeBreaking(x, y);
      break;

    case GameEventType.Object_Destroyed_Chest:
      for (var i = 0; i < 8; i++) {
        spawnParticleShardWood(x, y);
      }
      audio.crateDestroyed(x, y);
      break;

    case GameEventType.Material_Struck_Wood:
      for (var i = 0; i < 8; i++) {
        spawnParticleTreeShard(x, y);
      }
      audio.materialStruckWood(x, y);
      break;

    case GameEventType.Material_Struck_Rock:
      for (var i = 0; i < 8; i++) {
        spawnParticleRockShard(x, y);
      }
      audio.materialStruckRock(x, y);
      break;

    case GameEventType.Material_Struck_Flesh:
      audio.materialStruckFlesh(x, y);
      final total = randomInt(2, 5);
      for (var i = 0; i < total; i++) {
        spawnParticleBlood(
          x: x,
          y: y,
          z: 0.3,
          angle: angle + giveOrTake(0.2),
          speed: 4.0 + giveOrTake(2),
          zv: 0.07 + giveOrTake(0.01),
        );
      }
      for (var i = 0; i < 1; i++) {
        spawnParticleBlood(
          x: x,
          y: y,
          z: 0.3,
          angle: angle + giveOrTake(0.2) + pi,
          speed: 1.0 + giveOrTake(1),
          zv: 0.07 + giveOrTake(0.01),
        );
      }

      break;

    case GameEventType.Material_Struck_Metal:
      audio.materialStruckMetal(x, y);
      break;

    case GameEventType.Zombie_Hurt:
      audio.zombieHurt(x, y);
      break;

    case GameEventType.Blue_Orb_Deactivated:
      for (var i = 0; i < 8; i++){
        spawnParticleOrbShard(
            x: x,
            y: y,
            duration: 30,
            speed: randomBetween(1, 2)
        );
      }
      spawnEffect(x: x, y: y, type: EffectType.Explosion, duration: 30);
      break;

    case GameEventType.Projectile_Fired_Fireball:
      audio.firebolt(x, y);
      break;

  }
}
