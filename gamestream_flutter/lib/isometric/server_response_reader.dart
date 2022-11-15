import 'package:gamestream_flutter/isometric/events/on_changed_scene.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:lemon_byte/byte_reader.dart';
import 'package:lemon_math/library.dart';

final serverResponseReader = ServerResponseReader();

class ServerResponseReader with ByteReader {
  final byteLength = Watch(0);
  final bufferSize = Watch(0);
  final updateFrame = Watch(0, onChanged: GameState.onChangedUpdateFrame);

  void readBytes(Uint8List values) {
    updateFrame.value++;
    index = 0;
    GameState.totalCharacters = 0;
    GameState.totalGameObjects = 0;
    bufferSize.value = values.length;
    this.values = values;

    while (true) {
      switch (readByte()) {
        case ServerResponse.Player:
          readServerResponsePlayer();
          break;
        case ServerResponse.Character_Rat:
          readCharacterRat();
          break;
        case ServerResponse.Character_Zombie:
          readCharacterZombie();
          break;
        case ServerResponse.Character_Template:
          readCharacterTemplate();
          break;
        case ServerResponse.Character_Player:
          readCharacterPlayer();
          break;
        case ServerResponse.Character_Slime:
          readCharacterSlime();
          break;
        case ServerResponse.GameObject:
          readGameObject();
          break;
        case ServerResponse.End:
          return readEnd();
        case ServerResponse.Projectiles:
          readProjectiles();
          break;
        case ServerResponse.Game_Event:
          readGameEvent();
          break;
        case ServerResponse.Player_Event:
          readPlayerEvent();
          break;
        case ServerResponse.Grid:
          readGrid();
          break;
        case ServerResponse.Debug_Mode:
          readDebugMode();
          break;
        case ServerResponse.Damage_Applied:
          readDamageApplied();
          break;
        case ServerResponse.Paths:
          readPaths();
          break;
        case ServerResponse.Game_Time:
          readGameTime();
          break;
        case ServerResponse.Game_Type:
          ServerState.gameType.value = readByte();
          break;
        case ServerResponse.Player_Spawned:
          readPlayerSpawned();
          GameActions.playerStop();
          break;
        case ServerResponse.Environment:
          readServerResponseEnvironment();
          break;
        case ServerResponse.Node:
          readNode();
          break;
        case ServerResponse.Player_Target:
          readVector3(GameState.player.target);
          break;
        case ServerResponse.Store_Items:
          readStoreItems();
          break;
        case ServerResponse.Npc_Talk:
          readNpcTalk();
          break;
        case ServerResponse.Player_Quests:
          readPlayerQuests();
          break;
        case ServerResponse.Weather:
          readWeather();
          break;
        case ServerResponse.Scene_Meta_Data:
          readSceneMetaData();
          break;
        case ServerResponse.Map_Coordinate:
          readMapCoordinate();
          break;
        case ServerResponse.Interacting_Npc_Name:
          readInteractingNpcName();
          break;
        case ServerResponse.Editor_GameObject_Selected:
          readEditorGameObjectSelected();
          break;
        case ServerResponse.Render_Map:
          GameUI.mapVisible.value = readBool();
          break;
        case ServerResponse.Error:
          ServerState.error.value = readString();
          break;
        default:
          if (debugging) {
            return;
          }
          print(values);
          debugging = true;
          readBytes(values);
          GameNetwork.disconnect();
          WebsiteState.error.value = "An error occurred";
          return;
      }
    }
  }

  var debugging = false;

  void readServerResponseEnvironment() {
    final environmentResponse = readByte();
    switch (environmentResponse) {
      case EnvironmentResponse.Shade:
        ServerState.ambientShade.value = readByte();
        break;
      case EnvironmentResponse.Rain:
        ServerState.rain.value = readRain();
        break;
      case EnvironmentResponse.Lightning:
        ServerState.lightning.value = readLightning();
        break;
      case EnvironmentResponse.Wind:
        ServerState.windAmbient.value = readWind();
        break;
      case EnvironmentResponse.Breeze:
        ServerState.weatherBreeze.value = readBool();
        break;
    }
  }

