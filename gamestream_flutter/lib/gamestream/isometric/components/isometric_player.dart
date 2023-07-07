import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_character.dart';
import 'package:gamestream_flutter/library.dart';

import 'isometric_render.dart';
import '../enums/game_dialog.dart';
import '../classes/isometric_position.dart';

class IsometricPlayer {
  var playerInsideIsland = false;
  var energyPercentage = 0.0;
  var runningToTarget = false;
  var aimTargetCategory = TargetCategory.Nothing;
  var aimTargetType = 0;
  var aimTargetName = '';
  var aimTargetQuantity = 0;
  var messageTimer = 0;
  var mouseAngle = 0.0;
  var indexZ = 0;
  var indexRow = 0;
  var indexColumn = 0;
  var nodeIndex = 0;

  final npcTalk = Watch('');
  final aimTargetPosition = IsometricPosition();
  final targetPosition = IsometricPosition();
  final position = IsometricPosition();
  final npcTalkOptions = Watch<List<String>>([]);
  final aimTargetChanged = Watch(0);
  final id = Watch(0);
  final team = Watch(0);
  final powerType = Watch(CombatPowerType.None);
  final powerReady = Watch(true);
  final attributeHealth = Watch(0);
  final attributeMagic = Watch(0);
  final attributeDamage = Watch(0);
  final body = Watch(0);
  final head = Watch(0);
  final legs = Watch(0);
  final previousPosition = IsometricPosition();
  final accuracy = Watch(1.0);
  final storeItems = Watch(<int>[]);
  final energy = Watch(0);
  final energyMax = Watch(0);
  final abilityTarget = IsometricPosition();
  final mouseTargetName = Watch<String?>(null);
  final mouseTargetAllie = Watch<bool>(false);
  final mouseTargetHealth = Watch(0.0);
  final weaponCooldown = Watch(1.0);
  final interpolating = Watch(true);
  final target = IsometricPosition();
  final questAdded = Watch(false);

  late final message = Watch('', onChanged: gamestream.isometric.events.onChangedPlayerMessage);
  late final gameDialog = Watch<GameDialog?>(null, onChanged: onChangedGameDialog);
  late final active = Watch(false, onChanged: gamestream.isometric.events.onChangedPlayerActive);
  late final alive = Watch(true);
  late final weapon = Watch(0, onChanged: gamestream.isometric.events.onChangedPlayerWeapon);
  late final weaponPrimary = Watch(0, onChanged: gamestream.isometric.events.onChangedPlayerWeapon);
  late final weaponSecondary = Watch(0, onChanged: gamestream.isometric.events.onChangedPlayerWeapon);
  late final weaponTertiary = Watch(0, onChanged: gamestream.isometric.events.onChangedPlayerWeapon);
  late final respawnTimer = Watch(0);

  int get areaNodeIndex => (indexRow * gamestream.isometric.scene.totalColumns) + indexColumn;

  double get x => position.x;
  double get y => position.y;
  double get z => position.z;
  double get renderX => IsometricRender.getPositionRenderX(position);
  double get renderY => IsometricRender.getPositionRenderY(position);
  double get positionScreenX => engine.worldToScreenX(position.renderX);
  double get positionScreenY => engine.worldToScreenY(position.renderY);

  bool get interactModeTrading => gamestream.isometric.server.interactMode.value == InteractMode.Trading;
  bool get dead => !alive.value;
  bool get inBounds => gamestream.isometric.scene.inBoundsPosition(position);


  bool isCharacter(IsometricCharacter character){
    return position.x == character.x && position.y == character.y && position.z == character.z;
  }

  void onChangedGameDialog(GameDialog? value){
    gamestream.audio.click_sound_8();
    if (value == GameDialog.Quests) {
      // actionHideQuestAdded();
    }
  }

  bool isInsideBuilding(){
    if (!inBounds) return false;
    final scene = gamestream.isometric.scene;
    final index = nodeIndex + scene.area;
    while (index < scene.total){
      if (NodeType.isRainOrEmpty(scene.nodeTypes[index])) continue;
      return true;
    }
    return false;
  }

  Watch<int> getItemTypeWatch(int itemType){
    // if (ItemType.isTypeWeapon(itemType)) return weapon;
    // if (ItemType.isTypeHead(itemType)) return head;
    // if (ItemType.isTypeBody(itemType)) return body;
    // if (ItemType.isTypeLegs(itemType)) return legs;
    throw Exception(
        'gamestream.isometricEngine.player.getItemTypeWatch($itemType)'
    );
  }

  void updateMessageTimer() {
    if (messageTimer <= 0)
      return;
    messageTimer--;
    if (messageTimer > 0)
      return;
    message.value = '';
  }

  void reset() {
    position.x = 0;
    position.y = 0;
    position.z = 0;
    savePositionPrevious();
  }

  void savePositionPrevious(){
    previousPosition.x = position.x;
    previousPosition.y = position.y;
    previousPosition.z = position.z;
  }
}

typedef ItemTypeEntry = MapEntry<int, int>;