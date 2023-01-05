import 'package:gamestream_flutter/isometric/events/on_quests_in_progress_changed.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/services/mini_map.dart';

class Player {
  final questAdded = Watch(false);
  var gameDialog = Watch<GameDialog?>(null, onChanged: onChangedGameDialog);
  var mouseAngle = 0.0;
  final mapTile = Watch(0, onChanged: MiniMap.onMapTileChanged);
  var npcTalk = Watch("");
  var npcTalkOptions = Watch<List<String>>([]);
  final abilityTarget = Vector3();
  var aimTargetChanged = Watch(0);
  final mouseTargetName = Watch<String?>(null);
  final mouseTargetAllie = Watch<bool>(false);
  final mouseTargetHealth = Watch(0.0);
  final message = Watch("", onChanged: GameEvents.onChangedPlayerMessage);
  var messageTimer = 0;
  final questsInProgress = Watch<List<Quest>>([], onChanged: onQuestsInProgressChanged);
  final questsCompleted = Watch<List<Quest>>([]);


  double get weaponRoundPercentage => 1.0;


  static void onPlayerCharacterStateChanged(int characterState){
     GamePlayer.alive.value = characterState != CharacterState.Dead;
  }

  static void onChangedGameDialog(GameDialog? value){
    GameAudio.click_sound_8();
    if (value == GameDialog.Quests) {
      // actionHideQuestAdded();
    }
  }
}
