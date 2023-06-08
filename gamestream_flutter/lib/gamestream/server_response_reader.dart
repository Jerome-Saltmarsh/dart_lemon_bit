import 'package:archive/archive.dart';
import 'package:gamestream_flutter/gamestream/games/fight2d/game_fight2d.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric_position.dart';
import 'package:gamestream_flutter/isometric/events/on_changed_scene.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:lemon_byte/byte_reader.dart';

class ServerResponseReader with ByteReader {
  final bufferSize = Watch(0);
  final bufferSizeTotal = Watch(0);
  final decoder = ZLibDecoder();
  final Gamestream gamestream;
  late final updateFrame = Watch(0, onChanged: gamestream.isometric.clientState.onChangedUpdateFrame);

  ServerResponseReader(this.gamestream);

  var previousServerResponse = -1;

  void read(Uint8List values) {
    assert (values.isNotEmpty);
    updateFrame.value++;
    index = 0;
    gamestream.isometric.serverState.totalCharacters = 0;
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
          gamestream.refreshGame();
          break;
        case ServerResponse.Environment:
          readServerResponseEnvironment();
          break;
        case ServerResponse.Node:
          readNode();
          break;
        case ServerResponse.Player_Target:
          readVector3(gamestream.isometric.player.target);
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
              gamestream.isometric.serverState.areaType.value = readByte();
              break;
          }
          break;
        case ServerResponse.Fight2D:
          readServerResponseFight2D(gamestream.games.fight2D);
          break;
        case ServerResponse.Capture_The_Flag:
          readCaptureTheFlag();
          break;
        case ServerResponse.High_Score:
          gamestream.isometric.serverState.highScore.value = readUInt24();
          break;
        case ServerResponse.Download_Scene:
          final name = readString();
          final length = readUInt16();
          final bytes = readBytes(length);
          engine.downloadBytes(bytes, name: '$name.scene');
          break;
        case ServerResponse.Game_Status:
          gamestream.isometric.serverState.gameStatus.value = readByte();
          break;
        case ServerResponse.GameObject_Deleted:
          gamestream.isometric.serverState.removeGameObjectById(readUInt16());
          break;
        case ServerResponse.Game_Error:
          final errorTypeIndex = readByte();
          gamestream.error.value = parseIndexToGameError(errorTypeIndex);
          return;
        default:
          print("read error; index: $index, previous-server-response: $previousServerResponse");
          print(values);
          return;
      }
      previousServerResponse = serverResponse;
    }
  }

  void readCaptureTheFlag() {
    final captureTheFlag = gamestream.games.captureTheFlag;
    switch (readByte()) {
      case CaptureTheFlagResponse.Score:
        captureTheFlag.scoreRed.value = readUInt16();
        captureTheFlag.scoreBlue.value = readUInt16();
        break;
      case CaptureTheFlagResponse.Flag_Positions:
        readVector3(captureTheFlag.flagPositionRed);
        readVector3(captureTheFlag.flagPositionBlue);
        break;
      case CaptureTheFlagResponse.Base_Positions:
        readVector3(captureTheFlag.basePositionRed);
        readVector3(captureTheFlag.basePositionBlue);
        break;
      case CaptureTheFlagResponse.Flag_Status:
        captureTheFlag.flagStatusRed.value = readByte();
        captureTheFlag.flagStatusBlue.value = readByte();
        break;
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
      case GameFight2DEvents.Death:
        gamestream.audio.playAudioSingle2D(gamestream.audio.magical_impact_16, x, y);
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
    final info = readString();
    print(info);
  }

  void readServerResponseEnvironment() {
    final environmentResponse = readByte();
    switch (environmentResponse) {
      case EnvironmentResponse.Rain:
        gamestream.isometric.serverState.rainType.value = readByte();
        break;
      case EnvironmentResponse.Lightning:
        gamestream.isometric.serverState.lightningType.value = readByte();
        break;
      case EnvironmentResponse.Wind:
        gamestream.isometric.serverState.windTypeAmbient.value = readByte();
        break;
      case EnvironmentResponse.Breeze:
        gamestream.isometric.serverState.weatherBreeze.value = readBool();
        break;
      case EnvironmentResponse.Underground:
        gamestream.isometric.serverState.sceneUnderground.value = readBool();
        break;
      case EnvironmentResponse.Lightning_Flashing:
        gamestream.isometric.serverState.lightningFlashing.value = readBool();
        break;
      case EnvironmentResponse.Time_Enabled:
        gamestream.isometric.serverState.gameTimeEnabled.value = readBool();
        break;
    }
  }

  void readGameObject() {
    final id = readUInt16();
    final gameObject = gamestream.isometric.serverState.findOrCreateGameObject(id);
    gameObject.active = readBool();
    gameObject.type = readUInt16();
    readVector3(gameObject);
    gamestream.isometric.serverState.sortGameObjects();
  }

  void readApiPlayer() {
    final apiPlayer = readByte();
    switch (apiPlayer) {
      case ApiPlayer.Position:
        readApiPlayerPosition();
        break;
      case ApiPlayer.Aim_Target_Category:
        gamestream.isometric.player.aimTargetCategory = readByte();
        break;
      case ApiPlayer.Aim_Target_Position:
        readVector3(gamestream.isometric.player.aimTargetPosition);
        break;
      case ApiPlayer.Aim_Target_Type:
        gamestream.isometric.player.aimTargetType = readUInt16();
        break;
      case ApiPlayer.Aim_Target_Quantity:
        gamestream.isometric.player.aimTargetQuantity = readUInt16();
        break;
      case ApiPlayer.Aim_Target_Name:
        gamestream.isometric.player.aimTargetName = readString();
        break;
      case ApiPlayer.Power:
        gamestream.isometric.player.powerType.value = readByte();
        gamestream.isometric.player.powerReady.value = readBool();
        break;
      case ApiPlayer.Respawn_Timer:
        gamestream.isometric.player.respawnTimer.value = readUInt16();
        break;
      case ApiPlayer.PerkType:
        gamestream.isometric.player.perkType.value = readByte();
        break;
      case ApiPlayer.Target_Position:
        gamestream.isometric.player.runningToTarget = true;
        readVector3(gamestream.isometric.player.targetPosition);
        break;
      case ApiPlayer.Target_Category:
        gamestream.isometric.player.targetCategory = readByte();
        break;
      case ApiPlayer.Experience_Percentage:
        gamestream.isometric.serverState.playerExperiencePercentage.value = readPercentage();
        break;
      case ApiPlayer.Interact_Mode:
        gamestream.isometric.serverState.interactMode.value = readByte();
        break;
      case ApiPlayer.Health:
        readPlayerHealth();
        break;
      case ApiPlayer.Weapon_Cooldown:
        gamestream.isometric.player.weaponCooldown.value = readPercentage();
        break;
      case ApiPlayer.Accuracy:
        gamestream.isometric.serverState.playerAccuracy.value = readPercentage();
        break;
      case ApiPlayer.Level:
        gamestream.isometric.serverState.playerLevel.value = readUInt16();
        break;
      case ApiPlayer.Attributes:
        gamestream.isometric.serverState.playerAttributes.value = readUInt16();
        break;
      case ApiPlayer.Credits:
        gamestream.isometric.serverState.playerCredits.value = readUInt16();
        break;
      case ApiPlayer.Energy:
        // gamestream.isometricEngine.player.energy.value = readUInt16();
        // gamestream.isometricEngine.player.energyMax.value = readUInt16();
        readApiPlayerEnergy();
        break;
      case ApiPlayer.Weapons:
        readPlayerWeapons();
        break;
      // case ApiPlayer.Weapon_Quantity:
      //   readPlayerWeaponQuantity();
      //   break;
      case ApiPlayer.Aim_Angle:
        gamestream.isometric.player.mouseAngle = readAngle();
        break;
      case ApiPlayer.Inventory:
        readPlayerInventory();
        break;
      case ApiPlayer.Inventory_Slot:
        final index = readUInt16();
        final itemType = readUInt16();
        final itemQuantity = readUInt16();

        if (index == ItemType.Belt_1){
          gamestream.isometric.serverState.playerBelt1_ItemType.value = itemType;
          gamestream.isometric.serverState.playerBelt1_Quantity.value = itemQuantity;
          ClientActions.redrawInventory();
          return;
        }
        if (index == ItemType.Belt_2){
          gamestream.isometric.serverState.playerBelt2_ItemType.value = itemType;
          gamestream.isometric.serverState.playerBelt2_Quantity.value = itemQuantity;
          ClientActions.redrawInventory();
          return;
        }
        if (index == ItemType.Belt_3){
          gamestream.isometric.serverState.playerBelt3_ItemType.value = itemType;
          gamestream.isometric.serverState.playerBelt3_Quantity.value = itemQuantity;
          ClientActions.redrawInventory();
          return;
        }
        if (index == ItemType.Belt_4){
          gamestream.isometric.serverState.playerBelt4_ItemType.value = itemType;
          gamestream.isometric.serverState.playerBelt4_Quantity.value = itemQuantity;
          ClientActions.redrawInventory();
          return;
        }
        if (index == ItemType.Belt_5){
          gamestream.isometric.serverState.playerBelt5_ItemType.value = itemType;
          gamestream.isometric.serverState.playerBelt5_Quantity.value = itemQuantity;
          ClientActions.redrawInventory();
          return;
        }
        if (index == ItemType.Belt_6){
          gamestream.isometric.serverState.playerBelt6_ItemType.value = itemType;
          gamestream.isometric.serverState.playerBelt6_Quantity.value = itemQuantity;
          ClientActions.redrawInventory();
          return;
        }
        gamestream.isometric.serverState.inventory[index] = itemType;
        gamestream.isometric.serverState.inventoryQuantity[index] = itemQuantity;
        ClientActions.redrawInventory();
        break;
      case ApiPlayer.Message:
        gamestream.isometric.player.message.value = readString();
        break;
      case ApiPlayer.Alive:
        gamestream.isometric.player.alive.value = readBool();
        ClientActions.clearHoverDialogType();
        break;
      case ApiPlayer.Spawned:
        gamestream.isometric.camera.centerOnPlayer();
        gamestream.io.recenterCursor();
        break;
      case ApiPlayer.Damage:
        gamestream.isometric.serverState.playerDamage.value = readUInt16();
        break;
      case ApiPlayer.Items:
        readMap(gamestream.isometric.player.items);
        gamestream.isometric.player.Refresh_Items();
        break;
      case ApiPlayer.Equipment:
        readPlayerEquipped();
        break;
      case ApiPlayer.Grenades:
        gamestream.isometric.player.totalGrenades.value = readUInt16();
        break;
      case ApiPlayer.Id:
        gamestream.isometric.player.id.value = readUInt24();
        break;
      case ApiPlayer.Active:
        gamestream.isometric.player.active.value = readBool();
        break;
      case ApiPlayer.Attribute_Values:
        gamestream.isometric.player.attributeHealth.value = readUInt16();
        gamestream.isometric.player.attributeDamage.value = readUInt16();
        gamestream.isometric.player.attributeMagic.value = readUInt16();
        break;
      default:
        throw Exception("Cannot parse apiPlayer $apiPlayer");
    }
  }

  void readApiPlayerPosition() {
    final game = gamestream.game.value;

    if (game is! GameIsometric){
       throw Exception('game is! GameIsometric: $game');
    }
    final player = gamestream.isometric.player;
    player.previousPosition.x = player.position.x;
    player.previousPosition.y = player.position.y;
    player.previousPosition.z = player.position.z;
    readVector3(player.position);
    final position = player.position;
    player.indexColumn = position.indexColumn;
    player.indexRow = position.indexRow;
    player.indexZ = position.indexZ;
    player.nodeIndex = position.nodeIndex;
  }

  void readApiPlayerEnergy() =>
      gamestream.isometric.player.energyPercentage = readPercentage();

  void readPlayerWeapons() {
    gamestream.isometric.player.weapon.value = readUInt16();

    gamestream.isometric.player.weaponPrimary.value           = readUInt16();
    // gamestream.isometricEngine.player.weaponPrimaryQuantity.value   = readUInt16();
    // gamestream.isometricEngine.player.weaponPrimaryCapacity.value   = readUInt16();
    // gamestream.isometricEngine.player.weaponPrimaryLevel.value      = readUInt8();

    gamestream.isometric.player.weaponSecondary.value         = readUInt16();
    // gamestream.isometricEngine.player.weaponSecondaryQuantity.value = readUInt16();
    // gamestream.isometricEngine.player.weaponSecondaryCapacity.value = readUInt16();
    // gamestream.isometricEngine.player.weaponSecondaryLevel.value    = readUInt8();
  }

  // void readPlayerWeaponQuantity() {
  //   gamestream.isometricEngine.player.weaponPrimaryQuantity.value   = readUInt16();
  //   gamestream.isometricEngine.player.weaponSecondaryQuantity.value = readUInt16();
  // }

  void readPlayerEquipped() {
    gamestream.isometric.player.weapon.value = readUInt16();
    gamestream.isometric.player.head.value = readUInt16();
    gamestream.isometric.player.body.value = readUInt16();
    gamestream.isometric.player.legs.value = readUInt16();
  }

  void readPlayerHealth() {
    gamestream.isometric.serverState.playerHealth.value = readUInt16();
    gamestream.isometric.serverState.playerMaxHealth.value = readUInt16();
  }

  void readPlayerInventory() {
    gamestream.isometric.player.head.value = readUInt16();
    gamestream.isometric.player.body.value = readUInt16();
    gamestream.isometric.player.legs.value = readUInt16();
    gamestream.isometric.player.weapon.value = readUInt16();
    gamestream.isometric.serverState.playerBelt1_ItemType.value = readUInt16();
    gamestream.isometric.serverState.playerBelt2_ItemType.value = readUInt16();
    gamestream.isometric.serverState.playerBelt3_ItemType.value = readUInt16();
    gamestream.isometric.serverState.playerBelt4_ItemType.value = readUInt16();
    gamestream.isometric.serverState.playerBelt5_ItemType.value = readUInt16();
    gamestream.isometric.serverState.playerBelt6_ItemType.value = readUInt16();
    gamestream.isometric.serverState.playerBelt1_Quantity.value = readUInt16();
    gamestream.isometric.serverState.playerBelt2_Quantity.value = readUInt16();
    gamestream.isometric.serverState.playerBelt3_Quantity.value = readUInt16();
    gamestream.isometric.serverState.playerBelt4_Quantity.value = readUInt16();
    gamestream.isometric.serverState.playerBelt5_Quantity.value = readUInt16();
    gamestream.isometric.serverState.playerBelt6_Quantity.value = readUInt16();
    gamestream.isometric.serverState.equippedWeaponIndex.value = readUInt16();
    final total = readUInt16();
    if (gamestream.isometric.serverState.inventory.length != total){
      gamestream.isometric.serverState.inventory = Uint16List(total);
      gamestream.isometric.serverState.inventoryQuantity = Uint16List(total);
    }
    for (var i = 0; i < total; i++){
      gamestream.isometric.serverState.inventory[i] = readUInt16();
    }
    for (var i = 0; i < total; i++){
      gamestream.isometric.serverState.inventoryQuantity[i] = readUInt16();
    }
    ClientActions.redrawInventory();
  }

  void readMapCoordinate() {
    readByte(); // DO NOT DELETE
  }

  void readEditorGameObjectSelected() {
    // readVector3(gamestream.isometricEngine.editor.gameObject);

    final id = readUInt16();
    final gameObject = gamestream.isometric.serverState.findGameObjectById(id);
    if (gameObject == null) throw Exception("could not find gameobject with id $id");
    gamestream.isometric.editor.gameObject.value = gameObject;
    gamestream.isometric.editor.gameObjectSelectedCollidable   .value = readBool();
    gamestream.isometric.editor.gameObjectSelectedFixed        .value = readBool();
    gamestream.isometric.editor.gameObjectSelectedCollectable  .value = readBool();
    gamestream.isometric.editor.gameObjectSelectedPhysical     .value = readBool();
    gamestream.isometric.editor.gameObjectSelectedPersistable  .value = readBool();
    gamestream.isometric.editor.gameObjectSelectedGravity      .value = readBool();

    gamestream.isometric.editor.gameObjectSelectedType.value          = gameObject.type;
    gamestream.isometric.editor.gameObjectSelected.value              = true;
    gamestream.isometric.editor.cameraCenterSelectedObject();

    gamestream.isometric.editor.gameObjectSelectedEmission.value = gameObject.emission_type;
    gamestream.isometric.editor.gameObjectSelectedEmissionIntensity.value = gameObject.emission_intensity;
  }

  void readCharacters(){
     while (true) {
      final characterType = readByte();
      if (characterType == END) return;
      final character = gamestream.isometric.serverState.getCharacterInstance();

      character.characterType = characterType;
      readCharacterTeamDirectionAndState(character);
      readVector3(character);
      readCharacterHealthAndAnimationFrame(character);

      if (CharacterType.supportsUpperBody(characterType)){
        readCharacterUpperBody(character);
      }

      character.buff = readUInt8();
      gamestream.isometric.serverState.totalCharacters++;
    }
  }

  void readNpcTalk() {
    gamestream.isometric.player.npcTalk.value = readString();
    final totalOptions = readByte();
    final options = <String>[];
    for (var i = 0; i < totalOptions; i++) {
       options.add(readString());
    }
    gamestream.isometric.player.npcTalkOptions.value = options;
  }

  void readGameProperties() {
    gamestream.isometric.serverState.sceneEditable.value = readBool();
    gamestream.isometric.serverState.sceneName.value = readString();
    gamestream.isometric.serverState.gameRunning.value = readBool();
  }

  void readWeather() {
    gamestream.isometric.serverState.rainType.value = readByte();
    gamestream.isometric.serverState.weatherBreeze.value = readBool();
    gamestream.isometric.serverState.lightningType.value = readByte();
    gamestream.isometric.serverState.windTypeAmbient.value = readByte();
  }

  void readEnd() {
    bufferSize.value = index;
    index = 0;
    engine.redrawCanvas();
  }

  void readStoreItems() {
    final length = readUInt16();
    if (gamestream.isometric.player.storeItems.value.length != length){
      gamestream.isometric.player.storeItems.value = Uint16List(length);
    }
    for (var i = 0; i < length; i++){
      gamestream.isometric.player.storeItems.value[i] = readUInt16();
    }
  }

  void readNode() {
    final nodeIndex = readUInt24();
    final nodeType = readByte();
    final nodeOrientation = readByte();
    assert(NodeType.supportsOrientation(nodeType, nodeOrientation));
    gamestream.isometric.nodes.nodeTypes[nodeIndex] = nodeType;
    gamestream.isometric.nodes.nodeOrientations[nodeIndex] = nodeOrientation;
    /// TODO optimize
    gamestream.isometric.events.onChangedNodes();
    gamestream.isometric.editor.refreshNodeSelectedIndex();
  }

  void readPlayerTarget() {
    readVector3(gamestream.isometric.player.abilityTarget);
  }

  void readGameTime() {
    gamestream.isometric.serverState.seconds.value = readUInt24();

  }

  void readNodes() {
    final scenePart = readByte(); /// DO NOT DELETE
    gamestream.isometric.nodes.totalZ = readUInt16();
    gamestream.isometric.nodes.totalRows = readUInt16();
    gamestream.isometric.nodes.totalColumns = readUInt16();

    final compressedNodeTypeLength = readUInt24();
    final compressedNodeOrientationsLength = readUInt24();

    final compressedNodeTypes = readUint8List(compressedNodeTypeLength);
    final compressedNodeOrientations = readUint8List(compressedNodeOrientationsLength);
    final nodeTypes = decoder.decodeBytes(compressedNodeTypes);

    gamestream.isometric.nodes.nodeTypes = Uint8List.fromList(nodeTypes);
    gamestream.isometric.nodes.nodeOrientations = Uint8List.fromList(decoder.decodeBytes(compressedNodeOrientations));
    gamestream.isometric.nodes.area = gamestream.isometric.nodes.totalRows * gamestream.isometric.nodes.totalColumns;
    gamestream.isometric.nodes.area2 = gamestream.isometric.nodes.area * 2;
    gamestream.isometric.nodes.projection = gamestream.isometric.nodes.area2 + gamestream.isometric.nodes.totalColumns + 1;
    gamestream.isometric.nodes.projectionHalf =  gamestream.isometric.nodes.projection ~/ 2;
    final totalNodes = gamestream.isometric.nodes.totalZ * gamestream.isometric.nodes.totalRows * gamestream.isometric.nodes.totalColumns;
    gamestream.isometric.nodes.colorStack = Uint16List(totalNodes);
    gamestream.isometric.nodes.ambientStack = Uint16List(totalNodes);
    gamestream.isometric.nodes.total = totalNodes;
    gamestream.isometric.clientState.nodesRaycast = gamestream.isometric.nodes.area +  gamestream.isometric.nodes.area + gamestream.isometric.nodes.totalColumns + 1;
    gamestream.isometric.events.onChangedNodes();
    gamestream.isometric.nodes.refreshNodeVariations();
    gamestream.isometric.clientState.sceneChanged.value++;
    onChangedScene();
  }

  double readDouble() => readInt16().toDouble();

  void readGameEvent(){
      final type = readByte();
      final x = readDouble();
      final y = readDouble();
      final z = readDouble();
      final angle = readDouble() * degreesToRadians;
      gamestream.isometric.events.onGameEvent(type, x, y, z, angle);
  }

  void readProjectiles(){
    gamestream.isometric.serverState.totalProjectiles = readUInt16();
    while (gamestream.isometric.serverState.totalProjectiles >= gamestream.isometric.serverState.projectiles.length){
      gamestream.isometric.serverState.projectiles.add(IsometricProjectile());
    }
    for (var i = 0; i < gamestream.isometric.serverState.totalProjectiles; i++) {
      final projectile = gamestream.isometric.serverState.projectiles[i];
      projectile.x = readDouble();
      projectile.y = readDouble();
      projectile.z = readDouble();
      projectile.type = readByte();
      projectile.angle = readDouble() * degreesToRadians;
    }
  }

  void readCharacterTeamDirectionAndState(IsometricCharacter character){
    final byte = readByte();
    character.allie = byte >= 100;
    character.direction = ((byte % 100) ~/ 10);
    character.state = byte % 10;
  }

  void readCharacterUpperBody(IsometricCharacter character){
    character.weaponType = readUInt16();
    character.weaponState = readUInt16();
    character.bodyType = readUInt16();
    character.headType = readUInt16();
    character.legType = readUInt16();
    character.lookRadian = readAngle();
    character.weaponFrame = readByte();
  }

  // todo optimize
  void readCharacterHealthAndAnimationFrame(IsometricCharacter character){
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
    gamestream.isometric.events.onPlayerEvent(readByte());
  }

  void readPosition(Position position){
    position.x = readDouble();
    position.y = readDouble();
  }

  void readVector3(IsometricPosition value){
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
     gamestream.isometric.serverState.playerScores.clear();
     for (var i = 0; i < total; i++) {
       final id = readUInt24();
       final name = readString();
       final credits = readUInt24();
       gamestream.isometric.serverState.playerScores.add(
         PlayerScore(
           id: id,
           name: name,
           credits: credits,
         )
       );
     }
     gamestream.isometric.serverState.sortPlayerScores();
     gamestream.isometric.serverState.playerScoresReads.value++;
  }

  void readApiPlayersScore() {
    final id = readUInt24();
    final credits = readUInt24();

    for (final player in gamestream.isometric.serverState.playerScores) {
      if (player.id != id) continue;
      player.credits = credits;
      break;
    }
    gamestream.isometric.serverState.sortPlayerScores();
    gamestream.isometric.serverState.playerScoresReads.value++;
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
      game.characterIsBot[i] = readBool();
      game.characterDamage[i] = readUInt16();
      game.characterPositionX[i] = readInt16().toDouble();
      game.characterPositionY[i] = readInt16().toDouble();
      game.characterStateDuration[i] = readByte();
    }
  }
}
