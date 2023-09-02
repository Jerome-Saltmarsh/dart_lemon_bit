

import 'dart:typed_data';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:lemon_watch/src.dart';
import 'package:archive/archive.dart';
import 'package:gamestream_flutter/amulet/mmo_parser.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/classes/position.dart';
import 'package:gamestream_flutter/isometric/classes/projectile.dart';
import 'package:gamestream_flutter/packages/lemon_bits.dart';
import 'package:lemon_byte/byte_reader.dart';
import 'package:lemon_math/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

import 'isometric_component.dart';


class IsometricParser with ByteReader, IsometricComponent {
  final bufferSize = Watch(0);

  void parseString(String value){

  }

  void parseBytes(Uint8List bytes) {
    index = 0;
    values = bytes;
    bufferSize.value = bytes.length;
    final length = bytes.length;

    while (index < length) {
      readServerResponse(readByte());
    }

    onReadRespondFinished();
    index = 0;
  }

  void onReadRespondFinished() {
    if (options.renderResponse){
      engine.redrawCanvas();
    }
  }

  void readServerResponseString(String response){

  }

  void readServerResponse(int serverResponse){
    options.rendersSinceUpdate.value = 0;

    switch (serverResponse) {
      case NetworkResponse.Isometric_Characters:
        readIsometricCharacters();
        break;
      case NetworkResponse.Api_Player:
        readApiPlayer();
        break;
      case NetworkResponse.Player:
        player.parsePlayerResponse();
        break;
      case NetworkResponse.Isometric:
        readIsometricResponse();
        break;
      case NetworkResponse.GameObject:
        readGameObject();
        break;
      case NetworkResponse.Projectiles:
        readProjectiles();
        break;
      case NetworkResponse.Game_Event:
        readGameEvent();
        break;
      case NetworkResponse.Player_Event:
        readPlayerEvent();
        break;
      case NetworkResponse.Game_Time:
        readGameTime();
        break;
      case NetworkResponse.Game_Type:
        final index = readByte();
        if (index >= GameType.values.length){
          throw Exception('invalid game type index $index');
        }
        options.gameType.value = GameType.values[index];
        break;
      case NetworkResponse.Environment:
        readServerResponseEnvironment();
        break;
      case NetworkResponse.Node:
        readNode();
        break;
      case NetworkResponse.Player_Target:
        readIsometricPosition(player.target);
        break;
      case NetworkResponse.Store_Items:
        readStoreItems();
        break;
      case NetworkResponse.Npc_Talk:
        readNpcTalk();
        break;
      case NetworkResponse.Weather:
        readWeather();
        break;
      case NetworkResponse.Game_Properties:
        readGameProperties();
        break;
      case NetworkResponse.Map_Coordinate:
        readMapCoordinate();
        break;
      case NetworkResponse.Editor_GameObject_Selected:
        readEditorGameObjectSelected();
        break;
      case NetworkResponse.Info:
        readServerResponseInfo();
        break;
      case NetworkResponse.MMO:
        readMMOResponse();
        break;
      case NetworkResponse.Amulet_Player:
        readNetworkResponseAmulet();
        break;
      case NetworkResponse.Download_Scene:
        final name = readString();
        final length = readUInt16();
        final bytes = readBytes(length);
        downloadBytes(bytes: bytes, name: '$name.scene');
        break;
      case NetworkResponse.GameObject_Deleted:
        scene.removeGameObjectById(readUInt16());
        break;
      case NetworkResponse.Game_Error:
        final errorTypeIndex = readByte();
        options.error.value = GameError.fromIndex(errorTypeIndex);
        return;
      case NetworkResponse.FPS:
        options.serverFPS.value = readUInt16();
        return;
      case NetworkResponse.Sort_GameObjects:
        scene.gameObjects.sort();
        break;
      case NetworkResponse.Scene:
        parseServerResponseScene();
        break;
      case NetworkResponse.Editor_Response:
        parseEditorResponse();
        break;


      default:
        print('read error; index: $index');
        print(values);
        network.websocket.disconnect();
        return;
    }
  }


