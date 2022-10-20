import 'package:bleed_common/character_type.dart';
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/game_audio.dart';
import 'package:gamestream_flutter/game_events.dart';
import 'package:gamestream_flutter/isometric/audio.dart';
import 'package:gamestream_flutter/isometric/camera.dart';
import 'package:gamestream_flutter/isometric/classes/explosion.dart';
import 'package:gamestream_flutter/isometric/events/on_character_hurt.dart';
import 'package:gamestream_flutter/isometric/events/on_game_event_attack_performed.dart';
import 'package:gamestream_flutter/isometric/events/on_game_event_game_object_destroyed.dart';
import 'package:gamestream_flutter/isometric/server_response_reader.dart';
import 'package:lemon_math/library.dart';

import 'on_character_death.dart';
import 'on_game_event_footstep.dart';

void onGameEvent(int type, double x, double y, double z, double angle) {
  switch (type) {
    case GameEventType.Footstep:
      return onGameEventFootstep(x, y, z);
    case GameEventType.Attack_Performed:
      return onGameEventAttackPerformed(x, y, z, angle);
    case GameEventType.Player_Spawn_Started:
      cameraCenterOnPlayer();
      return GameAudio.teleport.playXYZ(x, y, z);
    case GameEventType.AI_Target_Acquired:
      final characterType = serverResponseReader.readByte();
      switch (characterType){
        case CharacterType.Zombie:
          randomItem(GameAudio.audioSingleZombieTalking).playXYZ(x, y, z);
          break;
      }
      break;
    case GameEventType.Node_Set:
      return onGameEventNodeSet(x, y, z);
    case GameEventType.Node_Struck:
      final nodeType = serverResponseReader.readByte();
      onGameEventNodeStruck(nodeType, x, y, z);
      break;
    case GameEventType.Node_Deleted:
      GameAudio.hover_over_button_sound_30.playXYZ(x, y, z);
      break;
    case GameEventType.Weapon_Type_Equipped:
      final attackType =  serverResponseReader.readByte();
      return GameEvents.onWeaponTypeEquipped(attackType, x, y, z);
    case GameEventType.Player_Spawned:
      for (var i = 0; i < 7; i++){
        GameState.spawnParticleOrbShard(x: x, y: y, z: z, angle: randomAngle());
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
      GameAudio.change_cloths.playXYZ(x, y, z);
      break;
    case GameEventType.Zombie_Strike:
      randomItem(GameAudio.audioSingleZombieBits).playXYZ(x, y, z);
      if (randomBool()){
        randomItem(GameAudio.audioSingleZombieTalking).playXYZ(x, y, z);
      }
      break;
    case GameEventType.Player_Death:
      break;
    case GameEventType.Teleported:
      audio.magicalSwoosh(x, y);
      break;
    case GameEventType.Blue_Orb_Fired:
      return GameAudio.sci_fi_blaster_1.playXYZ(x, y, z);
    case GameEventType.Arrow_Hit:
      audio.arrowImpact(x, y);
      break;
    case GameEventType.Draw_Bow:
      return GameAudio.bow_draw.playXYZ(x, y, z);
    case GameEventType.Release_Bow:
      return GameAudio.bow_release.playXYZ(x, y, z);
    case GameEventType.Sword_Woosh:
      return GameAudio.swing_sword.playXYZ(x, y, z);
    case GameEventType.EnemyTargeted:
      break;
    case GameEventType.Attack_Missed:
      final attackType = serverResponseReader.readByte();
      switch (attackType) {
        case AttackType.Unarmed:
          GameAudio.arm_swing_whoosh_11.playXYZ(x, y, z);
          break;
        case AttackType.Blade:
          GameAudio.arm_swing_whoosh_11.playXYZ(x, y, z);
          break;
        case AttackType.Baseball_Bat:
          GameAudio.arm_swing_whoosh_11.playXYZ(x, y, z);
          break;
      }
      break;
    case GameEventType.Arrow_Fired:
      return GameAudio.arrow_flying_past_6.playXYZ(x, y, z);

    case GameEventType.Crate_Breaking:
      return audio.crateBreaking(x, y);

    case GameEventType.Blue_Orb_Deactivated:
      for (var i = 0; i < 8; i++) {
        GameState.spawnParticleOrbShard(
            x: x, y: y, z: z, duration: 30, speed: randomBetween(1, 2), angle: randomAngle());
      }
      GameState.spawnEffect(x: x, y: y, type: EffectType.Explosion, duration: 30);
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
  GameAudio.hover_over_button_sound_43.playXYZ(x, y, z);
}

void onGameEventNodeStruck(int nodeType, double x, double y, double z) {

  if (NodeType.isMaterialWood(nodeType)){
    GameAudio.material_struck_wood.playXYZ(x, y, z);
    GameState.spawnParticleBlockWood(x, y, z);
  }

  if (NodeType.isMaterialGrass(nodeType)){
    GameAudio.grass_cut.playXYZ(x, y, z);
    GameState.spawnParticleBlockGrass(x, y, z);
  }

  if (NodeType.isMaterialStone(nodeType)){
    GameAudio.material_struck_stone.playXYZ(x, y, z);
    GameState.spawnParticleBlockBrick(x, y, z);
  }
}

void onGameEventAttackPerformedBlade(double x, double y, double z, double angle) {
  GameState.spawnParticleStrikeBlade(x: x, y: y, z: z, angle: angle);
  // audioSingleSciFiBlaster8.playXYZ(x, y, z);

  GameAudio.swing_sword.playXYZ(x, y, z);
  // const range = 5.0;
  // engine.camera.x += getAdjacent(angle + piQuarter, range);
  // engine.camera.y += getOpposite(angle + piQuarter, range);

  GameState.spawnParticleBubbles(
    count: 3,
    x: x,
    y: y,
    z: z,
    angle: angle,
  );
}

void onGameEventAttackPerformedUnarmed(double x, double y, double z, double angle) {
  GameState.spawnParticleBubbles(
    count: 3,
    x: x,
    y: y,
    z: z,
    angle: angle,
  );
}

void onGameEventSpawnDustCloud(double x, double y, double z) {
  for (var i = 0; i < 3; i++){
    GameState.spawnParticleBubble(x: x, y: y, z: z, speed: 1, angle: randomAngle());
  }
}

void onGameEventSplash(double x, double y, double z) {
  for (var i = 0; i < 8; i++){
    GameState.spawnParticleWaterDrop(x: x, y: y, z: z);
  }
  return GameAudio.splash.playXYZ(x, y, z);
}
