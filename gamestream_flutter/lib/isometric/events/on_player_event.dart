import 'package:bleed_common/PlayerEvent.dart';
import 'package:bleed_common/attack_type.dart';
import 'package:gamestream_flutter/game_audio.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/audio.dart';
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
      return GameAudio.audioSingleTeleport();
    case PlayerEvent.Loot_Collected:
      return GameAudio.audioSingleCollectStar3();
    case PlayerEvent.Weapon_Rounds:
      final rounds = serverResponseReader.readInt();
      final capacity = serverResponseReader.readInt();
      Game.player.weapon.rounds.value = rounds;
      Game.player.weapon.capacity.value = capacity;
      break;
    case PlayerEvent.Scene_Changed:
      return cameraCenterOnPlayer();
    case PlayerEvent.Quest_Started:
      return onPlayerEventQuestStarted();
    case PlayerEvent.Quest_Completed:
      return onPlayerEventQuestCompleted();
    case PlayerEvent.Interaction_Finished:
      Game.player.npcTalk.value = null;
      Game.player.npcTalkOptions.value = [];
      break;
    case PlayerEvent.Level_Up:
      audio.buff(Game.player.x, Game.player.y);
      spawnFloatingText(Game.player.x, Game.player.y, 'LEVEL UP');
      break;
    case PlayerEvent.Skill_Upgraded:
      audio.unlock(Game.player.x, Game.player.y);
      break;
    case PlayerEvent.Dash_Activated:
      audio.buff11(Game.player.x, Game.player.y);
      break;
    case PlayerEvent.Item_Purchased:
      GameAudio.audioSingleItemUnlock();
      break;
    case PlayerEvent.Ammo_Acquired:
      audio.itemAcquired(Engine.screenCenterWorldX, Engine.screenCenterWorldY);
      break;
    case PlayerEvent.Item_Equipped:
      final type = serverResponseReader.readByte();
      onPlayerEventItemEquipped(type);
      break;
    case PlayerEvent.Item_Dropped:
      GameAudio.audioSingleSwitchSounds4();
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
      GameAudio.audioSingleMaleHello.play();
      break;
    case PlayerEvent.GameObject_Deselected:
      EditState.gameObjectSelected.value = false;
      break;
    case PlayerEvent.Player_Moved:
      cameraCenterOnPlayer();
      break;
  }
}

void onPlayerEventItemEquipped(int type) {
  switch (type) {
    case AttackType.Revolver:
      GameAudio.audioSingleRevolverReload();
      break;
    case AttackType.Handgun:
      GameAudio.audioSingleReload6();
      break;
    case AttackType.Shotgun:
      GameAudio.audioSingleShotgunCock();
      break;
    case AttackType.Rifle:
      GameAudio.audioSingleMagIn2();
      break;
    case AttackType.Blade:
      GameAudio.audioSingleSwordUnsheathe();
      break;
    case AttackType.Assault_Rifle:
      GameAudio.audioSingleGunPickup();
      break;
    case AttackType.Bow:
      GameAudio.audioSingleBowDraw();
      break;
  }
}
