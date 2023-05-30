import 'package:archive/archive.dart';
import 'package:gamestream_flutter/gamestream/games/fight2d/game_fight2d.dart';
import 'package:gamestream_flutter/isometric/events/on_changed_scene.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/structure/business/handle_server_response_game_error.dart';
import 'package:lemon_byte/byte_reader.dart';

class ServerResponseReader with ByteReader {
  final bufferSize = Watch(0);
  final bufferSizeTotal = Watch(0);
  late final updateFrame = Watch(0, onChanged: gamestream.games.isometric.clientState.onChangedUpdateFrame);
  final decoder = ZLibDecoder();

  var previousServerResponse = -1;

  void read(Uint8List values, GameFight2D gameFight2D) {
    assert (values.isNotEmpty);
    updateFrame.value++;
    index = 0;
    gamestream.games.isometric.serverState.totalCharacters = 0;
    this.values = values;
    bufferSize.value = values.length;
    bufferSizeTotal.value += values.length;

    while (true) {
      final serverResponse = readByte();
      switch (serverResponse) {
        case ServerResponse.Api_Player:
          readApiPlayer();
          break;
        case ServerResponse.Characters:
          readCharacters();
          break;
        case ServerResponse.Api_SPR:
          readServerResponseApiSPR();
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
        case ServerResponse.Api_Players:
          readApiPlayers();
          break;
        case ServerResponse.Grid:
          readNodes();
          break;
        case ServerResponse.Game_Time:
          readGameTime();
          break;
        case ServerResponse.Game_Type:
          final index = readByte();
          if (index >= GameType.values.length){
            throw Exception('invalid game type index $index');
          }
          final gameType = GameType.values[index];
          gamestream.gameType.value = gameType;
          break;
        case ServerResponse.Environment:
          readServerResponseEnvironment();
          break;
        case ServerResponse.Node:
          readNode();
          break;
        case ServerResponse.Player_Target:
          readVector3(gamestream.games.isometric.player.target);
          break;
        case ServerResponse.Store_Items:
          readStoreItems();
          break;
        case ServerResponse.Npc_Talk:
          readNpcTalk();
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
        case ServerResponse.Info:
          readServerResponseInfo();
          break;
        case ServerResponse.Dark_Age:
          final darkAgeCode = readByte();
          switch (darkAgeCode) {
            case ApiDarkAge.areaType:
              gamestream.games.isometric.serverState.areaType.value = readByte();
              break;
          }
          break;
        case ServerResponse.Fight2D:
          readServerResponseFight2D(gamestream.games.gameFight2D);
          break;
        case ServerResponse.High_Score:
          gamestream.games.isometric.serverState.highScore.value = readUInt24();
          break;
        case ServerResponse.Download_Scene:
          final name = readString();
          final length = readUInt16();
          final bytes = readBytes(length);
          engine.downloadBytes(bytes, name: '$name.scene');
          break;
        case ServerResponse.Game_Status:
          gamestream.games.isometric.serverState.gameStatus.value = readByte();
          break;
        case ServerResponse.GameObject_Deleted:
          gamestream.games.isometric.serverState.removeGameObjectById(readUInt16());
          break;
        case ServerResponse.Game_Error:
          final errorTypeIndex = readByte();
          final errorType = parseIndexToGameError(errorTypeIndex);
          handleServerResponseGameError(errorType);
          break;
        default:
          print("read error; index: $index, previous-server-response: $previousServerResponse");
          print(values);
          return;
      }
      previousServerResponse = serverResponse;
    }
  }

  void readServerResponseFight2D(GameFight2D game) {
    final fight2DResponse = readByte();
    switch (fight2DResponse) {
      case GameFight2DResponse.Characters:
        readGameFight2DResponseCharacters(game);
        break;
      case GameFight2DResponse.Player:
        final player = game.player;
        player.state = readByte();
        player.x = readInt16().toDouble();
        player.y = readInt16().toDouble();
        break;
      case GameFight2DResponse.Event:
        readFight2DEvent();
        break;
      case GameFight2DResponse.Scene:
        game.sceneWidth = readUInt16();
        game.sceneHeight = readUInt16();
        game.sceneNodes = readUint8List(game.sceneTotal);
        break;
      case GameFight2DResponse.Player_Edit:
        game.player.edit.value = readBool();
        break;
      default:
        throw Exception('unknown fight2DResponse $fight2DResponse');
    }
  }

