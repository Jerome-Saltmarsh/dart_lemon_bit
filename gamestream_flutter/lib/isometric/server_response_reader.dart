import 'package:archive/archive.dart';
import 'package:gamestream_flutter/engine/games/game_fight2d.dart';
import 'package:gamestream_flutter/isometric/events/on_changed_scene.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/structure/business/handle_server_response_game_error.dart';
import 'package:lemon_byte/byte_reader.dart';
import 'package:bleed_common/src/fight2d/game_fight2d_events.dart';

import '../engine/instances.dart';

class ServerResponseReader with ByteReader {
  final bufferSize = Watch(0);
  final bufferSizeTotal = Watch(0);
  final updateFrame = Watch(0, onChanged: GameState.onChangedUpdateFrame);
  final decoder = ZLibDecoder();

  var previousServerResponse = -1;

  void read(Uint8List values, GameFight2D gameFight2D) {
    assert (values.isNotEmpty);
    updateFrame.value++;
    index = 0;
    ServerState.totalCharacters = 0;
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
          readVector3(GamePlayer.target);
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
              ServerState.areaType.value = readByte();
              break;
          }
          break;
        case ServerResponse.Fight2D:
          readServerResponseFight2D(gamestream.gameFight2D);
          break;
        case ServerResponse.High_Score:
          ServerState.highScore.value = readUInt24();
          break;
        case ServerResponse.Download_Scene:
          final name = readString();
          final length = readUInt16();
          final bytes = readBytes(length);
          engine.downloadBytes(bytes, name: '$name.scene');
          break;
        case ServerResponse.Game_Status:
          ServerState.gameStatus.value = readByte();
          break;
        case ServerResponse.GameObject_Deleted:
          ServerState.removeGameObjectById(readUInt16());
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
      case Fight2DResponse.Characters:
        readFight2DResponseCharacters(game);
        break;
      case Fight2DResponse.Player:
        final player = game.player;
        player.state = readByte();
        player.x = readInt16().toDouble();
        player.y = readInt16().toDouble();
        break;
      case Fight2DResponse.Event:
        readFight2DEvent();
        break;
      case Fight2DResponse.Scene:
        game.sceneWidth = readUInt16();
        game.sceneHeight = readUInt16();
        game.sceneNodes = readUint8List(game.sceneTotal);
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
    ServerState.setMessage(readString());
  }

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
    final id = readUInt16();
    final gameObject = ServerState.findOrCreateGameObject(id);
    gameObject.active = readBool();
    gameObject.type = readUInt16();
    readVector3(gameObject);
    ServerState.sortGameObjects();
  }

  void readApiPlayer() {
    final apiPlayer = readByte();
    switch (apiPlayer) {
      case ApiPlayer.Position:
        readApiPlayerPosition();
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
      case ApiPlayer.Power:
        GamePlayer.powerType.value = readByte();
        GamePlayer.powerReady.value = readBool();
        break;
      case ApiPlayer.Respawn_Timer:
        GamePlayer.respawnTimer.value = readUInt16();
        break;
      case ApiPlayer.PerkType:
        GamePlayer.perkType.value = readByte();
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
      case ApiPlayer.Weapon_Cooldown:
        GamePlayer.weaponCooldown.value = readPercentage();
        break;
      case ApiPlayer.Accuracy:
        ServerState.playerAccuracy.value = readPercentage();
        break;
      case ApiPlayer.Level:
        ServerState.playerLevel.value = readUInt16();
        break;
      case ApiPlayer.Attributes:
        ServerState.playerAttributes.value = readUInt16();
        break;
      case ApiPlayer.Credits:
        ServerState.playerCredits.value = readUInt16();
        break;
      case ApiPlayer.Energy:
        // GamePlayer.energy.value = readUInt16();
        // GamePlayer.energyMax.value = readUInt16();
        readApiPlayerEnergy();
        break;
      case ApiPlayer.Weapons:
        readPlayerWeapons();
        break;
      // case ApiPlayer.Weapon_Quantity:
      //   readPlayerWeaponQuantity();
      //   break;
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
        gamestream.io.recenterCursor();
        break;
      case ApiPlayer.Damage:
        ServerState.playerDamage.value = readUInt16();
        break;
      case ApiPlayer.Items:
        readMap(GamePlayer.items);
        GamePlayer.Refresh_Items();
        break;
      case ApiPlayer.Equipment:
        readPlayerEquipped();
        break;
      case ApiPlayer.Grenades:
        GamePlayer.totalGrenades.value = readUInt16();
        break;
      case ApiPlayer.Id:
        GamePlayer.id.value = readUInt24();
        break;
      case ApiPlayer.Active:
        GamePlayer.active.value = readBool();
        break;
      case ApiPlayer.Attribute_Values:
        GamePlayer.attributeHealth.value = readUInt16();
        GamePlayer.attributeDamage.value = readUInt16();
        GamePlayer.attributeMagic.value = readUInt16();
        break;
      default:
        throw Exception("Cannot parse apiPlayer $apiPlayer");
    }
  }

  void readApiPlayerPosition(){
    GamePlayer.previousPosition.x = GamePlayer.position.x;
    GamePlayer.previousPosition.y = GamePlayer.position.y;
    GamePlayer.previousPosition.z = GamePlayer.position.z;
    readVector3(GamePlayer.position);
    GamePlayer.indexColumn = GamePlayer.position.indexColumn;
    GamePlayer.indexRow = GamePlayer.position.indexRow;
    GamePlayer.indexZ = GamePlayer.position.indexZ;
    GamePlayer.nodeIndex = GamePlayer.position.nodeIndex;
  }

  void readApiPlayerEnergy() =>
      GamePlayer.energyPercentage = readPercentage();

  void readPlayerWeapons() {
    GamePlayer.weapon.value = readUInt16();

    GamePlayer.weaponPrimary.value           = readUInt16();
    // GamePlayer.weaponPrimaryQuantity.value   = readUInt16();
    // GamePlayer.weaponPrimaryCapacity.value   = readUInt16();
    // GamePlayer.weaponPrimaryLevel.value      = readUInt8();

    GamePlayer.weaponSecondary.value         = readUInt16();
    // GamePlayer.weaponSecondaryQuantity.value = readUInt16();
    // GamePlayer.weaponSecondaryCapacity.value = readUInt16();
    // GamePlayer.weaponSecondaryLevel.value    = readUInt8();
  }

  // void readPlayerWeaponQuantity() {
  //   GamePlayer.weaponPrimaryQuantity.value   = readUInt16();
  //   GamePlayer.weaponSecondaryQuantity.value = readUInt16();
  // }

  void readPlayerEquipped() {
    GamePlayer.weapon.value = readUInt16();
    GamePlayer.head.value = readUInt16();
    GamePlayer.body.value = readUInt16();
    GamePlayer.legs.value = readUInt16();
  }

  void readPlayerHealth() {
    ServerState.playerHealth.value = readUInt16();
    ServerState.playerMaxHealth.value = readUInt16();
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

  void readMapCoordinate() {
    readByte(); // DO NOT DELETE
  }

  void readEditorGameObjectSelected() {
    // readVector3(GameEditor.gameObject);

    final id = readUInt16();
    final gameObject = ServerState.findGameObjectById(id);
    if (gameObject == null) throw Exception("could not find gameobject with id $id");
    GameEditor.gameObject.value = gameObject;
    GameEditor.gameObjectSelectedCollidable   .value = readBool();
    GameEditor.gameObjectSelectedFixed        .value = readBool();
    GameEditor.gameObjectSelectedCollectable  .value = readBool();
    GameEditor.gameObjectSelectedPhysical     .value = readBool();
    GameEditor.gameObjectSelectedPersistable  .value = readBool();
    GameEditor.gameObjectSelectedGravity      .value = readBool();

    GameEditor.gameObjectSelectedType.value          = gameObject.type;
    GameEditor.gameObjectSelected.value              = true;
    GameEditor.cameraCenterSelectedObject();

    GameEditor.gameObjectSelectedEmission.value = gameObject.emission_type;
    GameEditor.gameObjectSelectedEmissionIntensity.value = gameObject.emission_intensity;
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

      character.buff = readUInt8();
      ServerState.totalCharacters++;
    }
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
    ServerState.windTypeAmbient.value = readByte();
  }

  void readEnd() {
    bufferSize.value = index;
    index = 0;
    engine.redrawCanvas();
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
    /// TODO optimize
    GameEvents.onChangedNodes();
    GameEditor.refreshNodeSelectedIndex();
  }

  void readPlayerTarget() {
    readVector3(GamePlayer.abilityTarget);
  }

  void readGameTime() {
    ServerState.seconds.value = readUInt24();

  }

  void readNodes() {
    final scenePart = readByte(); /// DO NOT DELETE
    GameNodes.totalZ = readUInt16();
    GameNodes.totalRows = readUInt16();
    GameNodes.totalColumns = readUInt16();

    final compressedNodeTypeLength = readUInt24();
    final compressedNodeOrientationsLength = readUInt24();
    
    final compressedNodeTypes = readUint8List(compressedNodeTypeLength);
    final compressedNodeOrientations = readUint8List(compressedNodeOrientationsLength);
    final nodeTypes = decoder.decodeBytes(compressedNodeTypes);

    GameNodes.nodeTypes = Uint8List.fromList(nodeTypes);
    GameNodes.nodeOrientations = Uint8List.fromList(decoder.decodeBytes(compressedNodeOrientations));
    GameNodes.area = GameNodes.totalRows * GameNodes.totalColumns;
    GameNodes.area2 = GameNodes.area * 2;
    GameNodes.projection = GameNodes.area2 + GameNodes.totalColumns + 1;
    GameNodes.projectionHalf =  GameNodes.projection ~/ 2;
    final totalNodes = GameNodes.totalZ * GameNodes.totalRows * GameNodes.totalColumns;
    GameNodes.colorStack = Uint16List(totalNodes);
    GameNodes.ambientStack = Uint16List(totalNodes);
    GameNodes.total = totalNodes;
    GameState.nodesRaycast = GameNodes.area +  GameNodes.area + GameNodes.totalColumns + 1;
    GameEvents.onChangedNodes();
    GameNodes.refreshNodeVariations();
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
     ServerState.playerScores.clear();
     for (var i = 0; i < total; i++) {
       final id = readUInt24();
       final name = readString();
       final credits = readUInt24();
       ServerState.playerScores.add(
         PlayerScore(
           id: id,
           name: name,
           credits: credits,
         )
       );
     }
     ServerState.sortPlayerScores();
     ServerState.playerScoresReads.value++;
  }

  void readApiPlayersScore() {
    final id = readUInt24();
    final credits = readUInt24();

    for (final player in ServerState.playerScores) {
      if (player.id != id) continue;
      player.credits = credits;
      break;
    }
    ServerState.sortPlayerScores();
    ServerState.playerScoresReads.value++;
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

  void readFight2DResponseCharacters(GameFight2D game) {
    final totalPlayers = readUInt16();
    assert (totalPlayers < GameFight2D.length);
    game.charactersTotal = totalPlayers;
    for (var i = 0; i < totalPlayers; i++) {
      game.characterState[i] = readByte();
      game.characterDirection[i] = readByte();
      game.characterPositionX[i] = readInt16().toDouble();
      game.characterPositionY[i] = readInt16().toDouble();
      game.characterStateDuration[i] = readByte();
    }
  }
}