  void readIsometricResponse() {
    switch (readByte()) {

      case IsometricResponse.Selected_Collider:
        readSelectedCollider();
        break;

      case IsometricResponse.Scene:
        readScene();
        break;

      case IsometricResponse.Player_Position:
        readIsometricPlayerPosition();
        break;

      case IsometricResponse.Player_Aim_Target:
        readPlayerAimTarget();
        break;

      case IsometricResponse.Player_Position_Change:
        final position = player.position;
        player.savePositionPrevious();
        final changeX = readInt8().toDouble();
        final changeY = readInt8().toDouble();
        final changeZ = readInt8().toDouble();
        position.x += changeX;
        position.y += changeY;
        position.z += changeZ;
        player.indexColumn = position.indexColumn;
        player.indexRow = position.indexRow;
        player.indexZ = position.indexZ;
        player.nodeIndex = scene.getIndexPosition(position);
        break;

      case IsometricResponse.Player_Accuracy:
        player.accuracy.value = readPercentage();
        break;

      case IsometricResponse.Player_Weapon_Duration_Percentage:
        player.weaponCooldown.value = readPercentage();
        break;

      case IsometricResponse.GameObjects:
        scene.gameObjects.clear();
        break;

      case IsometricResponse.Player_Initialized:
        player.onPlayerInitialized();
        break;

      case IsometricResponse.Player_Controls:
        player.controlsCanTargetEnemies.value = readBool();
        player.controlsRunInDirectionEnabled.value = readBool();
        break;
    }
  }


  void readSelectedCollider() {
    debug.selectedCollider.value = readBool();

    if (!debug.selectedCollider.value)
      return;

    final selectedColliderType = readByte();
    debug.selectedColliderType.value = selectedColliderType;

    if (selectedColliderType == IsometricType.GameObject) {
      debug.runTimeType.value = readString();
      debug.team.value = readUInt16();
      debug.radius.value = readUInt16();
      debug.health.value = readUInt16();
      debug.healthMax.value = readUInt16();
      debug.x.value = readDouble();
      debug.y.value = readDouble();
      debug.z.value = readDouble();
      debug.position.x = debug.x.value;
      debug.position.y = debug.y.value;
      debug.position.z = debug.z.value;
      debug.selectedGameObjectType.value = readByte();
      debug.selectedGameObjectSubType.value = readByte();
      return;
    }

    if (selectedColliderType == IsometricType.Character){
      debug.runTimeType.value = readString();
      debug.characterAction.value = readByte();
      debug.goal.value = readByte();
      debug.team.value = readUInt16();
      debug.radius.value = readUInt16();
      debug.health.value = readUInt16();
      debug.healthMax.value = readUInt16();
      debug.x.value = readDouble();
      debug.y.value = readDouble();
      debug.z.value = readDouble();
      debug.position.x = debug.x.value;
      debug.position.y = debug.y.value;
      debug.position.z = debug.z.value;
      debug.destinationX.value = readDouble();
      debug.destinationY.value = readDouble();
      debug.pathIndex.value = readInt16();
      debug.pathEnd.value = readInt16();
      debug.pathTargetIndex.value = readInt16();
      for (var i = 0; i < debug.pathEnd.value; i++) {
        debug.path[i] = readUInt16();
      }

      debug.characterType.value = readByte();
      debug.characterState.value = readByte();
      debug.characterComplexion.value = readByte();
      debug.characterStateDuration.value = readInt16();
      debug.characterStateDurationRemaining.value = readUInt16();

      debug.weaponType.value = readUInt16();
      debug.weaponDamage.value = readUInt16();
      debug.weaponRange.value = readUInt16();
      debug.weaponState.value = readByte();
      debug.weaponStateDuration.value = readUInt16();

      debug.autoAttack.value = readBool();
      debug.pathFindingEnabled.value = readBool();
      debug.runToDestinationEnabled.value = readBool();
      debug.arrivedAtDestination.value = readBool();

      final characterSelectedTarget = readBool();
      debug.targetSet.value = characterSelectedTarget;
      if (!characterSelectedTarget) return;
      debug.targetType.value = readString();
      debug.targetX.value = readDouble();
      debug.targetY.value = readDouble();
      debug.targetZ.value = readDouble();
    }
  }

  void readScene() {
    final scenePart = readByte(); /// DO NOT DELETE
    ///
    scene.totalZ = readUInt16();
    scene.totalRows = readUInt16();
    scene.totalColumns = readUInt16();

    final compressedNodeTypeLength = readUInt24();
    final compressedNodeOrientationsLength = readUInt24();

    final compressedNodeTypes = readUint8List(compressedNodeTypeLength);
    final compressedNodeOrientations = readUint8List(compressedNodeOrientationsLength);

    final scenePartMarks = readByte(); /// DO NOT DELETE
    final marksLength = readUInt16();
    final marks = readUint32List(marksLength);
    scene.marks = marks;
    scene.marksChangedNotifier.value++;

    final decoder = ZLibDecoder();
    scene.nodeTypes = Uint8List.fromList(decoder.decodeBytes(compressedNodeTypes));
    scene.nodeOrientations = Uint8List.fromList(decoder.decodeBytes(compressedNodeOrientations));
    scene.area = scene.totalRows * scene.totalColumns;
    scene.area2 = scene.area * 2;
    scene.projection = scene.area2 + scene.totalColumns + 1;
    scene.projectionHalf =  scene.projection ~/ 2;
    final totalNodes = scene.totalZ * scene.totalRows * scene.totalColumns;
    scene.totalNodes = totalNodes;
    if (scene.colorStack.length != totalNodes){
      scene.colorStack = Uint16List(totalNodes);
      scene.ambientStack = Uint16List(totalNodes);
      scene.nodeColors = Uint32List(totalNodes);
    }
    scene.colorStack.fillRange(0, scene.colorStack.length, scene.ambientColor);
    events.onChangedNodes();
    scene.nodesChangedNotifier.value++;
    io.recenterCursor();
  }