  void readGameObject() {
    final instance = GameState.getInstanceGameObject();
    instance.type = readUInt16();
    readVector3(instance);
  }

  void readServerResponsePlayer() {
    final apiPlayer = readByte();
    switch (apiPlayer) {
      case ApiPlayer.Position:
        GamePlayer.previousPosition.x = GamePlayer.position.x;
        GamePlayer.previousPosition.y = GamePlayer.position.y;
        GamePlayer.previousPosition.z = GamePlayer.position.z;
        readVector3(GamePlayer.position);
        break;
      case ApiPlayer.Aim_Target_Category:
        GamePlayer.aimTargetCategory = readByte();
        break;
      case ApiPlayer.Aim_Target_Position:
        readVector3(GamePlayer.aimTargetPosition);
        break;
      case ApiPlayer.Aim_Target_Type:
        GamePlayer.aimTargetType = readUInt16();
        break;
      case ApiPlayer.Aim_Target_Quantity:
        GamePlayer.aimTargetQuantity = readUInt16();
        break;
      case ApiPlayer.Equipped_Weapon_Ammunition:
        ServerState.playerEquippedWeaponAmmunitionType.value = readUInt16();
        ServerState.playerEquippedWeaponAmmunitionQuantity.value = readUInt16();
        break;
      case ApiPlayer.Aim_Target_Name:
        GamePlayer.aimTargetName = readString();
        break;
      case ApiPlayer.Target_Position:
        GamePlayer.runningToTarget = true;
        readVector3(GamePlayer.targetPosition);
        break;
      case ApiPlayer.Target_Category:
        GamePlayer.targetCategory = readByte();
        break;
      case ApiPlayer.Experience_Percentage:
        ServerState.playerExperiencePercentage.value = readPercentage();
        break;
      case ApiPlayer.Interact_Mode:
        ServerState.interactMode.value = readByte();
        break;
      case ApiPlayer.Health:
        ServerState.playerHealth.value = readInt();
        break;
      case ApiPlayer.Max_Health:
        ServerState.playerMaxHealth.value = readInt();
        break;
      case ApiPlayer.Weapon_Cooldown:
        GameState.player.weaponCooldown.value = readPercentage();
        break;
      case ApiPlayer.Level:
        ServerState.playerLevel.value = readUInt16();
        break;
      case ApiPlayer.Gold:
        ServerState.playerGold.value = readUInt16();
        break;
      case ApiPlayer.Aim_Angle:
       GameState.player.mouseAngle = readAngle();
        break;
      case ApiPlayer.Inventory:
        readPlayerInventory();
        break;
      case ApiPlayer.Inventory_Slot:
        final index = readUInt16();
        final itemType = readUInt16();
        final itemQuantity = readUInt16();
        ServerState.inventory[index] = itemType;
        ServerState.inventoryQuantity[index] = itemQuantity;
        ClientActions.redrawInventory();
        break;
      case ApiPlayer.Message:
       GameState.player.message.value = readString();
       break;
      case ApiPlayer.Alive:
        GameState.player.alive.value = readBool();
        break;
      case ApiPlayer.Spawned:
        GameCamera.centerOnPlayer();
        GameIO.recenterCursor();
        break;
      case ApiPlayer.Attributes:
        ServerState.playerAttributes.value = readUInt16();
        break;
      default:
        throw Exception("Cannot parse apiPlayer $apiPlayer");
    }
  }

