import 'package:gamestream_flutter/isometric/events/on_changed_scene.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:lemon_byte/byte_reader.dart';

final serverResponseReader = ServerResponseReader();

class ServerResponseReader with ByteReader {
  final byteLength = Watch(0);
  final bufferSize = Watch(0);
  final updateFrame = Watch(0, onChanged: GameState.onChangedUpdateFrame);

  void read(Uint8List values) {
    updateFrame.value++;
    index = 0;
    ServerState.totalCharacters = 0;
    ServerState.totalGameObjects = 0;
    this.values = values;
    bufferSize.value = values.length;

    while (true) {
      switch (readByte()) {
        case ServerResponse.Player:
          readApiPlayer();
          break;
        case ServerResponse.Characters:
          readCharacters();
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
          readNodes();
          break;
        case ServerResponse.Game_Time:
          readGameTime();
          break;
        case ServerResponse.Game_Type:
          ServerState.gameType.value = readByte();
          break;
        case ServerResponse.Environment:
          readServerResponseEnvironment();
          break;
        case ServerResponse.Node:
          readNode();
          break;
        case ServerResponse.Player_Target:
          readVector3(GamePlayer.target);
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
        case ServerResponse.Game_Properties:
          readGameProperties();
          break;
        case ServerResponse.Map_Coordinate:
          readMapCoordinate();
          break;
        case ServerResponse.Editor_GameObject_Selected:
          readEditorGameObjectSelected();
          break;
        case ServerResponse.Render_Map:
          GameUI.mapVisible.value = readBool();
          break;
        case ServerResponse.Error:
          readServerResponseError();
          break;
        case ServerResponse.Dark_Age:
          final darkAgeCode = readByte();
          switch (darkAgeCode) {
            case ApiDarkAge.areaType:
              ServerState.areaType.value = readByte();
              break;
          }
          break;
        case ServerResponse.Download_Scene:
          final name = readString();
          final length = readUInt16();
          final bytes = readBytes(length);
          Engine.downloadBytes(bytes, name: '$name.scene');
          break;
        case ServerResponse.Game_Status:
          ServerState.gameStatus.value = readByte();
          break;
        default:
          if (debugging) {
            return;
          }
          print(values);
          debugging = true;
          read(values);
          GameNetwork.disconnect();
          WebsiteState.error.value = "An error occurred";
          return;
      }
    }
  }

  void readServerResponseError() {
    ServerState.error.value = "";
    ServerState.error.value = readString();
  }

  var debugging = false;

  void readServerResponseEnvironment() {
    final environmentResponse = readByte();
    switch (environmentResponse) {
      case EnvironmentResponse.Rain:
        ServerState.rainType.value = readByte();
        break;
      case EnvironmentResponse.Lightning:
        ServerState.lightningType.value = readByte();
        break;
      case EnvironmentResponse.Wind:
        ServerState.windTypeAmbient.value = readByte();
        break;
      case EnvironmentResponse.Breeze:
        ServerState.weatherBreeze.value = readBool();
        break;
      case EnvironmentResponse.Underground:
        ServerState.sceneUnderground.value = readBool();
        break;
      case EnvironmentResponse.Lightning_Flashing:
        ServerState.lightningFlashing.value = readBool();
        break;
      case EnvironmentResponse.Time_Enabled:
        ServerState.gameTimeEnabled.value = readBool();
        break;
    }
  }

  void readGameObject() {
    final instance = ServerState.getInstanceGameObject();
    instance.type = readUInt16();
    readVector3(instance);
  }

