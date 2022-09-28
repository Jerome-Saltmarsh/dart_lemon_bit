import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/audio.dart';
import 'package:gamestream_flutter/isometric/audio/audio_singles.dart';
import 'package:gamestream_flutter/isometric/classes/explosion.dart';
import 'package:gamestream_flutter/isometric/events/on_character_hurt.dart';
import 'package:gamestream_flutter/isometric/events/on_game_event_attack_performed.dart';
import 'package:gamestream_flutter/isometric/events/on_game_event_game_object_destroyed.dart';
import 'package:gamestream_flutter/isometric/events/on_game_event_weapon_type_equipped.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
import 'package:gamestream_flutter/isometric/server_response_reader.dart';
import 'package:lemon_math/library.dart';

import 'on_character_death.dart';
import 'on_game_event_footstep.dart';

void onGameEvent(int type, double x, double y, double z, double angle) {
  switch (type) {
    case GameEventType.Attack_Performed:
      return onGameEventAttackPerformed(x, y, z, angle);
    case GameEventType.Footstep:
      return onGameEventFootstep(x, y, z);
    case GameEventType.Player_Spawn_Started:
      return audioSingleTeleport.playXYZ(x, y, z);
    case GameEventType.Node_Set:
      return onGameEventNodeSet(x, y, z);
    case GameEventType.Node_Struck:
      final nodeType = serverResponseReader.readByte();
      onGameEventNodeStruck(nodeType, x, y, z);
      break;
    case GameEventType.Node_Deleted:
      audioSingleHoverOverButton30.playXYZ(x, y, z);
      break;
    case GameEventType.Weapon_Type_Equipped:
      final attackType =  serverResponseReader.readByte();
      return onGameEventWeaponTypeEquipped(attackType, x, y, z);
    case GameEventType.Player_Spawned:
      for (var i = 0; i < 7; i++){
        spawnParticleOrbShard(x: x, y: y, z: z, angle: randomAngle());
      }
      return;
    case GameEventType.Splash:
      return onGameEventSplash(x, y, z);
    case GameEventType.Spawn_Dust_Cloud:
      return onGameEventSpawnDustCloud(x, y, z);
    case GameEventType.Player_Hit:
      if (randomBool()) {
        audio.humanHurt(x, y);
      }
      break;
    case GameEventType.Zombie_Target_Acquired:
      audio.zombieTargetAcquired(x, y);
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
    case GameEventType.EnemyTargeted:
      break;
    case GameEventType.Attack_Missed:
      final attackType = serverResponseReader.readByte();
      switch (attackType) {
        case AttackType.Unarmed:
          audioSingleArmSwing.playXYZ(x, y, z);
          break;
        case AttackType.Blade:
          audioSingleArmSwing.playXYZ(x, y, z);
          break;
        case AttackType.Baseball_Bat:
          audioSingleArmSwing.playXYZ(x, y, z);
          break;
      }
      break;
    case GameEventType.Arrow_Fired:
      return audioSingleArrowFlying.playXYZ(x, y, z);

    case GameEventType.Crate_Breaking:
      return audio.crateBreaking(x, y);

    case GameEventType.Blue_Orb_Deactivated:
      for (var i = 0; i < 8; i++) {
        spawnParticleOrbShard(
            x: x, y: y, z: z, duration: 30, speed: randomBetween(1, 2), angle: randomAngle());
      }
      spawnEffect(x: x, y: y, type: EffectType.Explosion, duration: 30);
      break;

    case GameEventType.Character_Death:
      final characterType = serverResponseReader.readByte();
      return onGameEventCharacterDeath(characterType, x, y, z, angle);

    case GameEventType.Character_Hurt:
      final characterType = serverResponseReader.readByte();
      return onGameEventCharacterHurt(characterType, x, y, z, angle);

    case GameEventType.Game_Object_Destroyed:
      final type = serverResponseReader.readByte();
      return onGameEventGameObjectDestroyed(x, y, z, angle, type);
  }
}

void onGameEventNodeSet(double x, double y, double z) {
  audioSingleHoverOverButton43.playXYZ(x, y, z);
}

void onGameEventNodeStruck(int nodeType, double x, double y, double z) {

  if (NodeType.isMaterialWood(nodeType)){
    audioSingleMaterialStruckWood.playXYZ(x, y, z);
    spawnParticleBlockWood(x, y, z);
  }

  if (NodeType.isMaterialGrass(nodeType)){
    audioSingleGrassCut.playXYZ(x, y, z);
    spawnParticleBlockGrass(x, y, z);
  }

  if (NodeType.isMaterialStone(nodeType)){
    audioSingleMaterialStruckStone.playXYZ(x, y, z);
    spawnParticleBlockBrick(x, y, z);
  }
}

void onGameEventAttackPerformedBlade(double x, double y, double z, double angle) {
  spawnParticleStrikeBlade(x: x, y: y, z: z, angle: angle);
  // audioSingleSciFiBlaster8.playXYZ(x, y, z);

  audioSingleSwingSword.playXYZ(x, y, z);
  // const range = 5.0;
  // engine.camera.x += getAdjacent(angle + piQuarter, range);
  // engine.camera.y += getOpposite(angle + piQuarter, range);

  spawnParticleBubbles(
    count: 3,
    x: x,
    y: y,
    z: z,
    angle: angle,
  );
}

void onGameEventAttackPerformedUnarmed(double x, double y, double z, double angle) {
  spawnParticleStrikePunch(x: x, y: y, z: z, angle: angle);
  // const range = 25.0;
  // engine.camera.x += getAdjacent(angle + piQuarter, range);
  // engine.camera.y += getOpposite(angle + piQuarter, range);

  spawnParticleBubbles(
    count: 3,
    x: x,
    y: y,
    z: z,
    angle: angle,
  );
}

void onGameEventSpawnDustCloud(double x, double y, double z) {
  for (var i = 0; i < 3; i++){
    spawnParticleBubble(x: x, y: y, z: z, speed: 1, angle: randomAngle());
  }
}

void onGameEventSplash(double x, double y, double z) {
  for (var i = 0; i < 8; i++){
    spawnParticleWaterDrop(x: x, y: y, z: z);
  }
  return audioSingleSplash.playXYZ(x, y, z);
}