  void readPlayerInventory() {
    GamePlayer.head.value = readUInt16();
    GamePlayer.body.value = readUInt16();
    GamePlayer.legs.value = readUInt16();
    GamePlayer.weapon.value = readUInt16();
    ServerState.playerBelt1_ItemType.value = readUInt16();
    ServerState.playerBelt2_ItemType.value = readUInt16();
    ServerState.playerBelt3_ItemType.value = readUInt16();
    ServerState.playerBelt4_ItemType.value = readUInt16();
    ServerState.playerBelt5_ItemType.value = readUInt16();
    ServerState.playerBelt6_ItemType.value = readUInt16();
    ServerState.playerBelt1_Quantity.value = readUInt16();
    ServerState.playerBelt2_Quantity.value = readUInt16();
    ServerState.playerBelt3_Quantity.value = readUInt16();
    ServerState.playerBelt4_Quantity.value = readUInt16();
    ServerState.playerBelt5_Quantity.value = readUInt16();
    ServerState.playerBelt6_Quantity.value = readUInt16();
    ServerState.equippedWeaponIndex.value = readUInt16();
    final total = readUInt16();
    if (ServerState.inventory.length != total){
      ServerState.inventory = Uint16List(total);
      ServerState.inventoryQuantity = Uint16List(total);
    }
    for (var i = 0; i < total; i++){
      ServerState.inventory[i] = readUInt16();
    }
    for (var i = 0; i < total; i++){
      ServerState.inventoryQuantity[i] = readUInt16();
    }
    ClientActions.redrawInventory();
  }

  void readGameObjectStatic() {
    final gameObject = GameState.getInstanceGameObject();
    readVector3(gameObject);
    gameObject.type = readByte();
  }

  void readPlayerAttackTargetName() {
   GameState.player.mouseTargetName.value = readString();
   GameState.player.mouseTargetAllie.value = readBool();
   GameState.player.mouseTargetHealth.value = readPercentage();
  }

  void readMapCoordinate() {
   GameState.player.mapTile.value = readByte();
  }

  void readEditorGameObjectSelected() {
    readVector3(GameEditor.gameObject);
    final type = readUInt16();
    GameEditor.gameObject.type = type;
    GameEditor.gameObjectSelectedType.value = type;
    GameEditor.gameObjectSelected.value = true;
    GameEditor.cameraCenterSelectedObject();
  }

  void readCharacterRat() {
    final character = GameState.getCharacterInstance();
    character.characterType = CharacterType.Rat;
    readCharacter(character);
    GameState.totalCharacters++;
  }

  void readCharacterZombie() {
    final character = GameState.getCharacterInstance();
    character.characterType = CharacterType.Zombie;
    readCharacter(character);
    GameState.totalCharacters++;
  }

  void readCharacterSlime() {
    final character = GameState.getCharacterInstance();
    character.characterType = CharacterType.Slime;
    readCharacter(character);
    GameState.totalCharacters++;
  }

  void readCharacterTemplate() {
    final character = GameState.getCharacterInstance();
    character.characterType = CharacterType.Template;
    readCharacter(character);
    readCharacterEquipment(character);
    GameState.totalCharacters++;
  }

  void readCharacterPlayer(){
    final character = GameState.getCharacterInstance();
    final teamDirectionState = readByte();
    character.characterType = CharacterType.Template;
    readTeamDirectionState(character, teamDirectionState);
    character.x = readDouble();
    character.y = readDouble();
    character.z = readDouble();
    _parseCharacterFrameHealth(character, readByte());
    readCharacterEquipment(character);
    character.name = readString();
    character.text = readString();
    character.lookRadian = readAngle();
    character.weaponFrame = readByte();
    GameState.totalCharacters++;
  }

  void readInteractingNpcName() {
   GameState.player.interactingNpcName.value = readString();
  }

  void readPlayerQuests() {
   GameState.player.questsInProgress.value = readQuests();
   GameState.player.questsCompleted.value = readQuests();
  }

  void readNpcTalk() {
   GameState.player.npcTalk.value = readString();
    final totalOptions = readByte();
    final options = <String>[];
    for (var i = 0; i < totalOptions; i++) {
       options.add(readString());
    }
   GameState.player.npcTalkOptions.value = options;
  }

  void readSceneMetaData() {
    ServerState.sceneEditable.value = readBool();
    ServerState.sceneName.value = readString();
  }

  void readWeather() {
    ServerState.rain.value = readRain();
    ServerState.weatherBreeze.value = readBool();
    ServerState.lightning.value = readLightning();
    ServerState.watchTimePassing.value = readBool();
    ServerState.windAmbient.value = readWind();
    ServerState.ambientShade.value = readByte();
  }

