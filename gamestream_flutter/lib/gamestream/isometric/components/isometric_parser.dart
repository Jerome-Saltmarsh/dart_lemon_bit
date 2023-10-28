

import 'dart:typed_data';
import 'package:gamestream_flutter/gamestream/isometric/enums/emission_type.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:lemon_watch/src.dart';
import 'package:archive/archive.dart';
import 'package:gamestream_flutter/amulet/amulet_parser.dart';
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
  final decoder = ZLibDecoder();

  void parseString(String value){

  }

  void parseBytes(Uint8List bytes) {
    index = 0;
    values = bytes;
    bufferSize.value = bytes.length;
    options.rendersSinceUpdate.value = 0;
    final length = bytes.length;

    while (index < length) {
      readServerResponse(readByte());
    }

    onReadResponseFinished();
    index = 0;
  }

  void onReadResponseFinished() {
    if (options.renderResponse){
      engine.redrawCanvas();
    }
  }

  void readServerResponseString(String response){

  }

  void readServerResponse(int serverResponse){
    switch (serverResponse) {
      case NetworkResponse.Characters:
        readNetworkResponseCharacters();
        break;
      case NetworkResponse.Player:
        readNetworkResponsePlayer();
        break;
      case NetworkResponse.Isometric:
        readNetworkResponseIsometric();
        break;
      case NetworkResponse.GameObject:
        readNetworkResponseGameObject();
        break;
      case NetworkResponse.Projectiles:
        readNetworkResponseProjectiles();
        break;
      case NetworkResponse.Game_Event:
        readNetworkResponseGameEvent();
        break;
      case NetworkResponse.Player_Event:
        readNetworkResponsePlayerEvent();
        break;
      case NetworkResponse.Game_Time:
        readNetworkResponseGameTime();
        break;
      case NetworkResponse.Game_Type:
        readNetworkResponseGameType();
        break;
      case NetworkResponse.Environment:
        readNetworkResponseEnvironment();
        break;
      case NetworkResponse.Amulet:
        readNetworkResponseAmulet();
        break;
      case NetworkResponse.Amulet_Player:
        readNetworkResponseAmuletPlayer();
        break;
      case NetworkResponse.Game_Error:
        readNetworkResponseGameError();
        break;
      case NetworkResponse.FPS:
        readNetworkResponseFPS();
        break;
      case NetworkResponse.Scene:
        readNetworkResponseScene();
        break;
      case NetworkResponse.Editor:
        readNetworkResponseEditor();
        break;
      case NetworkResponse.Server_Error:
        readNetworkServerError();
        break;
      default:
        readNetworkResponseDefault();
        return;
    }
  }

  void readNetworkResponsePlayer() {
    player.readNetworkResponsePlayer();
  }

  void readNetworkResponseDefault() {
    print('read error; index: $index');
    print(values);
    ui.error.value = 'failed to parse response from server';
    network.websocket.disconnect();
  }

  void readSortGameObjects() {
    scene.gameObjects.sort();
  }

  void readNetworkResponseFPS() {
    options.serverFPS.value = readUInt16();
  }

  void readNetworkResponseGameError() {
    final errorTypeIndex = readByte();
    options.gameError.value = GameError.fromIndex(errorTypeIndex);
  }

  void readGameObjectDeleted() {
    scene.removeGameObjectById(readUInt16());
  }

  void readDownloadScene() {
    final name = readString();
    final length = readUInt16();
    final bytes = readBytes(length);
    downloadBytes(bytes: bytes, name: '$name.scene');
  }

  void readNetworkResponseGameType() {
    final index = readByte();
    if (index >= GameType.values.length){
      throw Exception('invalid game type index $index');
    }
    options.gameType.value = GameType.values[index];
  }

  void readNetworkResponseIsometric() {
    switch (readByte()) {

      case NetworkResponseIsometric.Zoom:
        readZoom();
        break;

      case NetworkResponseIsometric.Edit_Enabled:
        readEditEnabled();
        break;

      case NetworkResponseIsometric.Selected_Collider:
        readSelectedCollider();
        break;

      case NetworkResponseIsometric.Scene:
        readScene();
        break;

      case NetworkResponseIsometric.Game_Running:
        readGameRunning();
        break;

      case NetworkResponseIsometric.Player_Aim_Target:
        readPlayerAimTarget();
        break;

      case NetworkResponseIsometric.Player_Accuracy:
        player.accuracy.value = readPercentage();
        break;

      case NetworkResponseIsometric.Player_Weapon_Duration_Percentage:
        player.weaponCooldown.value = readPercentage();
        break;

      case NetworkResponseIsometric.GameObjects:
        scene.gameObjects.clear();
        break;

      // case NetworkResponseIsometric.Player_Initialized:
      //   player.onPlayerInitialized();
      //   break;

      case NetworkResponseIsometric.Player_Controls:
        player.controlsCanTargetEnemies.value = readBool();
        player.controlsRunInDirectionEnabled.value = readBool();
        break;
    }
  }

  void readGameRunning() {
    options.gameRunning.value = readBool();
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

    print('readScene()');
    final scenePart = readByte(); /// DO NOT DELETE

    final scene = this.scene;
    scene.clearVisited();
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

    final scenePartKeys = readByte(); /// DO NOT DELETE
    readNetworkResponseSceneKeys();

    final scenePartVariations = readByte(); /// DO NOT DELETE
    final compressedVariationsLength = readUInt24();
    final compressedVariations = readUint8List(compressedVariationsLength);
    scene.nodeVariations = Uint8List.fromList(decoder.decodeBytes(compressedVariations));

    scene.nodeTypes = Uint8List.fromList(decoder.decodeBytes(compressedNodeTypes));
    scene.nodeOrientations = Uint8List.fromList(decoder.decodeBytes(compressedNodeOrientations));
    scene.colorStack.fillRange(0, scene.colorStack.length, scene.ambientColor);
    events.onChangedNodes();
    particles.clearParticles();
    io.recenterCursor();
  }

  // void readIsometricPlayerPosition() {
  //   final position = player.position;
  //   readIsometricPosition(position);
  //   player.updateIndexes();
  // }

  void readPlayerAimTarget() {
    final aimTargetSet = readBool();
    player.aimTargetSet.value = aimTargetSet;
    if (aimTargetSet) {
      player.aimTargetName.value = readString();
    } else {
      player.aimTargetName.value = '';
    }
  }

  void readNetworkResponseEnvironment() {
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
      case NetworkResponseEnvironment.Weather:
        readNetworkResponseWeather();
        break;
    }
  }

  void readNetworkResponseGameObject() {
    final id = readUInt16();
    final gameObject = scene.findOrCreateGameObject(id);
    gameObject.active = readBool();
    gameObject.type = readByte();
    gameObject.subType = readByte();
    gameObject.health = readUInt16();
    gameObject.maxHealth = readUInt16();
    readIsometricPosition(gameObject);

    if (gameObject.type == ItemType.Object && gameObject.subType == ObjectType.Crystal_Glowing_False){
      gameObject.emissionType = EmissionType.Zero;
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

  void readApiPlayerEnergy() =>
      player.energyPercentage = readPercentage();

  void readPlayerHealth() {
    player.health.value = readUInt16();
    player.maxHealth.value = readUInt16();
  }

  void readNetworkResponseEditorGameObjectSelected() {
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

    editor.gameObjectSelectedEmission.value = gameObject.emissionType;
    editor.gameObjectSelectedEmissionIntensity.value = gameObject.emissionIntensity;
  }

  void readNetworkResponseCharacters(){
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

      switch (changeTypeX) {
        case ChangeType.None:
          break;
        case ChangeType.One:
          character.x++;
          break;
        case ChangeType.Delta:
          character.x += readInt8();
          break;
        case ChangeType.Absolute:
          character.x = readInt16().toDouble();
          break;
      }

      switch (changeTypeY) {
        case ChangeType.None:
          break;
        case ChangeType.One:
          character.y++;
          break;
        case ChangeType.Delta:
          character.y += readInt8();
          break;
        case ChangeType.Absolute:
          character.y = readInt16().toDouble();
          break;
      }

      switch (changeTypeZ) {
        case ChangeType.None:
          break;
        case ChangeType.One:
          character.z++;
          break;
        case ChangeType.Delta:
          character.z += readInt8();
          break;
        case ChangeType.Absolute:
          character.z = readInt16().toDouble();
          break;
      }

      if (character.characterType == CharacterType.Kid){
        readCharacterTemplate(character);
      }

      if (const[
        CharacterState.Strike,
        CharacterState.Fire,
      ].contains(character.state)){
        character.actionComplete = readPercentage();
      } else {
        character.actionComplete = 0;
      }


      scene.totalCharacters++;
    }
  }

  void readEditEnabled() {
    scene.editEnabled.value = readBool();
  }

  void readNetworkResponseWeather() {
    final environment = this.environment;
    environment.rainType.value = readByte();
    environment.weatherBreeze.value = readBool();
    environment.lightningType.value = readByte();
    environment.wind.value = readByte();
    environment.myst.value = readByte();
  }

  void readNode() {
    final nodeIndex = readUInt24();
    final nodeType = readByte();
    final nodeOrientation = readByte();
    final nodeVariation = readByte();
    scene.setNode(
      index: nodeIndex,
      nodeType: nodeType,
      nodeOrientation: nodeOrientation,
      variation: nodeVariation,
    );

    editor.refreshNodeSelectedIndex();
  }

  void readPlayerTarget() {
    readIsometricPosition(player.abilityTarget);
  }

  void readNetworkResponseGameTime() {
    environment.seconds.value = readUInt24();
  }

  double readDouble() => readInt16().toDouble();

  void readNetworkResponseGameEvent(){
    final type = readByte();
    final x = readDouble();
    final y = readDouble();
    final z = readDouble();
    final angle = readDouble() * degreesToRadians;
    events.onGameEvent(type, x, y, z, angle);
  }

  void readNetworkResponseProjectiles(){
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

  // TODO OPTIMIZE
  void readCharacterTemplate(Character character){

    final compression = readByte();
    final readA = readBitFromByte(compression, 0);
    final readB = readBitFromByte(compression, 1);

    if (readA) {
      character.weaponType = readByte();
      character.bodyType = readByte();
      character.helmType = readByte();
      character.legType = readByte();
      character.handTypeLeft = readByte();
      character.handTypeRight = readByte();
      character.hairType = readByte();
      character.hairColor = readByte();
    }

    if (readB) {
      character.complexion = readByte();
      character.shoeType = readByte();
      character.gender = readByte();
      character.headType = readByte();
    }
  }

  void readNetworkResponsePlayerEvent() {
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

  void readNetworkResponseScene() {
    switch (readByte()){
      case NetworkResponseScene.Node:
        readNode();
        break;
      case NetworkResponseScene.Marks:
        readMarks();
        break;
      case NetworkResponseScene.GameObject_Deleted:
        readGameObjectDeleted();
        break;
      case NetworkResponseScene.Sort_GameObjects:
        readSortGameObjects();
        break;
      case NetworkResponseScene.Download_Scene:
        readDownloadScene();
        break;
      case NetworkResponseScene.Name:
        readSceneName();
        break;
      case NetworkResponseScene.Keys:
        readNetworkResponseSceneKeys();
        break;
    }
  }

  void readSceneName() {
    options.sceneName.value = readString();
  }

  void readMarks() {
    final length = readUInt16();
    scene.marks = Uint32List(length);
    for (var i = 0; i < length; i++) {
      scene.marks[i] = readUInt32();
    }
    scene.marksChangedNotifier.value++;
  }

  void readNetworkResponseEditor() {
    switch (readByte()){
      case NetworkResponseEditor.Selected_Mark_List_Index:
        editor.selectedMarkListIndex.value = readInt16();
        break;
      case NetworkResponseEditor.Editor_GameObject_Selected:
        readNetworkResponseEditorGameObjectSelected();
        break;
    }
  }

  void readNetworkResponseAmuletPlayer() {
    final amulet = this.amulet;
    switch (readByte()) {
      case NetworkResponseAmuletPlayer.Elements:
        amulet.elementFire.value = readByte();
        amulet.elementWater.value = readByte();
        amulet.elementWind.value = readByte();
        amulet.elementEarth.value = readByte();
        amulet.elementElectricity.value = readByte();
        break;
      case NetworkResponseAmuletPlayer.Element_Points:
        amulet.elementPoints.value = readUInt16();
        break;
      case NetworkResponseAmuletPlayer.Message:
        amulet.clearMessage();
        amulet.messages.addAll(readString().split('.').map((e) => e.trim()).toList(growable: false));
        amulet.messages.removeWhere((element) => element.isEmpty);
        amulet.messageIndex.value = 0;
        break;
      case NetworkResponseAmuletPlayer.End_Interaction:
        amulet.endInteraction();
        break;
      case NetworkResponseAmuletPlayer.Camera_Target:
        readCameraTarget();
        break;
    }
  }

  void readNetworkServerError() {
    final message = readString();
    ui.error.value = message;
  }

  void readNetworkResponseSceneKeys() {
    final length = readUInt16();
    final keys = scene.keys;
    keys.clear();

    for (var i = 0; i < length; i++){
       final name = readString();
       final index = readUInt16();
       keys[name] = index;
    }
    scene.keysChangedNotifier.value++;
  }

  void readCameraTarget() {
    final cameraTargetSet = readBool();
    amulet.cameraTargetSet.value = cameraTargetSet;
    if (cameraTargetSet) {
      readIsometricPosition(amulet.cameraTarget);
    }
  }

  void readZoom() {
    final value = readDouble();
    engine.targetZoom = value / 10.0;
  }
}