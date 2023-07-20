import 'package:gamestream_flutter/gamestream/games/capture_the_flag/capture_the_flag_response_reader.dart';
import 'package:gamestream_flutter/gamestream/games/fight2d/game_fight2d.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_read_response.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_position.dart';
import 'package:gamestream_flutter/gamestream/isometric/extensions/isometric_response_reader.dart';
import 'package:gamestream_flutter/library.dart';

import 'games/game_scissors_paper_rock.dart';
import 'isometric/classes/isometric_character.dart';
import 'isometric/components/isometric_player_score.dart';
import 'isometric/classes/isometric_projectile.dart';

import 'gamestream.dart';


extension ServerResponseReader on Gamestream {

  static final serverResponseStack = Uint8List(1000);
  static final serverResponseStackLength = Uint16List(1000);
  static var serverResponseStackIndex = 0;

  void readServerResponse(Uint8List values) {
    assert (values.isNotEmpty);
    updateFrame.value++;
    index = 0;
    isometric.server.totalCharacters = 0;
    this.values = values;
    bufferSize.value = values.length;
    bufferSizeTotal.value += values.length;

    var serverResponseStart = -1;
    var serverResponse = -1;
    serverResponseStackIndex = -1;
    final length = values.length - 1;

    while (index < length) {

      if (serverResponse != -1) {
        serverResponseStackIndex++;
        serverResponseStack[serverResponseStackIndex] = serverResponse;
        serverResponseStackLength[serverResponseStackIndex] = index - serverResponseStart;
      }

      serverResponseStart = index;
      serverResponse = readByte();

      switch (serverResponse) {
       case ServerResponse.Isometric_Characters:
          readIsometricCharacters();
          break;
        case ServerResponse.Api_Player:
          readApiPlayer();
          break;
        case ServerResponse.Api_SPR:
          readServerResponseApiSPR();
          break;
        case ServerResponse.Isometric:
          readIsometricResponse();
          break;
        case ServerResponse.GameObject:
          readGameObject();
          break;
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
        case ServerResponse.Game_Time:
          readGameTime();
          break;
        case ServerResponse.Game_Type:
          final index = readByte();
          if (index >= GameType.values.length){
            throw Exception('invalid game type index $index');
          }
          gameType.value = GameType.values[index];
          break;
        case ServerResponse.Environment:
          readServerResponseEnvironment();
          break;
        case ServerResponse.Node:
          readNode();
          break;
        case ServerResponse.Player_Target:
          readIsometricPosition(isometric.player.target);
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
        case ServerResponse.Fight2D:
          readServerResponseFight2D(games.fight2D);
          break;
        case ServerResponse.Capture_The_Flag:
          readCaptureTheFlag();
          break;
        case ServerResponse.MMO:
          readMMOResponse();
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
        case ServerResponse.GameObject_Deleted:
          isometric.server.removeGameObjectById(readUInt16());
          break;
        case ServerResponse.Game_Error:
          final errorTypeIndex = readByte();
          error.value = GameError.fromIndex(errorTypeIndex);
          return;
        case ServerResponse.FPS:
          serverFPS.value = readUInt16();
          return;
        default:
          print('read error; index: $index, previous-server-response: $previousServerResponse');
          print(values);
          return;
      }
      previousServerResponse = serverResponse;
    }

    serverResponseStackIndex++;
    serverResponseStack[serverResponseStackIndex] = serverResponse;
    serverResponseStackLength[serverResponseStackIndex] = index - serverResponseStart;
    bufferSize.value = index;
    index = 0;

    if (renderResponse){
      engine.redrawCanvas();
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
        audio.playAudioSingle2D(audio.heavy_punch_13, x, y);
        break;
      case GameFight2DEvents.Jump:
        audio.playAudioSingle2D(audio.jump, x, y);
        break;
      case GameFight2DEvents.Footstep:
        audio.playAudioSingle2D(audio.footstep_stone, x, y);
        break;
      case GameFight2DEvents.Strike_Swing:
        audio.playAudioSingle2D(audio.arm_swing_whoosh_11, x, y);
        break;
      case GameFight2DEvents.Death:
        audio.playAudioSingle2D(audio.magical_impact_16, x, y);
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
    gameObject.type = readByte();
    gameObject.subType = readByte();
    gameObject.health = readUInt16();
    gameObject.maxHealth = readUInt16();
    readIsometricPosition(gameObject);
    isometric.server.gameObjects.sort();
  }

  void readApiPlayer() {
    final apiPlayer = readByte();
    final player = isometric.player;
    switch (apiPlayer) {
      case ApiPlayer.Aim_Target_Category:
        player.aimTargetCategory = readByte();
        break;
      case ApiPlayer.Aim_Target_Position:
        readIsometricPosition(player.aimTargetPosition);
        break;
      case ApiPlayer.Aim_Target_Type:
        player.aimTargetType = readUInt16();
        break;
      case ApiPlayer.Aim_Target_Quantity:
        player.aimTargetQuantity = readUInt16();
        break;
      case ApiPlayer.Aim_Target_Name:
        player.aimTargetName = readString();
        break;
      case ApiPlayer.Arrived_At_Destination:
        player.arrivedAtDestination.value = readBool();
        break;
      case ApiPlayer.Run_To_Destination_Enabled:
        player.runToDestinationEnabled.value = readBool();
        break;
      case ApiPlayer.Debugging:
        player.debugging.value = readBool();
        break;
      case ApiPlayer.Destination:
        player.runX = readDouble();
        player.runY = readDouble();
        player.runZ = readDouble();
        break;
      case ApiPlayer.Target_Position:
        player.runningToTarget = true;
        readIsometricPosition(player.targetPosition);
        break;
      case ApiPlayer.Experience_Percentage:
        isometric.server.playerExperiencePercentage.value = readPercentage();
        break;
      case ApiPlayer.Health:
        readPlayerHealth();
        break;
      case ApiPlayer.Aim_Angle:
        isometric.player.mouseAngle = readAngle();
        break;
      case ApiPlayer.Message:
        isometric.player.message.value = readString();
        break;
      case ApiPlayer.Alive:
        isometric.player.alive.value = readBool();
        // isometric.ui.mouseOverDialog.setFalse();
        break;
      case ApiPlayer.Spawned:
        isometric.camera.centerOnChaseTarget();
        io.recenterCursor();
        break;
      case ApiPlayer.Damage:
        isometric.player.weaponDamage.value = readUInt16();
        break;
      case ApiPlayer.Id:
        isometric.player.id.value = readUInt24();
        break;
      case ApiPlayer.Active:
        isometric.player.active.value = readBool();
        break;
      case ApiPlayer.Team:
        isometric.player.team.value = readByte();
        break;
      default:
        throw Exception('Cannot parse apiPlayer $apiPlayer');
    }
  }

  void readApiPlayerEnergy() =>
      isometric.player.energyPercentage = readPercentage();

  void readPlayerHealth() {
    isometric.player.health.value = readUInt16();
    isometric.player.maxHealth.value = readUInt16();
  }

  void readMapCoordinate() {
    readByte(); // DO NOT DELETE
  }

  void readEditorGameObjectSelected() {
    // readVector3(isometricEngine.editor.gameObject);

    final id = readUInt16();
    final gameObject = isometric.server.findGameObjectById(id);
    if (gameObject == null) throw Exception('could not find gameobject with id $id');
    isometric.editor.gameObject.value = gameObject;
    isometric.editor.gameObjectSelectedCollidable   .value = readBool();
    isometric.editor.gameObjectSelectedFixed        .value = readBool();
    isometric.editor.gameObjectSelectedCollectable  .value = readBool();
    isometric.editor.gameObjectSelectedPhysical     .value = readBool();
    isometric.editor.gameObjectSelectedPersistable  .value = readBool();
    isometric.editor.gameObjectSelectedGravity      .value = readBool();

    isometric.editor.gameObjectSelectedType.value          = gameObject.type;
    isometric.editor.gameObjectSelectedSubType.value       = gameObject.subType;
    isometric.editor.gameObjectSelected.value              = true;
    isometric.editor.cameraCenterSelectedObject();

    isometric.editor.gameObjectSelectedEmission.value = gameObject.colorType;
    isometric.editor.gameObjectSelectedEmissionIntensity.value = gameObject.emission_intensity;
  }

  void readIsometricCharacters(){
     final server = isometric.server;
     while (true) {

       final compressionLevel = readByte();
      if (compressionLevel == CHARACTER_END) break;
      final character = server.getCharacterInstance();


      final stateAChanged = readBitFromByte(compressionLevel, 0);
      final stateBChanged = readBitFromByte(compressionLevel, 1);
      final changeTypeX = (compressionLevel & Hex00001100) >> 2;
      final changeTypeY =  (compressionLevel & Hex00110000) >> 4;
      final changeTypeZ = (compressionLevel & Hex11000000) >> 6;

      if (stateAChanged) {
        character.characterType = readByte();
        character.state = readByte();
        character.team = readByte();
        character.health = readPercentage();
      }

      if (stateBChanged){
        final animationAndFrameDirection = readByte();
        character.direction = (animationAndFrameDirection & Hex11100000) >> 5;
        assert (character.direction >= 0 && character.direction <= 7);
        character.animationFrame = (animationAndFrameDirection & Hex00011111);
      }



       assert (changeTypeX >= 0 && changeTypeX <= 2);
       assert (changeTypeY >= 0 && changeTypeY <= 2);
       assert (changeTypeZ >= 0 && changeTypeZ <= 2);

       if (changeTypeX == ChangeType.Small) {
         character.x += readInt8();
       } else if (changeTypeX == ChangeType.Big) {
         character.x = readDouble();
       }

       if (changeTypeY == ChangeType.Small) {
         character.y += readInt8();
       } else if (changeTypeY == ChangeType.Big) {
         character.y = readDouble();
       }

       if (changeTypeZ == ChangeType.Small) {
         character.z += readInt8();
       } else if (changeTypeZ == ChangeType.Big) {
         character.z = readDouble();
       }

      if (character.characterType == CharacterType.Template){
        readCharacterTemplate(character);
      }
      server.totalCharacters++;
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
    isometric.scene.nodeTypes[nodeIndex] = nodeType;
    isometric.scene.nodeOrientations[nodeIndex] = nodeOrientation;
    /// TODO optimize
    isometric.events.onChangedNodes();
    isometric.editor.refreshNodeSelectedIndex();
  }

  void readPlayerTarget() {
    readIsometricPosition(isometric.player.abilityTarget);
  }

  void readGameTime() {
    isometric.server.seconds.value = readUInt24();
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

  void readCharacterTemplate(IsometricCharacter character){

    final compression = readByte();

    final readA = readBitFromByte(compression, 0);
    final readB = readBitFromByte(compression, 1);
    final readC = readBitFromByte(compression, 2);

    if (readA){
      character.weaponType = readByte();
      character.bodyType = readByte();
      character.headType = readByte();
      character.legType = readByte();
    }

    if (readB){
      final lookDirectionWeaponState = readByte();
      character.lookDirection = readNibbleFromByte1(lookDirectionWeaponState);
      final weaponState = readNibbleFromByte2(lookDirectionWeaponState);
      character.weaponState = weaponState;
    }

    if (readC) {
      character.weaponStateDuration = readByte();
    } else {
      character.weaponStateDuration = 0;
    }
  }

  void readPlayerEvent() {
    isometric.events.onPlayerEvent(readByte());
  }

  void readIsometricPosition(IsometricPosition value){
    value.x = readDouble();
    value.y = readDouble();
    value.z = readDouble();
  }

  double readPercentage() => readByte() / 255.0;

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

  CaptureTheFlagAIDecision readCaptureTheFlagAIDecision() => CaptureTheFlagAIDecision.values[readByte()];

  CaptureTheFlagAIRole readCaptureTheFlagAIRole() => CaptureTheFlagAIRole.values[readByte()];
}


int readFirstFiveBits(int byte) {
  if (byte < 0 || byte > 255) {
    throw ArgumentError('Invalid byte value. Expected values between 0 and 255.');
  }

  int result = byte & 0x11111;
  return result;
}

