import 'package:archive/archive.dart';
import 'package:gamestream_flutter/gamestream/games/fight2d/game_fight2d.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric_engine.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric_position.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:bleed_common/src/capture_the_flag/src.dart';
import 'package:lemon_byte/byte_reader.dart';

import 'games/game_scissors_paper_rock.dart';
import 'gamestream.dart';
import 'isometric/isometric_character.dart';
import 'isometric/isometric_player_score.dart';
import 'isometric/isometric_projectile.dart';

class ServerResponseReader with ByteReader {
  final bufferSize = Watch(0);
  final bufferSizeTotal = Watch(0);
  final decoder = ZLibDecoder();
  final Gamestream gamestream;
  final IsometricEngine isometric;
  late final updateFrame = Watch(0, onChanged: isometric.clientState.onChangedUpdateFrame);

  ServerResponseReader({required this.gamestream, required this.isometric});

  var previousServerResponse = -1;



  void read(Uint8List values) {
    assert (values.isNotEmpty);
    updateFrame.value++;
    index = 0;
    isometric.server.totalCharacters = 0;
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
          readVector3(isometric.player.target);
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
              isometric.server.areaType.value = readByte();
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
          isometric.server.highScore.value = readUInt24();
          break;
        case ServerResponse.Download_Scene:
          final name = readString();
          final length = readUInt16();
          final bytes = readBytes(length);
          engine.downloadBytes(bytes, name: '$name.scene');
          break;
        case ServerResponse.Game_Status:
          isometric.server.gameStatus.value = readByte();
          break;
        case ServerResponse.GameObject_Deleted:
          isometric.server.removeGameObjectById(readUInt16());
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
        captureTheFlag.flagRedStatus.value = readByte();
        captureTheFlag.flagBlueStatus.value = readByte();
        break;
      case CaptureTheFlagResponse.Red_Team_Scored:
        captureTheFlag.onRedTeamScore();
        break;
      case CaptureTheFlagResponse.Blue_Team_Scored:
        captureTheFlag.onBlueTeamScore();
        break;
      case CaptureTheFlagResponse.Player_Flag_Status:
        captureTheFlag.playerFlagStatus.value = readByte();
        break;
      case CaptureTheFlagResponse.Select_Class:
        captureTheFlag.selectClass.value = readBool();
        break;
      case CaptureTheFlagResponse.Game_Status:
        captureTheFlag.gameStatus.value = CaptureTheFlagGameStatus.values[readByte()];
        break;
      case CaptureTheFlagResponse.Next_Game_Count_Down:
        captureTheFlag.nextGameCountDown.value = readUInt16();
        break;
      case CaptureTheFlagResponse.AI_Paths:
        captureTheFlag.characterPaths.clear();
        final total = readUInt16();
        for (var i = 0; i < total; i++){
           final pathIndex = readUInt16();
           final pathLength = readUInt16();
           final path = readUint16List(pathLength);
           captureTheFlag.characterPaths.add(path);
        }
        break;
      case CaptureTheFlagResponse.AI_Targets:
        var index = 0;
        final characterTargets = captureTheFlag.characterTargets;
        captureTheFlag.characterTargetTotal = 0;
        while (readBool()) {
          captureTheFlag.characterTargetTotal++;
          for (var i = 0; i < 6; i++){
            characterTargets[index++] = readDouble();
          }
        }
        break;
      case CaptureTheFlagResponse.Debug_Mode:
         captureTheFlag.debugMode.value = readBool();
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
        isometric.server.rainType.value = readByte();
        break;
      case EnvironmentResponse.Lightning:
        isometric.server.lightningType.value = readByte();
        break;
      case EnvironmentResponse.Wind:
        isometric.server.windTypeAmbient.value = readByte();
        break;
      case EnvironmentResponse.Breeze:
        isometric.server.weatherBreeze.value = readBool();
        break;
      case EnvironmentResponse.Underground:
        isometric.server.sceneUnderground.value = readBool();
        break;
      case EnvironmentResponse.Lightning_Flashing:
        isometric.server.lightningFlashing.value = readBool();
        break;
      case EnvironmentResponse.Time_Enabled:
        isometric.server.gameTimeEnabled.value = readBool();
        break;
    }
  }

  void readGameObject() {
    final id = readUInt16();
    final gameObject = isometric.server.findOrCreateGameObject(id);
    gameObject.active = readBool();
    gameObject.type = readUInt16();
    readVector3(gameObject);
    isometric.server.sortGameObjects();
  }

  void readApiPlayer() {
    final apiPlayer = readByte();
    switch (apiPlayer) {
      case ApiPlayer.Position:
        readApiPlayerPosition();
        break;
      case ApiPlayer.Aim_Target_Category:
        isometric.player.aimTargetCategory = readByte();
        break;
      case ApiPlayer.Aim_Target_Position:
        readVector3(isometric.player.aimTargetPosition);
        break;
      case ApiPlayer.Aim_Target_Type:
        isometric.player.aimTargetType = readUInt16();
        break;
      case ApiPlayer.Aim_Target_Quantity:
        isometric.player.aimTargetQuantity = readUInt16();
        break;
      case ApiPlayer.Aim_Target_Name:
        isometric.player.aimTargetName = readString();
        break;
      case ApiPlayer.Power:
        isometric.player.powerType.value = readByte();
        isometric.player.powerReady.value = readBool();
        break;
      case ApiPlayer.Respawn_Timer:
        isometric.player.respawnTimer.value = readUInt16();
        break;
      case ApiPlayer.PerkType:
        isometric.player.perkType.value = readByte();
        break;
      case ApiPlayer.Target_Position:
        isometric.player.runningToTarget = true;
        readVector3(isometric.player.targetPosition);
        break;
      case ApiPlayer.Target_Category:
        isometric.player.targetCategory = readByte();
        break;
      case ApiPlayer.Experience_Percentage:
        isometric.server.playerExperiencePercentage.value = readPercentage();
        break;
      case ApiPlayer.Interact_Mode:
        isometric.server.interactMode.value = readByte();
        break;
      case ApiPlayer.Health:
        readPlayerHealth();
        break;
      case ApiPlayer.Weapon_Cooldown:
        isometric.player.weaponCooldown.value = readPercentage();
        break;
      case ApiPlayer.Accuracy:
        isometric.server.playerAccuracy.value = readPercentage();
        break;
      case ApiPlayer.Level:
        isometric.server.playerLevel.value = readUInt16();
        break;
      case ApiPlayer.Attributes:
        isometric.server.playerAttributes.value = readUInt16();
        break;
      case ApiPlayer.Credits:
        isometric.server.playerCredits.value = readUInt16();
        break;
      case ApiPlayer.Energy:
        // isometricEngine.player.energy.value = readUInt16();
        // isometricEngine.player.energyMax.value = readUInt16();
        readApiPlayerEnergy();
        break;
      case ApiPlayer.Weapons:
        readPlayerWeapons();
        break;
      // case ApiPlayer.Weapon_Quantity:
      //   readPlayerWeaponQuantity();
      //   break;
      case ApiPlayer.Aim_Angle:
        isometric.player.mouseAngle = readAngle();
        break;
      case ApiPlayer.Inventory:
        readPlayerInventory();
        break;
      case ApiPlayer.Inventory_Slot:
        final index = readUInt16();
        final itemType = readUInt16();
        final itemQuantity = readUInt16();

        if (index == ItemType.Belt_1){
          isometric.server.playerBelt1_ItemType.value = itemType;
          isometric.server.playerBelt1_Quantity.value = itemQuantity;
          gamestream.isometric.clientState.redrawInventory();
          return;
        }
        if (index == ItemType.Belt_2){
          isometric.server.playerBelt2_ItemType.value = itemType;
          isometric.server.playerBelt2_Quantity.value = itemQuantity;
          gamestream.isometric.clientState.redrawInventory();
          return;
        }
        if (index == ItemType.Belt_3){
          isometric.server.playerBelt3_ItemType.value = itemType;
          isometric.server.playerBelt3_Quantity.value = itemQuantity;
          gamestream.isometric.clientState.redrawInventory();
          return;
        }
        if (index == ItemType.Belt_4){
          isometric.server.playerBelt4_ItemType.value = itemType;
          isometric.server.playerBelt4_Quantity.value = itemQuantity;
          gamestream.isometric.clientState.redrawInventory();
          return;
        }
        if (index == ItemType.Belt_5){
          isometric.server.playerBelt5_ItemType.value = itemType;
          isometric.server.playerBelt5_Quantity.value = itemQuantity;
          gamestream.isometric.clientState.redrawInventory();
          return;
        }
        if (index == ItemType.Belt_6){
          isometric.server.playerBelt6_ItemType.value = itemType;
          isometric.server.playerBelt6_Quantity.value = itemQuantity;
          gamestream.isometric.clientState.redrawInventory();
          return;
        }
        isometric.server.inventory[index] = itemType;
        isometric.server.inventoryQuantity[index] = itemQuantity;
        gamestream.isometric.clientState.redrawInventory();
        break;
      case ApiPlayer.Message:
        isometric.player.message.value = readString();
        break;
      case ApiPlayer.Alive:
        isometric.player.alive.value = readBool();
        isometric.clientState.clearHoverDialogType();
        break;
      case ApiPlayer.Spawned:
        isometric.camera.centerOnPlayer();
        gamestream.io.recenterCursor();
        break;
      case ApiPlayer.Damage:
        isometric.server.playerDamage.value = readUInt16();
        break;
      case ApiPlayer.Items:
        readMap(isometric.player.items);
        isometric.player.Refresh_Items();
        break;
      case ApiPlayer.Equipment:
        readPlayerEquipped();
        break;
      case ApiPlayer.Grenades:
        isometric.player.totalGrenades.value = readUInt16();
        break;
      case ApiPlayer.Id:
        isometric.player.id.value = readUInt24();
        break;
      case ApiPlayer.Active:
        isometric.player.active.value = readBool();
        break;
      case ApiPlayer.Attribute_Values:
        isometric.player.attributeHealth.value = readUInt16();
        isometric.player.attributeDamage.value = readUInt16();
        isometric.player.attributeMagic.value = readUInt16();
        break;
      case ApiPlayer.Team:
        isometric.player.team.value = readByte();
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
    final player = isometric.player;
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
      isometric.player.energyPercentage = readPercentage();

  void readPlayerWeapons() {
    isometric.player.weapon.value = readUInt16();

    isometric.player.weaponPrimary.value           = readUInt16();
    // isometricEngine.player.weaponPrimaryQuantity.value   = readUInt16();
    // isometricEngine.player.weaponPrimaryCapacity.value   = readUInt16();
    // isometricEngine.player.weaponPrimaryLevel.value      = readUInt8();

    isometric.player.weaponSecondary.value         = readUInt16();
    // isometricEngine.player.weaponSecondaryQuantity.value = readUInt16();
    // isometricEngine.player.weaponSecondaryCapacity.value = readUInt16();
    // isometricEngine.player.weaponSecondaryLevel.value    = readUInt8();
  }

  // void readPlayerWeaponQuantity() {
  //   isometricEngine.player.weaponPrimaryQuantity.value   = readUInt16();
  //   isometricEngine.player.weaponSecondaryQuantity.value = readUInt16();
  // }

  void readPlayerEquipped() {
    isometric.player.weapon.value = readUInt16();
    isometric.player.head.value = readUInt16();
    isometric.player.body.value = readUInt16();
    isometric.player.legs.value = readUInt16();
  }

  void readPlayerHealth() {
    isometric.server.playerHealth.value = readUInt16();
    isometric.server.playerMaxHealth.value = readUInt16();
  }

  void readPlayerInventory() {
    isometric.player.head.value = readUInt16();
    isometric.player.body.value = readUInt16();
    isometric.player.legs.value = readUInt16();
    isometric.player.weapon.value = readUInt16();
    isometric.server.playerBelt1_ItemType.value = readUInt16();
    isometric.server.playerBelt2_ItemType.value = readUInt16();
    isometric.server.playerBelt3_ItemType.value = readUInt16();
    isometric.server.playerBelt4_ItemType.value = readUInt16();
    isometric.server.playerBelt5_ItemType.value = readUInt16();
    isometric.server.playerBelt6_ItemType.value = readUInt16();
    isometric.server.playerBelt1_Quantity.value = readUInt16();
    isometric.server.playerBelt2_Quantity.value = readUInt16();
    isometric.server.playerBelt3_Quantity.value = readUInt16();
    isometric.server.playerBelt4_Quantity.value = readUInt16();
    isometric.server.playerBelt5_Quantity.value = readUInt16();
    isometric.server.playerBelt6_Quantity.value = readUInt16();
    isometric.server.equippedWeaponIndex.value = readUInt16();
    final total = readUInt16();
    if (isometric.server.inventory.length != total){
      isometric.server.inventory = Uint16List(total);
      isometric.server.inventoryQuantity = Uint16List(total);
    }
    for (var i = 0; i < total; i++){
      isometric.server.inventory[i] = readUInt16();
    }
    for (var i = 0; i < total; i++){
      isometric.server.inventoryQuantity[i] = readUInt16();
    }
    gamestream.isometric.clientState.redrawInventory();
  }

  void readMapCoordinate() {
    readByte(); // DO NOT DELETE
  }

  void readEditorGameObjectSelected() {
    // readVector3(isometricEngine.editor.gameObject);

    final id = readUInt16();
    final gameObject = isometric.server.findGameObjectById(id);
    if (gameObject == null) throw Exception("could not find gameobject with id $id");
    isometric.editor.gameObject.value = gameObject;
    isometric.editor.gameObjectSelectedCollidable   .value = readBool();
    isometric.editor.gameObjectSelectedFixed        .value = readBool();
    isometric.editor.gameObjectSelectedCollectable  .value = readBool();
    isometric.editor.gameObjectSelectedPhysical     .value = readBool();
    isometric.editor.gameObjectSelectedPersistable  .value = readBool();
    isometric.editor.gameObjectSelectedGravity      .value = readBool();

    isometric.editor.gameObjectSelectedType.value          = gameObject.type;
    isometric.editor.gameObjectSelected.value              = true;
    isometric.editor.cameraCenterSelectedObject();

    isometric.editor.gameObjectSelectedEmission.value = gameObject.emission_type;
    isometric.editor.gameObjectSelectedEmissionIntensity.value = gameObject.emission_intensity;
  }

  void readCharacters(){
     while (true) {
      final characterType = readByte();
      if (characterType == END) return;
      final character = isometric.server.getCharacterInstance();

      character.characterType = characterType;
      readCharacterTeamDirectionAndState(character);
      readVector3(character);
      readCharacterHealthAndAnimationFrame(character);

      if (CharacterType.supportsUpperBody(characterType)){
        readCharacterUpperBody(character);
      }

      character.buff = readUInt8();
      isometric.server.totalCharacters++;
    }
  }

  void readNpcTalk() {
    isometric.player.npcTalk.value = readString();
    final totalOptions = readByte();
    final options = <String>[];
    for (var i = 0; i < totalOptions; i++) {
       options.add(readString());
    }
    isometric.player.npcTalkOptions.value = options;
  }

  void readGameProperties() {
    isometric.server.sceneEditable.value = readBool();
    isometric.server.sceneName.value = readString();
    isometric.server.gameRunning.value = readBool();
  }

  void readWeather() {
    isometric.server.rainType.value = readByte();
    isometric.server.weatherBreeze.value = readBool();
    isometric.server.lightningType.value = readByte();
    isometric.server.windTypeAmbient.value = readByte();
  }

  void readEnd() {
    bufferSize.value = index;
    index = 0;
    engine.redrawCanvas();
  }

  void readStoreItems() {
    final length = readUInt16();
    if (isometric.player.storeItems.value.length != length){
      isometric.player.storeItems.value = Uint16List(length);
    }
    for (var i = 0; i < length; i++){
      isometric.player.storeItems.value[i] = readUInt16();
    }
  }

  void readNode() {
    final nodeIndex = readUInt24();
    final nodeType = readByte();
    final nodeOrientation = readByte();
    assert(NodeType.supportsOrientation(nodeType, nodeOrientation));
    isometric.nodes.nodeTypes[nodeIndex] = nodeType;
    isometric.nodes.nodeOrientations[nodeIndex] = nodeOrientation;
    /// TODO optimize
    isometric.events.onChangedNodes();
    isometric.editor.refreshNodeSelectedIndex();
  }

  void readPlayerTarget() {
    readVector3(isometric.player.abilityTarget);
  }

  void readGameTime() {
    isometric.server.seconds.value = readUInt24();

  }

  void readNodes() {
    final scenePart = readByte(); /// DO NOT DELETE
    isometric.nodes.totalZ = readUInt16();
    isometric.nodes.totalRows = readUInt16();
    isometric.nodes.totalColumns = readUInt16();

    final compressedNodeTypeLength = readUInt24();
    final compressedNodeOrientationsLength = readUInt24();

    final compressedNodeTypes = readUint8List(compressedNodeTypeLength);
    final compressedNodeOrientations = readUint8List(compressedNodeOrientationsLength);
    final nodeTypes = decoder.decodeBytes(compressedNodeTypes);

    isometric.nodes.nodeTypes = Uint8List.fromList(nodeTypes);
    isometric.nodes.nodeOrientations = Uint8List.fromList(decoder.decodeBytes(compressedNodeOrientations));
    isometric.nodes.area = isometric.nodes.totalRows * isometric.nodes.totalColumns;
    isometric.nodes.area2 = isometric.nodes.area * 2;
    isometric.nodes.projection = isometric.nodes.area2 + isometric.nodes.totalColumns + 1;
    isometric.nodes.projectionHalf =  isometric.nodes.projection ~/ 2;
    final totalNodes = isometric.nodes.totalZ * isometric.nodes.totalRows * isometric.nodes.totalColumns;
    isometric.nodes.colorStack = Uint16List(totalNodes);
    isometric.nodes.ambientStack = Uint16List(totalNodes);
    isometric.nodes.total = totalNodes;
    isometric.clientState.nodesRaycast = isometric.nodes.area +  isometric.nodes.area + isometric.nodes.totalColumns + 1;
    isometric.events.onChangedNodes();
    isometric.nodes.refreshNodeVariations();
    isometric.clientState.sceneChanged.value++;

    gamestream.isometric.clientState.totalActiveParticles = 0;
    gamestream.isometric.clientState.totalParticles = 0;
    gamestream.isometric.clientState.particles.clear();
    gamestream.io.recenterCursor();
  }

  double readDouble() => readInt16().toDouble();

  void readGameEvent(){
      final type = readByte();
      final x = readDouble();
      final y = readDouble();
      final z = readDouble();
      final angle = readDouble() * degreesToRadians;
      isometric.events.onGameEvent(type, x, y, z, angle);
  }

  void readProjectiles(){
    isometric.server.totalProjectiles = readUInt16();
    while (isometric.server.totalProjectiles >= isometric.server.projectiles.length){
      isometric.server.projectiles.add(IsometricProjectile());
    }
    for (var i = 0; i < isometric.server.totalProjectiles; i++) {
      final projectile = isometric.server.projectiles[i];
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
    isometric.events.onPlayerEvent(readByte());
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
     isometric.server.playerScores.clear();
     for (var i = 0; i < total; i++) {
       final id = readUInt24();
       final name = readString();
       final credits = readUInt24();
       isometric.server.playerScores.add(
         IsometricPlayerScore(
           id: id,
           name: name,
           credits: credits,
         )
       );
     }
     isometric.server.sortPlayerScores();
     isometric.server.playerScoresReads.value++;
  }

  void readApiPlayersScore() {
    final id = readUInt24();
    final credits = readUInt24();

    for (final player in isometric.server.playerScores) {
      if (player.id != id) continue;
      player.credits = credits;
      break;
    }
    isometric.server.sortPlayerScores();
    isometric.server.playerScoresReads.value++;
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
