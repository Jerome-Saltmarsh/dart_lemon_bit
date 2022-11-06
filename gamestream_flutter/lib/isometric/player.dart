import 'package:gamestream_flutter/isometric/events/on_quests_in_progress_changed.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/services/mini_map.dart';

class Player {
  final weaponCooldown = Watch(1.0);
  // final finalstoreVisible = Watch(false, onChanged: GameEvents.onChangedStoreVisible);
  final interpolating = Watch(true);
  final target = Vector3();
  final questAdded = Watch(false);
  var gameDialog = Watch<GameDialog?>(null, onChanged: onChangedGameDialog);
  var angle = 0.0;
  var mouseAngle = 0.0;
  var team = 0;
  var abilityRange = 0.0;
  var abilityRadius = 0.0;
  var maxHealth = 0;
  var attackRange = 0.0;
  final mapTile = Watch(0, onChanged: MiniMap.onMapTileChanged);
  var interactingNpcName = Watch<String?>(null, onChanged: onChangedNpcTalk);
  var npcTalk = Watch<String?>(null, onChanged: onChangedNpcTalk);
  var npcTalkOptions = Watch<List<String>>([]);
  final abilityTarget = Vector3();
  var aimTargetChanged = Watch(0);
  final mouseTargetName = Watch<String?>(null);
  final mouseTargetAllie = Watch<bool>(false);
  final mouseTargetHealth = Watch(0.0);
  final health = Watch(0);
  final experience = Watch(0.0);
  final level = Watch(1);
  final points = Watch(0);
  final message = Watch("", onChanged: GameEvents.onChangedPlayerMessage);
  var messageTimer = 0;
  final alive = Watch(true, onChanged: GameEvents.onChangedPlayerAlive);
  final wood = Watch(0);
  final stone = Watch(0);
  final gold = Watch(0);
  final questsInProgress = Watch<List<Quest>>([], onChanged: onQuestsInProgressChanged);
  final questsCompleted = Watch<List<Quest>>([]);


  // Properties
  bool get dead => !alive.value;

  double get weaponRoundPercentage => 1.0;


  static void onPlayerCharacterStateChanged(int characterState){
     GameState.player.alive.value = characterState != CharacterState.Dead;
  }

  static void onChangedGameDialog(GameDialog? value){
    GameAudio.click_sound_8();
    if (value == GameDialog.Quests) {
      // actionHideQuestAdded();
    }
  }

  static void onChangedNpcTalk(String? value){
    GameState.npcTextVisible = Engine.isNullOrEmpty(value);
    GamePlayer.interactMode.value = InteractMode.Talking;
  }
}

class AttackSlot {
  /// see attack_type.dart
  final type = Watch(ItemType.Empty);
  final capacity = Watch(0);
  final rounds = Watch(0);
}