  void readFight2DEvent() {
    final eventType = readByte();
    final x = readInt16().toDouble();
    final y = readInt16().toDouble();

    switch (eventType) {
      case GameFight2DEvents.Punch:
        gamestream.audio.playAudioSingle2D(gamestream.audio.heavy_punch_13, x, y);
        break;
      case GameFight2DEvents.Jump:
        gamestream.audio.playAudioSingle2D(gamestream.audio.jump, x, y);
        break;
      case GameFight2DEvents.Footstep:
        gamestream.audio.playAudioSingle2D(gamestream.audio.footstep_stone, x, y);
        break;
      case GameFight2DEvents.Strike_Swing:
        gamestream.audio.playAudioSingle2D(gamestream.audio.arm_swing_whoosh_11, x, y);
        break;
    }
  }

  void readMap(Map<int, int> map){
    final length = readUInt16();
    map.clear();
    for (var i = 0; i < length; i++) {
      final key = readUInt16();
      final value = readUInt16();
      map[key] = value;
    }
  }

  void readServerResponseInfo() {
    gamestream.games.isometric.serverState.setMessage(readString());
  }

  void readServerResponseEnvironment() {
    final environmentResponse = readByte();
    switch (environmentResponse) {
      case EnvironmentResponse.Rain:
        gamestream.games.isometric.serverState.rainType.value = readByte();
        break;
      case EnvironmentResponse.Lightning:
        gamestream.games.isometric.serverState.lightningType.value = readByte();
        break;
      case EnvironmentResponse.Wind:
        gamestream.games.isometric.serverState.windTypeAmbient.value = readByte();
        break;
      case EnvironmentResponse.Breeze:
        gamestream.games.isometric.serverState.weatherBreeze.value = readBool();
        break;
      case EnvironmentResponse.Underground:
        gamestream.games.isometric.serverState.sceneUnderground.value = readBool();
        break;
      case EnvironmentResponse.Lightning_Flashing:
        gamestream.games.isometric.serverState.lightningFlashing.value = readBool();
        break;
      case EnvironmentResponse.Time_Enabled:
        gamestream.games.isometric.serverState.gameTimeEnabled.value = readBool();
        break;
    }
  }

  void readGameObject() {
    final id = readUInt16();
    final gameObject = gamestream.games.isometric.serverState.findOrCreateGameObject(id);
    gameObject.active = readBool();
    gameObject.type = readUInt16();
    readVector3(gameObject);
    gamestream.games.isometric.serverState.sortGameObjects();
  }

