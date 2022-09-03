import 'package:bleed_common/character_type.dart';
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/audio.dart';
import 'package:gamestream_flutter/isometric/audio/audio_singles.dart';
import 'package:gamestream_flutter/isometric/classes/explosion.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
import 'package:gamestream_flutter/isometric/server_response_reader.dart';
import 'package:gamestream_flutter/isometric/watches/raining.dart';
import 'package:lemon_math/library.dart';

import 'on_character_death.dart';

void onGameEvent(int type, double x, double y, double z, double angle) {
  switch (type) {
    case GameEventType.Player_Spawn_Started:
      print("audioSingleTeleport.playXYZ($x, $y, $z);");
      return audioSingleTeleport.playXYZ(x, y, z);
    case GameEventType.Player_Spawned:
      for (var i = 0; i < 7; i++){
        spawnParticleOrbShard(x: x, y: y, z: z, angle: randomAngle());
      }
      return;
    case GameEventType.Splash:
      return audioSingleSplash.playXYZ(x, y, z);
    case GameEventType.Spawn_Dust_Cloud:
      for (var i = 0; i < 3; i++){
        spawnParticleBubble(x: x, y: y, z: z, speed: 1, angle: randomAngle());
      }
      break;
      // return spawnParticleDustCloud(x: x, y: y, z: z);
    case GameEventType.Footstep:
      final tile = getNodeXYZ(x, y, z - 2);
      if (raining.value){
        if (getNodeXYZ(x, y, z + 2) == NodeType.Rain_Landing) {
          audioSingleFootstepMud6.playXYZ(x, y, z);
        }
      }
      if (tile.isStone) {
        return audioSingleFootstepStone.playXYZ(x, y, z);
      }
      if (tile.isWood) {
        return audioSingleFootstepWood.playXYZ(x, y, z);
      }
      if (randomBool()){
        return audioSingleFootstepGrass8.playXYZ(x, y, z);
      }
      return audioSingleFootstepGrass7.playXYZ(x, y, z);

    case GameEventType.Handgun_Fired:
      audioSingleHandgunFired.playXYZ(x, y, z);
      const distance = 20.0;
      final xForward = getAdjacent(angle, distance);
      final yForward = getOpposite(angle, distance);
      spawnParticleShell(x: x + xForward, y: y + yForward);
      spawnParticleHandgunFiring(x: x + xForward, y: y + yForward, z: z + 15, angle: angle);
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
            x: x, y: y, z: z, duration: 30, speed: randomBetween(1, 2), angle: randomAngle());
      }
      spawnEffect(x: x, y: y, type: EffectType.Explosion, duration: 30);
      break;

    case GameEventType.Projectile_Fired_Fireball:
      return audioSingleFireball.playXYZ(x, y, z);

    case GameEventType.Character_Death:
      final characterType = serverResponseReader.readByte();
      onCharacterDeath(characterType, x, y, z, angle);
      break;

    case GameEventType.Sword_Slash:
      spawnParticleSlash(x: x, y: y, z: z, angle: angle);
      audioSingleSciFiBlaster8.playXYZ(x, y, z);
      audioSingleSwingSword.playXYZ(x, y, z);
      for (var i = 0; i < 3; i++) {
        spawnParticleBubble(x: x, y: y, z: z, angle: angle + giveOrTake(piQuarter), speed: 3 + giveOrTake(2));
      }
      final node = getNodeXYZ(x, y, z);
      if (node.type == NodeType.Grass_Long) {
        audioSingleGrassCut.playXYZ(x, y, z);
        for (var i = 0; i < 3; i++) {
          spawnParticleCutGrass(x: x, y: y, z: z);
        }
      }
      if (node.type == NodeType.Tree_Bottom) {
        audioSingleMaterialStruckWood.playXYZ(x, y, z);
      }
      if (node.type == NodeType.Torch) {
        audioSingleMaterialStruckWood.playXYZ(x, y, z);
      }
      if (node.type == NodeType.Wood_2) {
        audioSingleMaterialStruckWood.playXYZ(x, y, z);
      }
      if (node.type == NodeType.Wooden_Plank) {
        audioSingleMaterialStruckWood.playXYZ(x, y, z);
      }
      if (node.type == NodeType.Boulder) {
        audioSingleMaterialStruckStone.playXYZ(x, y, z);
      }
      if (node.type == NodeType.Brick_2) {
        audioSingleMaterialStruckStone.playXYZ(x, y, z);
      }
      break;
  }
}