  void readApiPlayer() {
    final apiPlayer = readByte();
    switch (apiPlayer) {
      case ApiPlayer.Position:
        GamePlayer.previousPosition.x = GamePlayer.position.x;
        GamePlayer.previousPosition.y = GamePlayer.position.y;
        GamePlayer.previousPosition.z = GamePlayer.position.z;
        readVector3(GamePlayer.position);
        GamePlayer.indexColumn = GamePlayer.position.indexColumn;
        GamePlayer.indexRow = GamePlayer.position.indexRow;
        GamePlayer.indexZ = GamePlayer.position.indexZ;
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
        readPlayerHealth();
        break;
      case ApiPlayer.Max_Health:
        readPlayerMaxHealth();
        break;
      case ApiPlayer.Weapon_Cooldown:
        GamePlayer.weaponCooldown.value = readPercentage();
        break;
      case ApiPlayer.Accuracy:
        ServerState.playerAccuracy.value = readPercentage();
        break;
      case ApiPlayer.Level:
        ServerState.playerLevel.value = readUInt16();
        break;
      case ApiPlayer.Gold:
        ServerState.playerGold.value = readUInt16();
        break;
      case ApiPlayer.Energy:
        GamePlayer.energy.value = readUInt16();
        GamePlayer.energyMax.value = readUInt16();
        break;
      case ApiPlayer.Aim_Angle:
        GamePlayer.mouseAngle = readAngle();
        break;
      case ApiPlayer.Inventory:
        readPlayerInventory();
        break;
      case ApiPlayer.Inventory_Slot:
        final index = readUInt16();
        final itemType = readUInt16();
        final itemQuantity = readUInt16();

        if (index == ItemType.Belt_1){
          ServerState.playerBelt1_ItemType.value = itemType;
          ServerState.playerBelt1_Quantity.value = itemQuantity;
          ClientActions.redrawInventory();
          return;
        }
        if (index == ItemType.Belt_2){
          ServerState.playerBelt2_ItemType.value = itemType;
          ServerState.playerBelt2_Quantity.value = itemQuantity;
          ClientActions.redrawInventory();
          return;
        }
        if (index == ItemType.Belt_3){
          ServerState.playerBelt3_ItemType.value = itemType;
          ServerState.playerBelt3_Quantity.value = itemQuantity;
          ClientActions.redrawInventory();
          return;
        }
        if (index == ItemType.Belt_4){
          ServerState.playerBelt4_ItemType.value = itemType;
          ServerState.playerBelt4_Quantity.value = itemQuantity;
          ClientActions.redrawInventory();
          return;
        }
        if (index == ItemType.Belt_5){
          ServerState.playerBelt5_ItemType.value = itemType;
          ServerState.playerBelt5_Quantity.value = itemQuantity;
          ClientActions.redrawInventory();
          return;
        }
        if (index == ItemType.Belt_6){
          ServerState.playerBelt6_ItemType.value = itemType;
          ServerState.playerBelt6_Quantity.value = itemQuantity;
          ClientActions.redrawInventory();
          return;
        }
        ServerState.inventory[index] = itemType;
        ServerState.inventoryQuantity[index] = itemQuantity;
        ClientActions.redrawInventory();
        break;
      case ApiPlayer.Message:
        GamePlayer.message.value = readString();
        break;
      case ApiPlayer.Alive:
        GamePlayer.alive.value = readBool();
        ClientActions.clearHoverDialogType();
        break;
      case ApiPlayer.Spawned:
        GameCamera.centerOnPlayer();
        GameIO.recenterCursor();
        break;
      case ApiPlayer.Attributes:
        ServerState.playerAttributes.value = readUInt16();
        break;
      case ApiPlayer.Damage:
        ServerState.playerDamage.value = readUInt16();
        break;
      case ApiPlayer.Base_Damage_Health_Energy:
        ServerState.playerBaseDamage.value = readUInt16();
        ServerState.playerBaseHealth.value = readUInt16();
        ServerState.playerBaseEnergy.value = readUInt16();
        break;
      case ApiPlayer.Perks:
        ServerState.playerPerkMaxHealth.value = readByte();
        ServerState.playerPerkMaxDamage.value = readByte();
        break;
      case ApiPlayer.Select_Hero:
        ServerState.playerSelectHero.value = readBool();
        break;
      default:
        throw Exception("Cannot parse apiPlayer $apiPlayer");
    }
  }

  void readPlayerMaxHealth() {
    ServerState.playerMaxHealth.value = readUInt16();
  }