  void readApiPlayer() {
    final apiPlayer = readByte();
    switch (apiPlayer) {
      case ApiPlayer.Position:
        readApiPlayerPosition();
        break;
      case ApiPlayer.Aim_Target_Category:
        gamestream.games.isometric.player.aimTargetCategory = readByte();
        break;
      case ApiPlayer.Aim_Target_Position:
        readVector3(gamestream.games.isometric.player.aimTargetPosition);
        break;
      case ApiPlayer.Aim_Target_Type:
        gamestream.games.isometric.player.aimTargetType = readUInt16();
        break;
      case ApiPlayer.Aim_Target_Quantity:
        gamestream.games.isometric.player.aimTargetQuantity = readUInt16();
        break;
      case ApiPlayer.Aim_Target_Name:
        gamestream.games.isometric.player.aimTargetName = readString();
        break;
      case ApiPlayer.Power:
        gamestream.games.isometric.player.powerType.value = readByte();
        gamestream.games.isometric.player.powerReady.value = readBool();
        break;
      case ApiPlayer.Respawn_Timer:
        gamestream.games.isometric.player.respawnTimer.value = readUInt16();
        break;
      case ApiPlayer.PerkType:
        gamestream.games.isometric.player.perkType.value = readByte();
        break;
      case ApiPlayer.Target_Position:
        gamestream.games.isometric.player.runningToTarget = true;
        readVector3(gamestream.games.isometric.player.targetPosition);
        break;
      case ApiPlayer.Target_Category:
        gamestream.games.isometric.player.targetCategory = readByte();
        break;
      case ApiPlayer.Experience_Percentage:
        gamestream.games.isometric.serverState.playerExperiencePercentage.value = readPercentage();
        break;
      case ApiPlayer.Interact_Mode:
        gamestream.games.isometric.serverState.interactMode.value = readByte();
        break;
      case ApiPlayer.Health:
        readPlayerHealth();
        break;
      case ApiPlayer.Weapon_Cooldown:
        gamestream.games.isometric.player.weaponCooldown.value = readPercentage();
        break;
      case ApiPlayer.Accuracy:
        gamestream.games.isometric.serverState.playerAccuracy.value = readPercentage();
        break;
      case ApiPlayer.Level:
        gamestream.games.isometric.serverState.playerLevel.value = readUInt16();
        break;
      case ApiPlayer.Attributes:
        gamestream.games.isometric.serverState.playerAttributes.value = readUInt16();
        break;
      case ApiPlayer.Credits:
        gamestream.games.isometric.serverState.playerCredits.value = readUInt16();
        break;
      case ApiPlayer.Energy:
        // gamestream.games.isometric.player.energy.value = readUInt16();
        // gamestream.games.isometric.player.energyMax.value = readUInt16();
        readApiPlayerEnergy();
        break;
      case ApiPlayer.Weapons:
        readPlayerWeapons();
        break;
      // case ApiPlayer.Weapon_Quantity:
      //   readPlayerWeaponQuantity();
      //   break;
      case ApiPlayer.Aim_Angle:
        gamestream.games.isometric.player.mouseAngle = readAngle();
        break;
      case ApiPlayer.Inventory:
        readPlayerInventory();
        break;
      case ApiPlayer.Inventory_Slot:
        final index = readUInt16();
        final itemType = readUInt16();
        final itemQuantity = readUInt16();

        if (index == ItemType.Belt_1){
          gamestream.games.isometric.serverState.playerBelt1_ItemType.value = itemType;
          gamestream.games.isometric.serverState.playerBelt1_Quantity.value = itemQuantity;
          ClientActions.redrawInventory();
          return;
        }
        if (index == ItemType.Belt_2){
          gamestream.games.isometric.serverState.playerBelt2_ItemType.value = itemType;
          gamestream.games.isometric.serverState.playerBelt2_Quantity.value = itemQuantity;
          ClientActions.redrawInventory();
          return;
        }
        if (index == ItemType.Belt_3){
          gamestream.games.isometric.serverState.playerBelt3_ItemType.value = itemType;
          gamestream.games.isometric.serverState.playerBelt3_Quantity.value = itemQuantity;
          ClientActions.redrawInventory();
          return;
        }
        if (index == ItemType.Belt_4){
          gamestream.games.isometric.serverState.playerBelt4_ItemType.value = itemType;
          gamestream.games.isometric.serverState.playerBelt4_Quantity.value = itemQuantity;
          ClientActions.redrawInventory();
          return;
        }
        if (index == ItemType.Belt_5){
          gamestream.games.isometric.serverState.playerBelt5_ItemType.value = itemType;
          gamestream.games.isometric.serverState.playerBelt5_Quantity.value = itemQuantity;
          ClientActions.redrawInventory();
          return;
        }
        if (index == ItemType.Belt_6){
          gamestream.games.isometric.serverState.playerBelt6_ItemType.value = itemType;
          gamestream.games.isometric.serverState.playerBelt6_Quantity.value = itemQuantity;
          ClientActions.redrawInventory();
          return;
        }
        gamestream.games.isometric.serverState.inventory[index] = itemType;
        gamestream.games.isometric.serverState.inventoryQuantity[index] = itemQuantity;
        ClientActions.redrawInventory();
        break;
      case ApiPlayer.Message:
        gamestream.games.isometric.player.message.value = readString();
        break;
      case ApiPlayer.Alive:
        gamestream.games.isometric.player.alive.value = readBool();
        ClientActions.clearHoverDialogType();
        break;
      case ApiPlayer.Spawned:
        gamestream.games.isometric.camera.centerOnPlayer();
        gamestream.io.recenterCursor();
        break;
      case ApiPlayer.Damage:
        gamestream.games.isometric.serverState.playerDamage.value = readUInt16();
        break;
      case ApiPlayer.Items:
        readMap(gamestream.games.isometric.player.items);
        gamestream.games.isometric.player.Refresh_Items();
        break;
      case ApiPlayer.Equipment:
        readPlayerEquipped();
        break;
      case ApiPlayer.Grenades:
        gamestream.games.isometric.player.totalGrenades.value = readUInt16();
        break;
      case ApiPlayer.Id:
        gamestream.games.isometric.player.id.value = readUInt24();
        break;
      case ApiPlayer.Active:
        gamestream.games.isometric.player.active.value = readBool();
        break;
      case ApiPlayer.Attribute_Values:
        gamestream.games.isometric.player.attributeHealth.value = readUInt16();
        gamestream.games.isometric.player.attributeDamage.value = readUInt16();
        gamestream.games.isometric.player.attributeMagic.value = readUInt16();
        break;
      default:
        throw Exception("Cannot parse apiPlayer $apiPlayer");
    }
  }

