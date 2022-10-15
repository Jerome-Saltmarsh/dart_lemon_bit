import 'package:bleed_common/PlayerEvent.dart';
import 'package:bleed_common/attack_type.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/audio.dart';
import 'package:gamestream_flutter/isometric/audio/audio_singles.dart';
import 'package:gamestream_flutter/isometric/camera.dart';
import 'package:gamestream_flutter/isometric/edit.dart';
import 'package:gamestream_flutter/isometric/events/on_player_event_quest_completed.dart';
import 'package:gamestream_flutter/isometric/events/on_player_event_quest_started.dart';
import 'package:gamestream_flutter/isometric/floating_texts.dart';
import 'package:gamestream_flutter/isometric/server_response_reader.dart';
import 'package:lemon_engine/engine.dart';

void onPlayerEvent(int event) {
  switch (event) {
    case PlayerEvent.Spawn_Started:
      return audioSingleTeleport();
    case PlayerEvent.Loot_Collected:
      return audioSingleCollectStar3();
    case PlayerEvent.Weapon_Rounds:
      final rounds = serverResponseReader.readInt();
      final capacity = serverResponseReader.readInt();
      GameState.player.weapon.rounds.value = rounds;
      GameState.player.weapon.capacity.value = capacity;
      break;
    case PlayerEvent.Scene_Changed:
      return cameraCenterOnPlayer();
    case PlayerEvent.Quest_Started:
      return onPlayerEventQuestStarted();
    case PlayerEvent.Quest_Completed:
      return onPlayerEventQuestCompleted();
    case PlayerEvent.Interaction_Finished:
      GameState.player.npcTalk.value = null;
      GameState.player.npcTalkOptions.value = [];
      break;
    case PlayerEvent.Level_Up:
      audio.buff(GameState.player.x, GameState.player.y);
      spawnFloatingText(GameState.player.x, GameState.player.y, 'LEVEL UP');
      break;
    case PlayerEvent.Skill_Upgraded:
      audio.unlock(GameState.player.x, GameState.player.y);
      break;
    case PlayerEvent.Dash_Activated:
      audio.buff11(GameState.player.x, GameState.player.y);
      break;
    case PlayerEvent.Item_Purchased:
      audioSingleItemUnlock();
      break;
    case PlayerEvent.Ammo_Acquired:
      audio.itemAcquired(screenCenterWorldX, screenCenterWorldY);
      break;
    case PlayerEvent.Item_Equipped:
      final type = serverResponseReader.readByte();
      onPlayerEventItemEquipped(type);
      break;
    case PlayerEvent.Item_Dropped:
      audioSingleSwitchSounds4();
      break;
    case PlayerEvent.Item_Sold:
      audio.coins(screenCenterWorldX, screenCenterWorldY);
      break;
    case PlayerEvent.Drink_Potion:
      audio.bottle(screenCenterWorldX, screenCenterWorldY);
      break;
    case PlayerEvent.Collect_Wood:
      audio.coins(screenCenterWorldX, screenCenterWorldY);
      break;
    case PlayerEvent.Collect_Rock:
      audio.coins(screenCenterWorldX, screenCenterWorldY);
      break;
    case PlayerEvent.Collect_Experience:
      audio.collectStar3(screenCenterWorldX, screenCenterWorldY);
      break;
    case PlayerEvent.Collect_Gold:
      audio.coins(screenCenterWorldX, screenCenterWorldY);
      break;
    case PlayerEvent.Hello_Male_01:
      audioSingleMaleHello.play();
      break;
    case PlayerEvent.GameObject_Deselected:
      edit.gameObjectSelected.value = false;
      break;
    case PlayerEvent.Player_Moved:
      cameraCenterOnPlayer();
      break;
  }
}

void onPlayerEventItemEquipped(int type) {
  switch (type) {
    case AttackType.Revolver:
      audioSingleRevolverReload();
      break;
    case AttackType.Handgun:
      audioSingleReload6();
      break;
    case AttackType.Shotgun:
      audioSingleShotgunCock();
      break;
    case AttackType.Rifle:
      audioSingleMagIn2();
      break;
    case AttackType.Blade:
      audioSingleSwordUnsheathe();
      break;
    case AttackType.Assault_Rifle:
      audioSingleGunPickup();
      break;
    case AttackType.Bow:
      audioSingleBowDraw();
      break;
  }
}
