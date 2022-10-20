import 'package:bleed_common/PlayerEvent.dart';
import 'package:bleed_common/attack_type.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/game_audio.dart';
import 'package:gamestream_flutter/isometric/audio.dart';
import 'package:gamestream_flutter/isometric/camera.dart';
import 'package:gamestream_flutter/game_editor.dart';
import 'package:gamestream_flutter/isometric/events/on_player_event_quest_completed.dart';
import 'package:gamestream_flutter/isometric/events/on_player_event_quest_started.dart';
import 'package:gamestream_flutter/isometric/floating_texts.dart';
import 'package:gamestream_flutter/isometric/server_response_reader.dart';
import 'package:lemon_engine/engine.dart';

void onPlayerEvent(int event) {
  switch (event) {
    case PlayerEvent.Spawn_Started:
      return GameAudio.teleport();
    case PlayerEvent.Loot_Collected:
      return GameAudio.collect_star_3();
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
      GameAudio.unlock();
      break;
    case PlayerEvent.Ammo_Acquired:
      audio.itemAcquired(Engine.screenCenterWorldX, Engine.screenCenterWorldY);
      break;
    case PlayerEvent.Item_Equipped:
      final type = serverResponseReader.readByte();
      onPlayerEventItemEquipped(type);
      break;
    case PlayerEvent.Item_Dropped:
      GameAudio.switch_sounds_4();
      break;
    case PlayerEvent.Item_Sold:
      audio.coins(Engine.screenCenterWorldX, Engine.screenCenterWorldY);
      break;
    case PlayerEvent.Drink_Potion:
      audio.bottle(Engine.screenCenterWorldX, Engine.screenCenterWorldY);
      break;
    case PlayerEvent.Collect_Wood:
      audio.coins(Engine.screenCenterWorldX, Engine.screenCenterWorldY);
      break;
    case PlayerEvent.Collect_Rock:
      audio.coins(Engine.screenCenterWorldX, Engine.screenCenterWorldY);
      break;
    case PlayerEvent.Collect_Experience:
      audio.collectStar3(Engine.screenCenterWorldX, Engine.screenCenterWorldY);
      break;
    case PlayerEvent.Collect_Gold:
      audio.coins(Engine.screenCenterWorldX, Engine.screenCenterWorldY);
      break;
    case PlayerEvent.Hello_Male_01:
      GameAudio.male_hello.play();
      break;
    case PlayerEvent.GameObject_Deselected:
      GameEditor.gameObjectSelected.value = false;
      break;
    case PlayerEvent.Player_Moved:
      cameraCenterOnPlayer();
      break;
  }
}

void onPlayerEventItemEquipped(int type) {
  switch (type) {
    case AttackType.Revolver:
      GameAudio.revolver_reload_1();
      break;
    case AttackType.Handgun:
      GameAudio.reload_6();
      break;
    case AttackType.Shotgun:
      GameAudio.cock_shotgun_3();
      break;
    case AttackType.Rifle:
      GameAudio.mag_in_03();
      break;
    case AttackType.Blade:
      GameAudio.sword_unsheathe();
      break;
    case AttackType.Assault_Rifle:
      GameAudio.gun_pickup_01();
      break;
    case AttackType.Bow:
      GameAudio.bow_draw();
      break;
  }
}