  void readApiPlayerPosition(){
    gamestream.games.isometric.player.previousPosition.x = gamestream.games.isometric.player.position.x;
    gamestream.games.isometric.player.previousPosition.y = gamestream.games.isometric.player.position.y;
    gamestream.games.isometric.player.previousPosition.z = gamestream.games.isometric.player.position.z;
    readVector3(gamestream.games.isometric.player.position);
    gamestream.games.isometric.player.indexColumn = gamestream.games.isometric.player.position.indexColumn;
    gamestream.games.isometric.player.indexRow = gamestream.games.isometric.player.position.indexRow;
    gamestream.games.isometric.player.indexZ = gamestream.games.isometric.player.position.indexZ;
    gamestream.games.isometric.player.nodeIndex = gamestream.games.isometric.player.position.nodeIndex;
  }

  void readApiPlayerEnergy() =>
      gamestream.games.isometric.player.energyPercentage = readPercentage();

  void readPlayerWeapons() {
    gamestream.games.isometric.player.weapon.value = readUInt16();

    gamestream.games.isometric.player.weaponPrimary.value           = readUInt16();
    // gamestream.games.isometric.player.weaponPrimaryQuantity.value   = readUInt16();
    // gamestream.games.isometric.player.weaponPrimaryCapacity.value   = readUInt16();
    // gamestream.games.isometric.player.weaponPrimaryLevel.value      = readUInt8();

    gamestream.games.isometric.player.weaponSecondary.value         = readUInt16();
    // gamestream.games.isometric.player.weaponSecondaryQuantity.value = readUInt16();
    // gamestream.games.isometric.player.weaponSecondaryCapacity.value = readUInt16();
    // gamestream.games.isometric.player.weaponSecondaryLevel.value    = readUInt8();
  }

  // void readPlayerWeaponQuantity() {
  //   gamestream.games.isometric.player.weaponPrimaryQuantity.value   = readUInt16();
  //   gamestream.games.isometric.player.weaponSecondaryQuantity.value = readUInt16();
  // }

  void readPlayerEquipped() {
    gamestream.games.isometric.player.weapon.value = readUInt16();
    gamestream.games.isometric.player.head.value = readUInt16();
    gamestream.games.isometric.player.body.value = readUInt16();
    gamestream.games.isometric.player.legs.value = readUInt16();
  }

  void readPlayerHealth() {
    gamestream.games.isometric.serverState.playerHealth.value = readUInt16();
    gamestream.games.isometric.serverState.playerMaxHealth.value = readUInt16();
  }

