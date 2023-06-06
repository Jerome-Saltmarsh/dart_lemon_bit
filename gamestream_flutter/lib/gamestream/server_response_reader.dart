import 'package:archive/archive.dart';
import 'package:gamestream_flutter/gamestream/games/fight2d/game_fight2d.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric.dart';
import 'package:gamestream_flutter/isometric/events/on_changed_scene.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:lemon_byte/byte_reader.dart';

class ServerResponseReader with ByteReader {
  final bufferSize = Watch(0);
  final bufferSizeTotal = Watch(0);
  final decoder = ZLibDecoder();
  final Gamestream gamestream;
  late final updateFrame = Watch(0, onChanged: gamestream.isometricEngine.clientState.onChangedUpdateFrame);

  ServerResponseReader(this.gamestream);

  var previousServerResponse = -1;

  void read(Uint8List values) {
    assert (values.isNotEmpty);
    updateFrame.value++;
    index = 0;
    gamestream.isometricEngine.serverState.totalCharacters = 0;
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
          readVector3(gamestream.isometricEngine.player.target);
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
              gamestream.isometricEngine.serverState.areaType.value = readByte();
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
          gamestream.isometricEngine.serverState.highScore.value = readUInt24();
          break;
        case ServerResponse.Download_Scene:
          final name = readString();
          final length = readUInt16();
          final bytes = readBytes(length);
          engine.downloadBytes(bytes, name: '$name.scene');
          break;
        case ServerResponse.Game_Status:
          gamestream.isometricEngine.serverState.gameStatus.value = readByte();
          break;
        case ServerResponse.GameObject_Deleted:
          gamestream.isometricEngine.serverState.removeGameObjectById(readUInt16());
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
        gamestream.isometricEngine.serverState.rainType.value = readByte();
        break;
      case EnvironmentResponse.Lightning:
        gamestream.isometricEngine.serverState.lightningType.value = readByte();
        break;
      case EnvironmentResponse.Wind:
        gamestream.isometricEngine.serverState.windTypeAmbient.value = readByte();
        break;
      case EnvironmentResponse.Breeze:
        gamestream.isometricEngine.serverState.weatherBreeze.value = readBool();
        break;
      case EnvironmentResponse.Underground:
        gamestream.isometricEngine.serverState.sceneUnderground.value = readBool();
        break;
      case EnvironmentResponse.Lightning_Flashing:
        gamestream.isometricEngine.serverState.lightningFlashing.value = readBool();
        break;
      case EnvironmentResponse.Time_Enabled:
        gamestream.isometricEngine.serverState.gameTimeEnabled.value = readBool();
        break;
    }
  }

  void readGameObject() {
    final id = readUInt16();
    final gameObject = gamestream.isometricEngine.serverState.findOrCreateGameObject(id);
    gameObject.active = readBool();
    gameObject.type = readUInt16();
    readVector3(gameObject);
    gamestream.isometricEngine.serverState.sortGameObjects();
  }

  void readApiPlayer() {
    final apiPlayer = readByte();
    switch (apiPlayer) {
      case ApiPlayer.Position:
        readApiPlayerPosition();
        break;
      case ApiPlayer.Aim_Target_Category:
        gamestream.isometricEngine.player.aimTargetCategory = readByte();
        break;
      case ApiPlayer.Aim_Target_Position:
        readVector3(gamestream.isometricEngine.player.aimTargetPosition);
        break;
      case ApiPlayer.Aim_Target_Type:
        gamestream.isometricEngine.player.aimTargetType = readUInt16();
        break;
      case ApiPlayer.Aim_Target_Quantity:
        gamestream.isometricEngine.player.aimTargetQuantity = readUInt16();
        break;
      case ApiPlayer.Aim_Target_Name:
        gamestream.isometricEngine.player.aimTargetName = readString();
        break;
      case ApiPlayer.Power:
        gamestream.isometricEngine.player.powerType.value = readByte();
        gamestream.isometricEngine.player.powerReady.value = readBool();
        break;
      case ApiPlayer.Respawn_Timer:
        gamestream.isometricEngine.player.respawnTimer.value = readUInt16();
        break;
      case ApiPlayer.PerkType:
        gamestream.isometricEngine.player.perkType.value = readByte();
        break;
      case ApiPlayer.Target_Position:
        gamestream.isometricEngine.player.runningToTarget = true;
        readVector3(gamestream.isometricEngine.player.targetPosition);
        break;
      case ApiPlayer.Target_Category:
        gamestream.isometricEngine.player.targetCategory = readByte();
        break;
      case ApiPlayer.Experience_Percentage:
        gamestream.isometricEngine.serverState.playerExperiencePercentage.value = readPercentage();
        break;
      case ApiPlayer.Interact_Mode:
        gamestream.isometricEngine.serverState.interactMode.value = readByte();
        break;
      case ApiPlayer.Health:
        readPlayerHealth();
        break;
      case ApiPlayer.Weapon_Cooldown:
        gamestream.isometricEngine.player.weaponCooldown.value = readPercentage();
        break;
      case ApiPlayer.Accuracy:
        gamestream.isometricEngine.serverState.playerAccuracy.value = readPercentage();
        break;
      case ApiPlayer.Level:
        gamestream.isometricEngine.serverState.playerLevel.value = readUInt16();
        break;
      case ApiPlayer.Attributes:
        gamestream.isometricEngine.serverState.playerAttributes.value = readUInt16();
        break;
      case ApiPlayer.Credits:
        gamestream.isometricEngine.serverState.playerCredits.value = readUInt16();
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
        gamestream.isometricEngine.player.mouseAngle = readAngle();
        break;
      case ApiPlayer.Inventory:
        readPlayerInventory();
        break;
      case ApiPlayer.Inventory_Slot:
        final index = readUInt16();
        final itemType = readUInt16();
        final itemQuantity = readUInt16();

        if (index == ItemType.Belt_1){
          gamestream.isometricEngine.serverState.playerBelt1_ItemType.value = itemType;
          gamestream.isometricEngine.serverState.playerBelt1_Quantity.value = itemQuantity;
          ClientActions.redrawInventory();
          return;
        }
        if (index == ItemType.Belt_2){
          gamestream.isometricEngine.serverState.playerBelt2_ItemType.value = itemType;
          gamestream.isometricEngine.serverState.playerBelt2_Quantity.value = itemQuantity;
          ClientActions.redrawInventory();
          return;
        }
        if (index == ItemType.Belt_3){
          gamestream.isometricEngine.serverState.playerBelt3_ItemType.value = itemType;
          gamestream.isometricEngine.serverState.playerBelt3_Quantity.value = itemQuantity;
          ClientActions.redrawInventory();
          return;
        }
        if (index == ItemType.Belt_4){
          gamestream.isometricEngine.serverState.playerBelt4_ItemType.value = itemType;
          gamestream.isometricEngine.serverState.playerBelt4_Quantity.value = itemQuantity;
          ClientActions.redrawInventory();
          return;
        }
        if (index == ItemType.Belt_5){
          gamestream.isometricEngine.serverState.playerBelt5_ItemType.value = itemType;
          gamestream.isometricEngine.serverState.playerBelt5_Quantity.value = itemQuantity;
          ClientActions.redrawInventory();
          return;
        }
        if (index == ItemType.Belt_6){
          gamestream.isometricEngine.serverState.playerBelt6_ItemType.value = itemType;
          gamestream.isometricEngine.serverState.playerBelt6_Quantity.value = itemQuantity;
          ClientActions.redrawInventory();
          return;
        }
        gamestream.isometricEngine.serverState.inventory[index] = itemType;
        gamestream.isometricEngine.serverState.inventoryQuantity[index] = itemQuantity;
        ClientActions.redrawInventory();
        break;
      case ApiPlayer.Message:
        gamestream.isometricEngine.player.message.value = readString();
        break;
      case ApiPlayer.Alive:
        gamestream.isometricEngine.player.alive.value = readBool();
        ClientActions.clearHoverDialogType();
        break;
      case ApiPlayer.Spawned:
        gamestream.isometricEngine.camera.centerOnPlayer();
        gamestream.io.recenterCursor();
        break;
      case ApiPlayer.Damage:
        gamestream.isometricEngine.serverState.playerDamage.value = readUInt16();
        break;
      case ApiPlayer.Items:
        readMap(gamestream.isometricEngine.player.items);
        gamestream.isometricEngine.player.Refresh_Items();
        break;
      case ApiPlayer.Equipment:
        readPlayerEquipped();
        break;
      case ApiPlayer.Grenades:
        gamestream.isometricEngine.player.totalGrenades.value = readUInt16();
        break;
      case ApiPlayer.Id:
        gamestream.isometricEngine.player.id.value = readUInt24();
        break;
      case ApiPlayer.Active:
        gamestream.isometricEngine.player.active.value = readBool();
        break;
      case ApiPlayer.Attribute_Values:
        gamestream.isometricEngine.player.attributeHealth.value = readUInt16();
        gamestream.isometricEngine.player.attributeDamage.value = readUInt16();
        gamestream.isometricEngine.player.attributeMagic.value = readUInt16();
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
    final player = gamestream.isometricEngine.player;
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
      gamestream.isometricEngine.player.energyPercentage = readPercentage();

  void readPlayerWeapons() {
    gamestream.isometricEngine.player.weapon.value = readUInt16();

    gamestream.isometricEngine.player.weaponPrimary.value           = readUInt16();
    // gamestream.isometricEngine.player.weaponPrimaryQuantity.value   = readUInt16();
    // gamestream.isometricEngine.player.weaponPrimaryCapacity.value   = readUInt16();
    // gamestream.isometricEngine.player.weaponPrimaryLevel.value      = readUInt8();

    gamestream.isometricEngine.player.weaponSecondary.value         = readUInt16();
    // gamestream.isometricEngine.player.weaponSecondaryQuantity.value = readUInt16();
    // gamestream.isometricEngine.player.weaponSecondaryCapacity.value = readUInt16();
    // gamestream.isometricEngine.player.weaponSecondaryLevel.value    = readUInt8();
  }

  // void readPlayerWeaponQuantity() {
  //   gamestream.isometricEngine.player.weaponPrimaryQuantity.value   = readUInt16();
  //   gamestream.isometricEngine.player.weaponSecondaryQuantity.value = readUInt16();
  // }

  void readPlayerEquipped() {
    gamestream.isometricEngine.player.weapon.value = readUInt16();
    gamestream.isometricEngine.player.head.value = readUInt16();
    gamestream.isometricEngine.player.body.value = readUInt16();
    gamestream.isometricEngine.player.legs.value = readUInt16();
  }

  void readPlayerHealth() {
    gamestream.isometricEngine.serverState.playerHealth.value = readUInt16();
    gamestream.isometricEngine.serverState.playerMaxHealth.value = readUInt16();
  }

  void readPlayerInventory() {
    gamestream.isometricEngine.player.head.value = readUInt16();
    gamestream.isometricEngine.player.body.value = readUInt16();
    gamestream.isometricEngine.player.legs.value = readUInt16();
    gamestream.isometricEngine.player.weapon.value = readUInt16();
    gamestream.isometricEngine.serverState.playerBelt1_ItemType.value = readUInt16();
    gamestream.isometricEngine.serverState.playerBelt2_ItemType.value = readUInt16();
    gamestream.isometricEngine.serverState.playerBelt3_ItemType.value = readUInt16();
    gamestream.isometricEngine.serverState.playerBelt4_ItemType.value = readUInt16();
    gamestream.isometricEngine.serverState.playerBelt5_ItemType.value = readUInt16();
    gamestream.isometricEngine.serverState.playerBelt6_ItemType.value = readUInt16();
    gamestream.isometricEngine.serverState.playerBelt1_Quantity.value = readUInt16();
    gamestream.isometricEngine.serverState.playerBelt2_Quantity.value = readUInt16();
    gamestream.isometricEngine.serverState.playerBelt3_Quantity.value = readUInt16();
    gamestream.isometricEngine.serverState.playerBelt4_Quantity.value = readUInt16();
    gamestream.isometricEngine.serverState.playerBelt5_Quantity.value = readUInt16();
    gamestream.isometricEngine.serverState.playerBelt6_Quantity.value = readUInt16();
    gamestream.isometricEngine.serverState.equippedWeaponIndex.value = readUInt16();
    final total = readUInt16();
    if (gamestream.isometricEngine.serverState.inventory.length != total){
      gamestream.isometricEngine.serverState.inventory = Uint16List(total);
      gamestream.isometricEngine.serverState.inventoryQuantity = Uint16List(total);
    }
    for (var i = 0; i < total; i++){
      gamestream.isometricEngine.serverState.inventory[i] = readUInt16();
    }
    for (var i = 0; i < total; i++){
      gamestream.isometricEngine.serverState.inventoryQuantity[i] = readUInt16();
    }
    ClientActions.redrawInventory();
  }

  void readMapCoordinate() {
    readByte(); // DO NOT DELETE
  }

  void readEditorGameObjectSelected() {
    // readVector3(gamestream.isometricEngine.editor.gameObject);

    final id = readUInt16();
    final gameObject = gamestream.isometricEngine.serverState.findGameObjectById(id);
    if (gameObject == null) throw Exception("could not find gameobject with id $id");
    gamestream.isometricEngine.editor.gameObject.value = gameObject;
    gamestream.isometricEngine.editor.gameObjectSelectedCollidable   .value = readBool();
    gamestream.isometricEngine.editor.gameObjectSelectedFixed        .value = readBool();
    gamestream.isometricEngine.editor.gameObjectSelectedCollectable  .value = readBool();
    gamestream.isometricEngine.editor.gameObjectSelectedPhysical     .value = readBool();
    gamestream.isometricEngine.editor.gameObjectSelectedPersistable  .value = readBool();
    gamestream.isometricEngine.editor.gameObjectSelectedGravity      .value = readBool();

    gamestream.isometricEngine.editor.gameObjectSelectedType.value          = gameObject.type;
    gamestream.isometricEngine.editor.gameObjectSelected.value              = true;
    gamestream.isometricEngine.editor.cameraCenterSelectedObject();

    gamestream.isometricEngine.editor.gameObjectSelectedEmission.value = gameObject.emission_type;
    gamestream.isometricEngine.editor.gameObjectSelectedEmissionIntensity.value = gameObject.emission_intensity;
  }

  void readCharacters(){
     while (true) {
      final characterType = readByte();
      if (characterType == END) return;
      final character = gamestream.isometricEngine.serverState.getCharacterInstance();

      character.characterType = characterType;
      readCharacterTeamDirectionAndState(character);
      readVector3(character);
      readCharacterHealthAndAnimationFrame(character);

      if (CharacterType.supportsUpperBody(characterType)){
        readCharacterUpperBody(character);
      }

      character.buff = readUInt8();
      gamestream.isometricEngine.serverState.totalCharacters++;
    }
  }

  void readNpcTalk() {
    gamestream.isometricEngine.player.npcTalk.value = readString();
    final totalOptions = readByte();
    final options = <String>[];
    for (var i = 0; i < totalOptions; i++) {
       options.add(readString());
    }
    gamestream.isometricEngine.player.npcTalkOptions.value = options;
  }

  void readGameProperties() {
    gamestream.isometricEngine.serverState.sceneEditable.value = readBool();
    gamestream.isometricEngine.serverState.sceneName.value = readString();
    gamestream.isometricEngine.serverState.gameRunning.value = readBool();
  }

  void readWeather() {
    gamestream.isometricEngine.serverState.rainType.value = readByte();
    gamestream.isometricEngine.serverState.weatherBreeze.value = readBool();
    gamestream.isometricEngine.serverState.lightningType.value = readByte();
    gamestream.isometricEngine.serverState.windTypeAmbient.value = readByte();
  }

  void readEnd() {
    bufferSize.value = index;
    index = 0;
    engine.redrawCanvas();
  }

  void readStoreItems() {
    final length = readUInt16();
    if (gamestream.isometricEngine.player.storeItems.value.length != length){
      gamestream.isometricEngine.player.storeItems.value = Uint16List(length);
    }
    for (var i = 0; i < length; i++){
      gamestream.isometricEngine.player.storeItems.value[i] = readUInt16();
    }
  }

  void readNode() {
    final nodeIndex = readUInt24();
    final nodeType = readByte();
    final nodeOrientation = readByte();
    assert(NodeType.supportsOrientation(nodeType, nodeOrientation));
    gamestream.isometricEngine.nodes.nodeTypes[nodeIndex] = nodeType;
    gamestream.isometricEngine.nodes.nodeOrientations[nodeIndex] = nodeOrientation;
    /// TODO optimize
    GameEvents.onChangedNodes();
    gamestream.isometricEngine.editor.refreshNodeSelectedIndex();
  }

  void readPlayerTarget() {
    readVector3(gamestream.isometricEngine.player.abilityTarget);
  }

  void readGameTime() {
    gamestream.isometricEngine.serverState.seconds.value = readUInt24();

  }

  void readNodes() {
    final scenePart = readByte(); /// DO NOT DELETE
    gamestream.isometricEngine.nodes.totalZ = readUInt16();
    gamestream.isometricEngine.nodes.totalRows = readUInt16();
    gamestream.isometricEngine.nodes.totalColumns = readUInt16();

    final compressedNodeTypeLength = readUInt24();
    final compressedNodeOrientationsLength = readUInt24();

    final compressedNodeTypes = readUint8List(compressedNodeTypeLength);
    final compressedNodeOrientations = readUint8List(compressedNodeOrientationsLength);
    final nodeTypes = decoder.decodeBytes(compressedNodeTypes);

    gamestream.isometricEngine.nodes.nodeTypes = Uint8List.fromList(nodeTypes);
    gamestream.isometricEngine.nodes.nodeOrientations = Uint8List.fromList(decoder.decodeBytes(compressedNodeOrientations));
    gamestream.isometricEngine.nodes.area = gamestream.isometricEngine.nodes.totalRows * gamestream.isometricEngine.nodes.totalColumns;
    gamestream.isometricEngine.nodes.area2 = gamestream.isometricEngine.nodes.area * 2;
    gamestream.isometricEngine.nodes.projection = gamestream.isometricEngine.nodes.area2 + gamestream.isometricEngine.nodes.totalColumns + 1;
    gamestream.isometricEngine.nodes.projectionHalf =  gamestream.isometricEngine.nodes.projection ~/ 2;
    final totalNodes = gamestream.isometricEngine.nodes.totalZ * gamestream.isometricEngine.nodes.totalRows * gamestream.isometricEngine.nodes.totalColumns;
    gamestream.isometricEngine.nodes.colorStack = Uint16List(totalNodes);
    gamestream.isometricEngine.nodes.ambientStack = Uint16List(totalNodes);
    gamestream.isometricEngine.nodes.total = totalNodes;
    gamestream.isometricEngine.clientState.nodesRaycast = gamestream.isometricEngine.nodes.area +  gamestream.isometricEngine.nodes.area + gamestream.isometricEngine.nodes.totalColumns + 1;
    GameEvents.onChangedNodes();
    gamestream.isometricEngine.nodes.refreshNodeVariations();
    gamestream.isometricEngine.clientState.sceneChanged.value++;
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
    gamestream.isometricEngine.serverState.totalProjectiles = readUInt16();
    while (gamestream.isometricEngine.serverState.totalProjectiles >= gamestream.isometricEngine.serverState.projectiles.length){
      gamestream.isometricEngine.serverState.projectiles.add(Projectile());
    }
    for (var i = 0; i < gamestream.isometricEngine.serverState.totalProjectiles; i++) {
      final projectile = gamestream.isometricEngine.serverState.projectiles[i];
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
     gamestream.isometricEngine.serverState.playerScores.clear();
     for (var i = 0; i < total; i++) {
       final id = readUInt24();
       final name = readString();
       final credits = readUInt24();
       gamestream.isometricEngine.serverState.playerScores.add(
         PlayerScore(
           id: id,
           name: name,
           credits: credits,
         )
       );
     }
     gamestream.isometricEngine.serverState.sortPlayerScores();
     gamestream.isometricEngine.serverState.playerScoresReads.value++;
  }

  void readApiPlayersScore() {
    final id = readUInt24();
    final credits = readUInt24();

    for (final player in gamestream.isometricEngine.serverState.playerScores) {
      if (player.id != id) continue;
      player.credits = credits;
      break;
    }
    gamestream.isometricEngine.serverState.sortPlayerScores();
    gamestream.isometricEngine.serverState.playerScoresReads.value++;
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
