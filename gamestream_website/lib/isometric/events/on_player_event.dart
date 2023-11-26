import 'package:bleed_common/PlayerEvent.dart';
import 'package:gamestream_flutter/isometric/audio.dart';
import 'package:gamestream_flutter/isometric/audio/audio_singles.dart';
import 'package:gamestream_flutter/isometric/camera.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/events/on_player_event_quest_completed.dart';
import 'package:gamestream_flutter/isometric/events/on_player_event_quest_started.dart';
import 'package:gamestream_flutter/isometric/floating_texts.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:lemon_engine/engine.dart';

void onPlayerEvent(int event) {
  switch (event) {
    case PlayerEvent.Scene_Changed:
      return cameraCenterOnPlayer();
    case PlayerEvent.Quest_Started:
      return onPlayerEventQuestStarted();
    case PlayerEvent.Quest_Completed:
      return onPlayerEventQuestCompleted();
    case PlayerEvent.Interaction_Finished:
      player.npcTalk.value = null;
      player.npcTalkOptions.value = [];
      break;
    case PlayerEvent.Level_Up:
      audio.buff(player.x, player.y);
      spawnFloatingText(player.x, player.y, 'LEVEL UP');
      break;
    case PlayerEvent.Skill_Upgraded:
      audio.unlock(player.x, player.y);
      break;
    case PlayerEvent.Dash_Activated:
      audio.buff11(player.x, player.y);
      break;
    case PlayerEvent.Item_Purchased:
      audioSingleItemUnlock();
      break;
    case PlayerEvent.Ammo_Acquired:
      audio.itemAcquired(screenCenterWorldX, screenCenterWorldY);
      break;
    case PlayerEvent.Item_Equipped:
      audio.itemAcquired(screenCenterWorldX, screenCenterWorldY);
      break;
    case PlayerEvent.Medkit:
      audio.medkit(screenCenterWorldX, screenCenterWorldY);
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
  }
}