  Rain readRain(){
     return rainValues[readByte()];
  }

  Wind readWind(){
    return windValues[readByte()];
  }

  Lightning readLightning(){
    return lightningValues[readByte()];
  }

  void readEnd() {
    byteLength.value = index;
    index = 0;
    Engine.redrawCanvas();
  }


  void readStoreItems() {
    final length = readUInt16();
    if (GamePlayer.storeItems.value.length != length){
      GamePlayer.storeItems.value = Uint16List(length);
    }
    for (var i = 0; i < length; i++){
      GamePlayer.storeItems.value[i] = readUInt16();
    }
  }

  void readNode() {
    final nodeIndex = readUInt16();
    final nodeType = readByte();
    final nodeOrientation = readByte();
    assert(NodeType.supportsOrientation(nodeType, nodeOrientation));
    GameNodes.nodesType[nodeIndex] = nodeType;
    GameNodes.nodesOrientation[nodeIndex] = nodeOrientation;
    GameEvents.onChangedNodes();
  }

  void readPlayerTarget() {
    readVector3(GameState.player.abilityTarget);
  }

  void readPlayerSpawned() {
   GamePlayer.position.x = readDouble();
   GamePlayer.position.y = readDouble();
   GameCamera.centerOnPlayer();
    Engine.zoom = 1.0;
    Engine.targetZoom = 1.0;
  }

  void readGameTime() {
    ServerState.hours.value = readByte();
    ServerState.minutes.value = readByte();
  }

  void readDamageApplied() {
    final x = readDouble();
    final y = readDouble() - 5;
    final amount = readInt();
    GameState.spawnFloatingText(x, y, amount.toString());
  }

  void readDebugMode() {
    GameUI.debug.value = readBool();
  }

  void readGrid() {
    GameState.nodesTotalZ = readInt();
    GameState.nodesTotalRows = readInt();
    GameState.nodesTotalColumns = readInt();
    GameState.nodesArea = GameState.nodesTotalRows * GameState.nodesTotalColumns;
    final totalNodes = GameState.nodesTotalZ * GameState.nodesTotalRows * GameState.nodesTotalColumns;
    if (GameNodes.nodesType.length < totalNodes) {
      GameNodes.nodesType = Uint8List(totalNodes);
      GameNodes.nodesOrientation = Uint8List(totalNodes);
      GameNodes.nodesShade = Uint8List(totalNodes);
      GameNodes.nodesBake = Uint8List(totalNodes);
      GameNodes.nodesWind = Uint8List(totalNodes);
      GameNodes.nodesVariation = List.generate(totalNodes, (index) => false, growable: false);
      GameNodes.nodesVisible = List.generate(totalNodes, (index) => true, growable: false);
      GameNodes.nodesVisibleIndex = Uint16List(totalNodes);
      GameNodes.nodesDynamicIndex = Uint16List(totalNodes);
    }
    GameNodes.nodesTotal = totalNodes;

    var gridIndex = 0;
    var total = 0;
    var currentRow = 0;
    var currentColumn = 0;

    while (total < totalNodes) {
      final nodeType = readByte();
      final nodeOrientation = readByte();

      if(!NodeType.supportsOrientation(nodeType, nodeOrientation)) {
         print("node type ${NodeType.getName(nodeType)} does not support orientation ${NodeOrientation.getName(nodeOrientation)}");
      }

      var count = readUInt16();
      total += count;

      while (count > 0) {
        GameNodes.nodesType[gridIndex] = nodeType;
        GameNodes.nodesOrientation[gridIndex] = nodeOrientation;

        if (nodeType == NodeType.Grass) {
          GameNodes.nodesVariation[gridIndex] = randomBool();
        }

        gridIndex++;
        count--;
        currentColumn++;
        if (currentColumn >= GameState.nodesTotalColumns) {
          currentColumn = 0;
          currentRow++;
          if (currentRow >= GameState.nodesTotalRows) {
            currentRow = 0;
          }
        }
      }
    }
    assert(total == totalNodes);
    GameEvents.onChangedNodes();
    onChangedScene();
  }