  void readPlayerHealth() {
    ServerState.playerHealth.value = readUInt16();
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

  void readPlayerAttackTargetName() {
    GamePlayer.mouseTargetName.value = readString();
    GamePlayer.mouseTargetAllie.value = readBool();
    GamePlayer.mouseTargetHealth.value = readPercentage();
  }

  void readMapCoordinate() {
    GamePlayer.mapTile.value = readByte();
  }

  void readEditorGameObjectSelected() {
    readVector3(GameEditor.gameObject);
    final type                                       = readUInt16();
    GameEditor.gameObjectSelectedCollidable   .value = readBool();
    GameEditor.gameObjectSelectedMovable      .value = readBool();
    GameEditor.gameObjectSelectedCollectable  .value = readBool();
    GameEditor.gameObjectSelectedPhysical     .value = readBool();
    GameEditor.gameObjectSelectedPersistable  .value = readBool();
    GameEditor.gameObject.type                       = type;
    GameEditor.gameObjectSelectedType.value          = type;
    GameEditor.gameObjectSelected.value              = true;
    GameEditor.cameraCenterSelectedObject();
  }

  void readCharacters(){
     while (true) {
      final characterType = readByte();
      if (characterType == END) return;
      final character = ServerState.getCharacterInstance();

      character.characterType = characterType;
      readCharacterTeamDirectionAndState(character);
      readVector3(character);
      readCharacterHealthAndAnimationFrame(character);

      if (CharacterType.supportsUpperBody(characterType)){
        readCharacterUpperBody(character);
      }
      ServerState.totalCharacters++;
    }
  }

  void readPlayerQuests() {
    GamePlayer.questsInProgress.value = readQuests();
    GamePlayer.questsCompleted.value = readQuests();
  }

  void readNpcTalk() {
    GamePlayer.npcTalk.value = readString();
    final totalOptions = readByte();
    final options = <String>[];
    for (var i = 0; i < totalOptions; i++) {
       options.add(readString());
    }
    GamePlayer.npcTalkOptions.value = options;
  }

  void readGameProperties() {
    ServerState.sceneEditable.value = readBool();
    ServerState.sceneName.value = readString();
    ServerState.gameRunning.value = readBool();
  }

  void readWeather() {
    ServerState.rainType.value = readByte();
    ServerState.weatherBreeze.value = readBool();
    ServerState.lightningType.value = readByte();
    // ServerState.watchTimePassing.value = readBool();
    ServerState.windTypeAmbient.value = readByte();
    // readByte(); // ambient shade DO NOT DELETE
    // ServerState.ambientShade.value = readByte();
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
    final nodeIndex = readUInt24();
    final nodeType = readByte();
    final nodeOrientation = readByte();
    assert(NodeType.supportsOrientation(nodeType, nodeOrientation));
    GameNodes.nodeTypes[nodeIndex] = nodeType;
    GameNodes.nodeOrientations[nodeIndex] = nodeOrientation;
    GameEvents.onChangedNodes();
    GameEditor.refreshNodeSelectedIndex();
  }

  void readPlayerTarget() {
    readVector3(GamePlayer.abilityTarget);
  }

  void readGameTime() {
    ServerState.hours.value = readByte();
    ServerState.minutes.value = readByte();
  }

  void readNodes() {
    final scenePart = readByte(); /// DO NOT DELETE
    GameState.nodesTotalZ = readUInt16();
    GameState.nodesTotalRows = readUInt16();
    GameState.nodesTotalColumns = readUInt16();
    GameNodes.area = GameState.nodesTotalRows * GameState.nodesTotalColumns;
    GameNodes.area2 = GameNodes.area * 2;
    GameNodes.projection = GameNodes.area2 + GameState.nodesTotalColumns + 1;
    GameNodes.projectionHalf =  GameNodes.projection ~/ 2;
    final totalNodes = GameState.nodesTotalZ * GameState.nodesTotalRows * GameState.nodesTotalColumns;
    if (GameNodes.nodeTypes.length < totalNodes) {
      GameNodes.nodeTypes = Uint8List(totalNodes);
      GameNodes.nodeOrientations = Uint8List(totalNodes);
      GameNodes.nodeWind = Uint8List(totalNodes);
      GameNodes.nodeVariations = Uint8List(totalNodes);
      GameNodes.nodeVisible = Uint8List(totalNodes);
      GameNodes.nodeVisibleIndex = Uint16List(totalNodes);
      GameNodes.nodeDynamicIndex = Uint16List(totalNodes);
    }
    GameNodes.total = totalNodes;
    GameState.nodesRaycast = GameNodes.area +  GameNodes.area + GameState.nodesTotalColumns + 1;

    var gridIndex = 0;
    var total = 0;
    var currentRow = 0;
    var currentColumn = 0;

    while (total < totalNodes) {
      final nodeType = readByte();
      final nodeOrientation = readByte();
      assert (NodeType.supportsOrientation(nodeType, nodeOrientation));

      var count = readUInt16();
      total += count;

      while (count > 0) {
        GameNodes.nodeTypes[gridIndex] = nodeType;
        GameNodes.nodeOrientations[gridIndex] = nodeOrientation;

        if (nodeType == NodeType.Tree_Bottom) {
          GameNodes.nodeVariations[gridIndex] = randomInt(0, 2);
        } else
        if (nodeType == NodeType.Grass) {
          GameNodes.nodeVariations[gridIndex] = randomInt(0, 4);
        } else
        if (nodeType == NodeType.Shopping_Shelf) {
          GameNodes.nodeVariations[gridIndex] = randomInt(0, 2);
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
    ClientState.sceneChanged.value++;
    onChangedScene();
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
    ServerState.totalProjectiles = readUInt16();
    while (ServerState.totalProjectiles >= ServerState.projectiles.length){
      ServerState.projectiles.add(Projectile());
    }
    for (var i = 0; i < ServerState.totalProjectiles; i++) {
      final projectile = ServerState.projectiles[i];
      projectile.x = readDouble();
      projectile.y = readDouble();
      projectile.z = readDouble();
      projectile.type = readByte();
      projectile.angle = readDouble() * degreesToRadians;
    }
  }

  void readCharacterTeamDirectionAndState(Character character){
    final byte = readByte();
    character.allie = byte >= 100;
    character.direction = ((byte % 100) ~/ 10);
    character.state = byte % 10;
  }

  void readCharacterUpperBody(Character character){
    character.weaponType = readUInt16();
    character.weaponState = readUInt16();
    character.bodyType = readUInt16();
    character.headType = readUInt16();
    character.legType = readUInt16();
    character.lookRadian = readAngle();
    character.weaponFrame = readByte();
  }

  // todo optimize
  void readCharacterHealthAndAnimationFrame(Character character){
    final byte = readByte();
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
     return value / 256.0; // todo optimize
  }

  List<Quest> readQuests(){
    final total = readUInt16();
    final values = <Quest>[];
    for (var i = 0; i < total; i++){
      values.add(quests[readByte()]);
    }
    return values;
  }

  double readAngle() => readDouble() * degreesToRadians;
}