  void readIsometricPlayerPosition() {
    final position = player.position;
    player.savePositionPrevious();
    readIsometricPosition(position);
    player.indexColumn = position.indexColumn;
    player.indexRow = position.indexRow;
    player.indexZ = position.indexZ;
    player.nodeIndex = scene.getIndexPosition(position);
    player.areaNodeIndex = (position.indexRow * scene.totalColumns) + position.indexColumn;
  }

  void readPlayerAimTarget() {
    final aimTargetSet = readBool();
    player.aimTargetSet.value = aimTargetSet;
    if (aimTargetSet) {
      player.aimTargetName.value = readString();
    } else {
      player.aimTargetName.value = '';
    }
  }

  void readServerResponseEnvironment() {
    switch (readByte()) {
      case NetworkResponseEnvironment.Rain:
        environment.rainType.value = readByte();
        break;
      case NetworkResponseEnvironment.Lightning:
        environment.lightningType.value = readByte();
        break;
      case NetworkResponseEnvironment.Wind:
        environment.wind.value = readByte();
        break;
      case NetworkResponseEnvironment.Breeze:
        environment.weatherBreeze.value = readBool();
        break;
      case NetworkResponseEnvironment.Lightning_Flashing:
        final flashing = readBool();
        environment.lightningFlashing01 = readPercentage();
        if (environment.lightningFlashing != flashing){
          rendererNodes.lightningFlashing = flashing;
          environment.lightningFlashing = flashing;
          if (flashing) {
            audio.thunder(1.0);
          }
        }
        break;
      case NetworkResponseEnvironment.Time_Enabled:
        environment.timeEnabled.value = readBool();
        break;
    }
  }

  void readGameObject() {
    final id = readUInt16();
    final gameObject = scene.findOrCreateGameObject(id);
    gameObject.active = readBool();
    gameObject.type = readByte();
    gameObject.subType = readByte();
    gameObject.health = readUInt16();
    gameObject.maxHealth = readUInt16();
    readIsometricPosition(gameObject);
  }