  void readPaths() {
    GameUI.debug.value = true;
    var index = 0;
    while (true) {
      final pathIndex = readInt();
      GameDebug.paths[index] = pathIndex.toDouble();
      index++;
      if (pathIndex == 250) break;
      for (var i = 0; i < pathIndex; i++) {
        GameDebug.paths[index] = readDouble();
        GameDebug.paths[index + 1] = readDouble();
        index += 2;
      }
    }
    var i = 0;

    while(readByte() != 0) {
      GameDebug.targets[i] = readDouble();
      GameDebug.targets[i + 1] = readDouble();
      GameDebug.targets[i + 2] = readDouble();
      GameDebug.targets[i + 3] = readDouble();
       i += 4;
    }
  }

  void readGameEvent(){
      final type = readByte();
      final x = readDouble();
      final y = readDouble();
      final z = readDouble();
      final angle = readDouble() * degreesToRadians;
      GameEvents.onGameEvent(type, x, y, z, angle);
  }

  void readProjectiles(){
    GameState.totalProjectiles = readInt();
    while (GameState.totalProjectiles >= GameState.projectiles.length){
      GameState.projectiles.add(Projectile());
    }
    for (var i = 0; i < GameState.totalProjectiles; i++) {
      final projectile = GameState.projectiles[i];
      projectile.x = readDouble();
      projectile.y = readDouble();
      projectile.z = readDouble();
      projectile.type = readByte();
      projectile.angle = readDouble() * degreesToRadians;
    }
  }

  void _parseCharacterTeamDirectionState(Character character){
    readTeamDirectionState(character, readByte());
  }

  void readTeamDirectionState(Character character, int byte){
    character.allie = byte >= 100;
    character.direction = ((byte % 100) ~/ 10);
    character.state = byte % 10;
  }

  void readNpcs() {
    GameState.totalNpcs = 0;
    var npcLength = GameState.npcs.length;
    while (true) {
      final stateInt = readByte();
      if (stateInt == END) break;
      if (GameState.totalNpcs >= npcLength){
        GameState.npcs.add(Character());
        npcLength++;
      }
      final npc = GameState.npcs[GameState.totalNpcs];
      readTeamDirectionState(npc, stateInt);
      npc.x = readDouble();
      npc.y = readDouble();
      npc.z = readDouble();
      _parseCharacterFrameHealth(npc, readByte());
      readCharacterEquipment(npc);
      GameState.totalNpcs++;
    }
  }

  void readCharacter(Character character){
     _parseCharacterTeamDirectionState(character);
     character.x = readDouble();
     character.y = readDouble();
     character.z = readDouble();
     _parseCharacterFrameHealth(character, readByte());
  }

  void readCharacterEquipment(Character character){
    character.weaponType = readUInt16();
    character.weaponState = readUInt16();
    character.bodyType = readUInt16();
    character.headType = readUInt16();
    character.legType = readUInt16();
  }

  void _parseCharacterFrameHealth(Character character, int byte){
    final frame = byte % 10;
    final health = (byte - frame) / 240.0;
    character.frame = frame;
    character.health = health;
  }

  int readSlotType(){
    return readByte();
  }

  void readPlayerEvent() {
    GameEvents.onPlayerEvent(readByte());
  }

  void readPosition(Position position){
    position.x = readDouble();
    position.y = readDouble();
  }

  void readVector3(Vector3 value){
    value.x = readDouble();
    value.y = readDouble();
    value.z = readDouble();
  }

  void readVector2(Vector2 value){
    value.x = readDouble();
    value.y = readDouble();
  }

  double readPercentage(){
    final value = readByte();
    if (value == 0) return 0;
     return value / 256.0;
  }

  List<Quest> readQuests(){
    final total = readInt();
    final values = <Quest>[];
    for (var i = 0; i < total; i++){
      values.add(quests[readByte()]);
    }
    return values;
  }

  double readAngle() => readDouble() * degreesToRadians;
}