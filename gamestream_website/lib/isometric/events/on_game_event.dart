import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/audio.dart';
import 'package:gamestream_flutter/isometric/audio/audio_singles.dart';
import 'package:gamestream_flutter/isometric/classes/explosion.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
import 'package:gamestream_flutter/isometric/watches/raining.dart';
import 'package:lemon_math/library.dart';

void onGameEvent(int type, double x, double y, double z, double angle) {
  switch (type) {
    case GameEventType.Splash:
      return audioSingleSplash.playXYZ(x, y, z);
    case GameEventType.Footstep:
      final tile = getNodeXYZ(x, y, z - 2);

      if (raining.value){
        if (getNodeXYZ(x, y, z + 2) == GridNodeType.Rain_Landing) {
          audioSingleFootstepMud6.playXYZ(x, y, z);
        }
      }
      if (GridNodeType.isStone(tile.type)) {
        return audioSingleFootstepStone.playXYZ(x, y, z);
      }
      if (randomBool()){
        return audioSingleFootstepGrass8.playXYZ(x, y, z);
      }
      return audioSingleFootstepGrass7.playXYZ(x, y, z);

    case GameEventType.Handgun_Fired:
      audio.handgunShot(x, y);
      const distance = 12.0;
      final xForward = getAdjacent(angle, distance);
      final yForward = getOpposite(angle, distance);
      spawnParticleShell(x: x + xForward, y: y + yForward);
      break;
    case GameEventType.Shotgun_Fired:
      audioSingleShotgunShot.playXYZ(x, y, z);
      spawnParticleShell(x: x, y: y);
      break;
    case GameEventType.SniperRifle_Fired:
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
      final zPos = z + tileSizeHalf;
      spawnParticleHeadZombie(x: x, y: y, z: zPos, angle: angle, speed: 4.0);
      spawnParticleArm(
          x: x,
          y: y,
          z: zPos,
          angle: angle + giveOrTake(0.5),
          speed: 4.0 + giveOrTake(0.5));
      spawnParticleArm(
          x: x,
          y: y,
          z: zPos,
          angle: angle + giveOrTake(0.5),
          speed: 4.0 + giveOrTake(0.5));
      spawnParticleLegZombie(
          x: x,
          y: y,
          z: zPos,
          angle: angle + giveOrTake(0.5),
          speed: 4.0 + giveOrTake(0.5));
      spawnParticleLegZombie(
          x: x,
          y: y,
          z: zPos,
          angle: angle + giveOrTake(0.5),
          speed: 4.0 + giveOrTake(0.5));
      spawnParticleOrgan(
          x: x,
          y: y,
          z: zPos,
          angle: angle + giveOrTake(0.5),
          speed: 4.0 + giveOrTake(0.5),
          zv: 0.1);
      
      randomItem(audioSingleZombieDeaths).playXYZ(x, y, z);
      
      break;

    case GameEventType.Zombie_Target_Acquired:
      audio.zombieTargetAcquired(x, y);
      break;
    case GameEventType.Bullet_Hole:
      break;
    case GameEventType.Character_Changing:
      audioSingleChanging.playXYZ(x, y, z);
      break;
    case GameEventType.Zombie_Strike:
      randomItem(audioSingleZombieBits).playXYZ(x, y, z);
      if (randomBool()){
        randomItem(audioSingleZombieTalking).playXYZ(x, y, z);
      }
      break;
    case GameEventType.Player_Death:
      // actions.emitPixelExplosion(x, y);
      break;
    case GameEventType.Explosion:
      spawnExplosion(x, y);
      break;

    case GameEventType.FreezeCircle:
      freezeCircle(
        x: x,
        y: y,
      );
      break;
    case GameEventType.Teleported:
      audio.magicalSwoosh(x, y);
      break;
    case GameEventType.Blue_Orb_Fired:
      return audioSingleSciFiBlaster.playXYZ(x, y, z);
    case GameEventType.Arrow_Hit:
      audio.arrowImpact(x, y);
      break;
    case GameEventType.Draw_Bow:
      return audioSingleBowDraw.playXYZ(x, y, z);
    case GameEventType.Release_Bow:
      return audioSingleBowRelease.playXYZ(x, y, z);
    case GameEventType.Sword_Woosh:
      return audioSingleSwingSword.playXYZ(x, y, z);
    case GameEventType.Arm_Swing:
      return audioSingleSwingArm.playXYZ(x, y, z);
    case GameEventType.Objective_Reached:
      break;
    case GameEventType.EnemyTargeted:
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
        spawnParticleTreeShard(x, y, z);
      }
      break;

    case GameEventType.Object_Destroyed_Chest:
      for (var i = 0; i < 8; i++) {
        spawnParticleTreeShard(x, y, z);
      }
      audio.crateDestroyed(x, y);
      break;

    case GameEventType.Material_Struck_Wood:
      for (var i = 0; i < 8; i++) {
        // spawnParticleTreeShard(x, y, z);
      }
      break;

    case GameEventType.Material_Struck_Rock:
      for (var i = 0; i < 8; i++) {
        spawnParticleRockShard(x, y);
      }
      audio.materialStruckRock(x, y);
      break;

    case GameEventType.Material_Struck_Flesh:
      audioSingleBloodyPunches.playXYZ(x, y, z);
      final total = randomInt(2, 5);
      for (var i = 0; i < total; i++) {
        spawnParticleBlood(
          x: x,
          y: y,
          z: z,
          angle: angle + giveOrTake(0.2),
          speed: 4.0 + giveOrTake(2),
          zv: 3,
        );
      }
      // for (var i = 0; i < 1; i++) {
      //   spawnParticleBlood(
      //     x: x,
      //     y: y,
      //     z: z,
      //     angle: angle + giveOrTake(0.2) + pi,
      //     speed: 1.0 + giveOrTake(1),
      //     zv: 0.07 + giveOrTake(0.01),
      //   );
      // }
      break;

    case GameEventType.Material_Struck_Metal:
      audio.materialStruckMetal(x, y);
      break;

    case GameEventType.Zombie_Hurt:
      audioSingleZombieHurt.playXYZ(x, y, z);
      break;

    case GameEventType.Blue_Orb_Deactivated:
      for (var i = 0; i < 8; i++) {
        spawnParticleOrbShard(
            x: x, y: y, z: z, duration: 30, speed: randomBetween(1, 2));
      }
      spawnEffect(x: x, y: y, type: EffectType.Explosion, duration: 30);
      break;

    case GameEventType.Projectile_Fired_Fireball:
      return audioSingleFireball.playXYZ(x, y, z);
  }
}