  void readPlayerInventory() {
    gamestream.games.isometric.player.head.value = readUInt16();
    gamestream.games.isometric.player.body.value = readUInt16();
    gamestream.games.isometric.player.legs.value = readUInt16();
    gamestream.games.isometric.player.weapon.value = readUInt16();
    gamestream.games.isometric.serverState.playerBelt1_ItemType.value = readUInt16();
    gamestream.games.isometric.serverState.playerBelt2_ItemType.value = readUInt16();
    gamestream.games.isometric.serverState.playerBelt3_ItemType.value = readUInt16();
    gamestream.games.isometric.serverState.playerBelt4_ItemType.value = readUInt16();
    gamestream.games.isometric.serverState.playerBelt5_ItemType.value = readUInt16();
    gamestream.games.isometric.serverState.playerBelt6_ItemType.value = readUInt16();
    gamestream.games.isometric.serverState.playerBelt1_Quantity.value = readUInt16();
    gamestream.games.isometric.serverState.playerBelt2_Quantity.value = readUInt16();
    gamestream.games.isometric.serverState.playerBelt3_Quantity.value = readUInt16();
    gamestream.games.isometric.serverState.playerBelt4_Quantity.value = readUInt16();
    gamestream.games.isometric.serverState.playerBelt5_Quantity.value = readUInt16();
    gamestream.games.isometric.serverState.playerBelt6_Quantity.value = readUInt16();
    gamestream.games.isometric.serverState.equippedWeaponIndex.value = readUInt16();
    final total = readUInt16();
    if (gamestream.games.isometric.serverState.inventory.length != total){
      gamestream.games.isometric.serverState.inventory = Uint16List(total);
      gamestream.games.isometric.serverState.inventoryQuantity = Uint16List(total);
    }
    for (var i = 0; i < total; i++){
      gamestream.games.isometric.serverState.inventory[i] = readUInt16();
    }
    for (var i = 0; i < total; i++){
      gamestream.games.isometric.serverState.inventoryQuantity[i] = readUInt16();
    }
    ClientActions.redrawInventory();
  }

  void readMapCoordinate() {
    readByte(); // DO NOT DELETE
  }

  void readEditorGameObjectSelected() {
    // readVector3(gamestream.games.isometric.editor.gameObject);

    final id = readUInt16();
    final gameObject = gamestream.games.isometric.serverState.findGameObjectById(id);
    if (gameObject == null) throw Exception("could not find gameobject with id $id");
    gamestream.games.isometric.editor.gameObject.value = gameObject;
    gamestream.games.isometric.editor.gameObjectSelectedCollidable   .value = readBool();
    gamestream.games.isometric.editor.gameObjectSelectedFixed        .value = readBool();
    gamestream.games.isometric.editor.gameObjectSelectedCollectable  .value = readBool();
    gamestream.games.isometric.editor.gameObjectSelectedPhysical     .value = readBool();
    gamestream.games.isometric.editor.gameObjectSelectedPersistable  .value = readBool();
    gamestream.games.isometric.editor.gameObjectSelectedGravity      .value = readBool();

    gamestream.games.isometric.editor.gameObjectSelectedType.value          = gameObject.type;
    gamestream.games.isometric.editor.gameObjectSelected.value              = true;
    gamestream.games.isometric.editor.cameraCenterSelectedObject();

    gamestream.games.isometric.editor.gameObjectSelectedEmission.value = gameObject.emission_type;
    gamestream.games.isometric.editor.gameObjectSelectedEmissionIntensity.value = gameObject.emission_intensity;
  }

  void readCharacters(){
     while (true) {
      final characterType = readByte();
      if (characterType == END) return;
      final character = gamestream.games.isometric.serverState.getCharacterInstance();

      character.characterType = characterType;
      readCharacterTeamDirectionAndState(character);
      readVector3(character);
      readCharacterHealthAndAnimationFrame(character);

      if (CharacterType.supportsUpperBody(characterType)){
        readCharacterUpperBody(character);
      }

      character.buff = readUInt8();
      gamestream.games.isometric.serverState.totalCharacters++;
    }
  }

