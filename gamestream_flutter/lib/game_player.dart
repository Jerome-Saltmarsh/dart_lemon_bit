import 'package:gamestream_flutter/isometric/events/on_quests_in_progress_changed.dart';
import 'package:gamestream_flutter/library.dart';

import 'services/mini_map.dart';

class GamePlayer {
  static final weapon = Watch(0);
  static final body = Watch(0);
  static final head = Watch(0);
  static final legs = Watch(0);
  static final alive = Watch(true);
  static final previousPosition = Vector3();
  static final storeItems = Watch(<int>[]);

  static final energy = Watch(0);
  static final energyMax = Watch(0);

  static var position = Vector3();
  static var runningToTarget = false;
  static var targetCategory = TargetCategory.Nothing;
  static var targetPosition = Vector3();
  static var aimTargetCategory = TargetCategory.Nothing;
  static var aimTargetType = 0;
  static var aimTargetName = "";
  static var aimTargetQuantity = 0;
  static var aimTargetPosition = Vector3();
  static final weaponCooldown = Watch(1.0);
  static final interpolating = Watch(true);
  static final target = Vector3();
  static final questAdded = Watch(false);
  static var gameDialog = Watch<GameDialog?>(null, onChanged: onChangedGameDialog);
  static var mouseAngle = 0.0;
  static final mapTile = Watch(0, onChanged: MiniMap.onMapTileChanged);
  static var npcTalk = Watch("");
  static var npcTalkOptions = Watch<List<String>>([]);
  static final abilityTarget = Vector3();
  static var aimTargetChanged = Watch(0);
  static final mouseTargetName = Watch<String?>(null);
  static final mouseTargetAllie = Watch<bool>(false);
  static final mouseTargetHealth = Watch(0.0);
  static final message = Watch("", onChanged: GameEvents.onChangedPlayerMessage);
  static var messageTimer = 0;
  static final questsInProgress = Watch<List<Quest>>([], onChanged: onQuestsInProgressChanged);
  static final questsCompleted = Watch<List<Quest>>([]);

  static var indexZ = 0;
  static var indexRow = 0;
  static var indexColumn = 0;

  static double get renderX => GameConvert.convertV3ToRenderX(position);
  static double get renderY => GameConvert.convertV3ToRenderY(position);
  static double get positionScreenX => Engine.worldToScreenX(position.renderX);
  static double get positionScreenY => Engine.worldToScreenY(position.renderX);
  static bool get interactModeTrading => ServerState.interactMode.value == InteractMode.Trading;
  static bool get dead => !alive.value;
  static bool get inBounds => GameQueries.inBoundsVector3(position);
  static int get nodeIndex => position.nodeIndex;

  static bool isCharacter(Character character){
    return position.x == character.x && position.y == character.y && position.z == character.z;
  }

  static void onChangedGameDialog(GameDialog? value){
    GameAudio.click_sound_8();
    if (value == GameDialog.Quests) {
      // actionHideQuestAdded();
    }
  }

  static bool isInsideBuilding(){
     if (!inBounds) return false;
     final index = position.nodeIndex + GameNodes.area;
     while (index < GameNodes.total){
       if (NodeType.isRainOrEmpty(GameNodes.nodeTypes[index]))  continue;
       return true;
     }
     return false;
  }
}