  void readApiPlayer() {
    final apiPlayer = readByte();
    switch (apiPlayer) {
      case ApiPlayer.Aim_Target_Position:
        readIsometricPosition(player.aimTargetPosition);
        break;
      case ApiPlayer.Aim_Target_Type:
        player.aimTargetType = readUInt16();
        break;
      case ApiPlayer.Aim_Target_Quantity:
        player.aimTargetQuantity = readUInt16();
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
        break;
      case ApiPlayer.Health:
        readPlayerHealth();
        break;
      case ApiPlayer.Aim_Angle:
        player.mouseAngle = readAngle();
        break;
      case ApiPlayer.Message:
        player.message.value = readString();
        break;
      case ApiPlayer.Alive:
        player.alive.value = readBool();
        // ui.mouseOverDialog.setFalse();
        break;
      case ApiPlayer.Spawned:
        camera.centerOnChaseTarget();
        io.recenterCursor();
        break;
      case ApiPlayer.Damage:
        player.weaponDamage.value = readUInt16();
        break;
      case ApiPlayer.Id:
        player.id.value = readUInt24();
        break;
      case ApiPlayer.Active:
        player.active.value = readBool();
        break;
      case ApiPlayer.Team:
        player.team.value = readByte();
        break;
      default:
        throw Exception('Cannot parse apiPlayer $apiPlayer');
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

  void readApiPlayerEnergy() =>
      player.energyPercentage = readPercentage();

  void readPlayerHealth() {
    player.health.value = readUInt16();
    player.maxHealth.value = readUInt16();
  }

  void readMapCoordinate() {
    readByte(); // DO NOT DELETE
  }

  void readEditorGameObjectSelected() {
    // readVector3(isometricEngine.editor.gameObject);

    final id = readUInt16();
    final gameObject = scene.findGameObjectById(id);
    if (gameObject == null) throw Exception('could not find gameobject with id $id');
    editor.gameObject.value = gameObject;
    editor.gameObjectSelectedCollidable   .value = readBool();
    editor.gameObjectSelectedFixed        .value = readBool();
    editor.gameObjectSelectedCollectable  .value = readBool();
    editor.gameObjectSelectedPhysical     .value = readBool();
    editor.gameObjectSelectedPersistable  .value = readBool();
    editor.gameObjectSelectedGravity      .value = readBool();

    editor.gameObjectSelectedType.value          = gameObject.type;
    editor.gameObjectSelectedSubType.value       = gameObject.subType;
    editor.gameObjectSelected.value              = true;
    editor.cameraCenterSelectedObject();

    editor.gameObjectSelectedEmission.value = gameObject.colorType;
    editor.gameObjectSelectedEmissionIntensity.value = gameObject.emissionIntensity;
  }

  void readIsometricCharacters(){
    scene.totalCharacters = 0;

    while (true) {

      final compressionLevel = readByte();
      if (compressionLevel == CHARACTER_END) break;
      final character = scene.getCharacterInstance();

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

      if (const [
        CharacterType.Template,
        CharacterType.Kid
      ].contains(character.characterType)){
        readCharacterTemplate(character);
      }

      character.actionComplete = readPercentage();

      scene.totalCharacters++;
    }
  }

  void readNpcTalk() {
    player.npcTalk.value = readString();
    final totalOptions = readByte();
    final options = <String>[];
    for (var i = 0; i < totalOptions; i++) {
      options.add(readString());
    }
    player.npcTalkOptions.value = options;
  }

  void readGameProperties() {
    scene.sceneEditable.value = readBool();
    options.sceneName.value = readString();
    options.gameRunning.value = readBool();
  }

  void readWeather() {
    environment.rainType.value = readByte();
    environment.weatherBreeze.value = readBool();
    environment.lightningType.value = readByte();
    environment.wind.value = readByte();
    environment.myst.value = readByte();
  }

  void readStoreItems() {
    final length = readUInt16();
    if (player.storeItems.value.length != length){
      player.storeItems.value = Uint16List(length);
    }
    for (var i = 0; i < length; i++){
      player.storeItems.value[i] = readUInt16();
    }
  }

  void readNode() {
    print('parser.readNode()');
    final nodeIndex = readUInt24();
    final nodeType = readByte();
    final nodeOrientation = readByte();
    scene.setNode(
        index: nodeIndex,
        nodeType: nodeType,
        nodeOrientation: nodeOrientation,
    );
  }

  void readPlayerTarget() {
    readIsometricPosition(player.abilityTarget);
  }

  void readGameTime() {
    environment.seconds.value = readUInt24();
  }

  double readDouble() => readInt16().toDouble();

  void readGameEvent(){
    final type = readByte();
    final x = readDouble();
    final y = readDouble();
    final z = readDouble();
    final angle = readDouble() * degreesToRadians;
    events.onGameEvent(type, x, y, z, angle);
  }

  void readProjectiles(){
    final projectiles = scene.projectiles;
    scene.totalProjectiles = readUInt16();
    while (scene.totalProjectiles >= projectiles.length){
      projectiles.add(Projectile());
    }
    for (var i = 0; i < scene.totalProjectiles; i++) {
      final projectile = projectiles[i];
      projectile.x = readDouble();
      projectile.y = readDouble();
      projectile.z = readDouble();
      projectile.type = readByte();
      projectile.angle = readDouble() * degreesToRadians;
    }
  }

  void readCharacterTemplate(Character character){

    final compression = readByte();

    final readA = readBitFromByte(compression, 0);

    if (readA) {
      character.weaponType = readByte();
      character.bodyType = readByte();
      character.headType = readByte();
      character.legType = readByte();
      character.handTypeLeft = readByte();
      character.handTypeRight = readByte();
    }

    character.complexion = readByte();
  }

  void readPlayerEvent() {
    events.onPlayerEvent(readByte());
  }

  void readIsometricPosition(Position value){
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

  void parseServerResponseScene() {
    switch (readByte()){
      case NetworkResponseScene.Marks:
        final length = readUInt16();
        scene.marks = Uint32List(length);
        for (var i = 0; i < length; i++) {
          scene.marks[i] = readUInt32();
        }
        scene.marksChangedNotifier.value++;
        break;
    }
  }

  void parseEditorResponse() {
    switch (readByte()){
      case NetworkResponseEditor.Selected_Mark_List_Index:
        editor.selectedMarkListIndex.value = readInt16();
        break;
    }
  }

  void readNetworkResponseAmulet() {
    switch (readByte()) {
      case NetworkResponseAmulet.Character_Created:
        amulet.characterCreated.value = readBool();
        break;
    }
  }
}