  void readNpcTalk() {
    gamestream.games.isometric.player.npcTalk.value = readString();
    final totalOptions = readByte();
    final options = <String>[];
    for (var i = 0; i < totalOptions; i++) {
       options.add(readString());
    }
    gamestream.games.isometric.player.npcTalkOptions.value = options;
  }

  void readGameProperties() {
    gamestream.games.isometric.serverState.sceneEditable.value = readBool();
    gamestream.games.isometric.serverState.sceneName.value = readString();
    gamestream.games.isometric.serverState.gameRunning.value = readBool();
  }

  void readWeather() {
    gamestream.games.isometric.serverState.rainType.value = readByte();
    gamestream.games.isometric.serverState.weatherBreeze.value = readBool();
    gamestream.games.isometric.serverState.lightningType.value = readByte();
    gamestream.games.isometric.serverState.windTypeAmbient.value = readByte();
  }

  void readEnd() {
    bufferSize.value = index;
    index = 0;
    engine.redrawCanvas();
  }

  void readStoreItems() {
    final length = readUInt16();
    if (gamestream.games.isometric.player.storeItems.value.length != length){
      gamestream.games.isometric.player.storeItems.value = Uint16List(length);
    }
    for (var i = 0; i < length; i++){
      gamestream.games.isometric.player.storeItems.value[i] = readUInt16();
    }
  }

  void readNode() {
    final nodeIndex = readUInt24();
    final nodeType = readByte();
    final nodeOrientation = readByte();
    assert(NodeType.supportsOrientation(nodeType, nodeOrientation));
    gamestream.games.isometric.nodes.nodeTypes[nodeIndex] = nodeType;
    gamestream.games.isometric.nodes.nodeOrientations[nodeIndex] = nodeOrientation;
    /// TODO optimize
    GameEvents.onChangedNodes();
    gamestream.games.isometric.editor.refreshNodeSelectedIndex();
  }

  void readPlayerTarget() {
    readVector3(gamestream.games.isometric.player.abilityTarget);
  }

  void readGameTime() {
    gamestream.games.isometric.serverState.seconds.value = readUInt24();

  }

  void readNodes() {
    final scenePart = readByte(); /// DO NOT DELETE
    gamestream.games.isometric.nodes.totalZ = readUInt16();
    gamestream.games.isometric.nodes.totalRows = readUInt16();
    gamestream.games.isometric.nodes.totalColumns = readUInt16();

    final compressedNodeTypeLength = readUInt24();
    final compressedNodeOrientationsLength = readUInt24();
    
    final compressedNodeTypes = readUint8List(compressedNodeTypeLength);
    final compressedNodeOrientations = readUint8List(compressedNodeOrientationsLength);
    final nodeTypes = decoder.decodeBytes(compressedNodeTypes);

    gamestream.games.isometric.nodes.nodeTypes = Uint8List.fromList(nodeTypes);
    gamestream.games.isometric.nodes.nodeOrientations = Uint8List.fromList(decoder.decodeBytes(compressedNodeOrientations));
    gamestream.games.isometric.nodes.area = gamestream.games.isometric.nodes.totalRows * gamestream.games.isometric.nodes.totalColumns;
    gamestream.games.isometric.nodes.area2 = gamestream.games.isometric.nodes.area * 2;
    gamestream.games.isometric.nodes.projection = gamestream.games.isometric.nodes.area2 + gamestream.games.isometric.nodes.totalColumns + 1;
    gamestream.games.isometric.nodes.projectionHalf =  gamestream.games.isometric.nodes.projection ~/ 2;
    final totalNodes = gamestream.games.isometric.nodes.totalZ * gamestream.games.isometric.nodes.totalRows * gamestream.games.isometric.nodes.totalColumns;
    gamestream.games.isometric.nodes.colorStack = Uint16List(totalNodes);
    gamestream.games.isometric.nodes.ambientStack = Uint16List(totalNodes);
    gamestream.games.isometric.nodes.total = totalNodes;
    gamestream.games.isometric.clientState.nodesRaycast = gamestream.games.isometric.nodes.area +  gamestream.games.isometric.nodes.area + gamestream.games.isometric.nodes.totalColumns + 1;
    GameEvents.onChangedNodes();
    gamestream.games.isometric.nodes.refreshNodeVariations();
    gamestream.games.isometric.clientState.sceneChanged.value++;
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
    gamestream.games.isometric.serverState.totalProjectiles = readUInt16();
    while (gamestream.games.isometric.serverState.totalProjectiles >= gamestream.games.isometric.serverState.projectiles.length){
      gamestream.games.isometric.serverState.projectiles.add(Projectile());
    }
    for (var i = 0; i < gamestream.games.isometric.serverState.totalProjectiles; i++) {
      final projectile = gamestream.games.isometric.serverState.projectiles[i];
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

  double readPercentage() => readByte() / 255.0;

  List<Quest> readQuests(){
    final total = readUInt16();
    final values = <Quest>[];
    for (var i = 0; i < total; i++){
      values.add(quests[readByte()]);
    }
    return values;
  }

  double readAngle() => readDouble() * degreesToRadians;

  Map<int, List<int>> readMapListInt(){
    final valueMap = <int, List<int>> {};
    final totalEntries = readUInt16();
    for (var i = 0; i < totalEntries; i++) {
      final key = readUInt16();
      final valueLength = readUInt16();
      final values = readUint16List(valueLength);
      valueMap[key] = values;
    }
    return valueMap;
  }

  void readApiPlayers() {
    switch (readUInt8()) {
      case ApiPlayers.All:
        readApiPlayersAll();
        break;
      case ApiPlayers.Score:
        readApiPlayersScore();
        break;
      default:
        throw Exception('readApiPlayers()');
    }
  }

  void readApiPlayersAll() {
     final total = readUInt16();
     gamestream.games.isometric.serverState.playerScores.clear();
     for (var i = 0; i < total; i++) {
       final id = readUInt24();
       final name = readString();
       final credits = readUInt24();
       gamestream.games.isometric.serverState.playerScores.add(
         PlayerScore(
           id: id,
           name: name,
           credits: credits,
         )
       );
     }
     gamestream.games.isometric.serverState.sortPlayerScores();
     gamestream.games.isometric.serverState.playerScoresReads.value++;
  }

  void readApiPlayersScore() {
    final id = readUInt24();
    final credits = readUInt24();

    for (final player in gamestream.games.isometric.serverState.playerScores) {
      if (player.id != id) continue;
      player.credits = credits;
      break;
    }
    gamestream.games.isometric.serverState.sortPlayerScores();
    gamestream.games.isometric.serverState.playerScoresReads.value++;
  }

  void readServerResponseApiSPR() {
     switch (readByte()){
       case ApiSPR.Player_Positions:
         GameScissorsPaperRock.playerTeam = readByte();
         GameScissorsPaperRock.playerX = readDouble();
         GameScissorsPaperRock.playerY = readDouble();

         final total = readUInt16();
         GameScissorsPaperRock.totalPlayers = total;
         for (var i = 0; i < total; i++) {
           final player     = GameScissorsPaperRock.players[i];
           player.team      = readUInt8();
           player.x         = readInt16().toDouble();
           player.y         = readInt16().toDouble();
           player.targetX   = readInt16().toDouble();
           player.targetY   = readInt16().toDouble();
         }
         break;
     }
  }

  void readGameFight2DResponseCharacters(GameFight2D game) {
    final totalPlayers = readUInt16();
    assert (totalPlayers < GameFight2D.length);
    game.charactersTotal = totalPlayers;
    for (var i = 0; i < totalPlayers; i++) {
      game.characterState[i] = readByte();
      game.characterDirection[i] = readByte();
      game.characterDamage[i] = readUInt16();
      game.characterPositionX[i] = readInt16().toDouble();
      game.characterPositionY[i] = readInt16().toDouble();
      game.characterStateDuration[i] = readByte();
    }
  }
}
