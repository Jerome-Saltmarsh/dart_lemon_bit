import 'dart:typed_data';
import 'package:amulet_flutter/amulet/classes/item_slot.dart';
import 'package:amulet_flutter/gamestream/isometric/enums/emission_type.dart';
import 'package:amulet_engine/packages/common.dart';
import 'package:amulet_engine/packages/lemon_math.dart';
import 'package:amulet_engine/packages/lemon_bits.dart';
import 'package:lemon_watch/src.dart';
import 'package:archive/archive.dart';
import 'package:amulet_flutter/amulet/amulet_parser.dart';
import 'package:amulet_flutter/isometric/classes/character.dart';
import 'package:amulet_flutter/isometric/classes/position.dart';
import 'package:amulet_flutter/isometric/classes/projectile.dart';
import 'package:lemon_byte/byte_reader.dart';
import 'package:lemon_widgets/lemon_widgets.dart';


import 'isometric_component.dart';


class IsometricParser with ByteReader, IsometricComponent implements Sink<Uint8List>{
  final bufferSize = Watch(0);
  final decoder = ZLibDecoder();
  var debugging = false;

  @override
  void add(Uint8List bytes) {
    values = bytes;
    index = 0;
    bufferSize.value = bytes.length;
    options.rendersSinceUpdate.value = 0;
    try {
     parseValues();
    } catch (exception) {
      debugParseValues();
    }
    onReadResponseFinished();
    index = 0;
  }

  void parseValues(){
    final length = values.length;
    index = 0;
    while (index < length) {
      readServerResponse(readByte());
    }
  }

  void onReadResponseFinished() {
    if (options.renderResponse){
      engine.redrawCanvas();
    }
  }

  void addString(String message){

  }

  void readServerResponse(int serverResponse){

    if (debugging) {
      print('debug_network_response[${NetworkResponse.getName(serverResponse)}]');
    }

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
      case NetworkResponse.Environment:
        readNetworkResponseEnvironment();
        break;
      case NetworkResponse.Amulet:
        readNetworkResponseAmulet();
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
      case NetworkResponse.Options:
        readNetworkResponseOptions();
        break;
      default:
        handleInvalidNetworkResponse(serverResponse);
        return;
    }
  }

  void readNetworkResponsePlayer() {
    player.readNetworkResponsePlayer();
  }

  void handleInvalidNetworkResponse(int value) {
    debugParseValues();
    server.disconnect();
  }

  void debugParseValues(){
    if (debugging) return;
    print('isometricParser.debugParseValues()');
    print(values);
    ui.error.value = 'failed to parse response from server';
    debugging = true;
    parseValues();
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

      case NetworkResponseIsometric.Player_Weapon_Duration_Percentage:
        player.weaponCooldown.value = readPercentage();
        break;

      case NetworkResponseIsometric.GameObjects:
        scene.gameObjects.clear();
        break;

      case NetworkResponseIsometric.Player_Controls:
        player.controlsCanTargetEnemies.value = readBool();
        player.controlsRunInDirectionEnabled.value = readBool();
        break;

      case NetworkResponseIsometric.Seconds_Per_Frame:
        options.secondsPerFrame.value = readUInt16();
        break;
    }
  }

  void readGameRunning() {
    options.gameRunning.value = readBool();
  }

  void readItemSlot(ItemSlot itemSlot) {
    final type = readInt16();
    itemSlot.amuletItem.value = type == -1 ? null : AmuletItem.values[type];
    itemSlot.charges.value = readUInt16();
    itemSlot.max.value = readUInt16();
    itemSlot.cooldownPercentage.value = readPercentage();
  }

  void readSelectedCollider() {
    debugger.selectedCollider.value = readBool();

    if (!debugger.selectedCollider.value)
      return;

    // final isEquippedWeapon = readBool();
    // if (isEquippedWeapon) {
    //   readItemSlot(debugger.itemSlotWeapon);
    //   readItemSlot(debugger.itemSlotPower);
    // }

    final selectedColliderType = readByte();
    debugger.selectedColliderType.value = selectedColliderType;

    if (selectedColliderType == IsometricType.GameObject) {
      debugger.runTimeType.value = readString();
      debugger.team.value = readUInt16();
      debugger.radius.value = readUInt16();
      debugger.health.value = readUInt16();
      debugger.healthMax.value = readUInt16();
      debugger.x.value = readDouble();
      debugger.y.value = readDouble();
      debugger.z.value = readDouble();
      debugger.position.x = debugger.x.value;
      debugger.position.y = debugger.y.value;
      debugger.position.z = debugger.z.value;
      debugger.selectedGameObjectType.value = readByte();
      debugger.selectedGameObjectSubType.value = readByte();
      return;
    }

    if (selectedColliderType == IsometricType.Character){
      debugger.runTimeType.value = readString();
      debugger.characterAction.value = readByte();
      debugger.goal.value = readByte();
      debugger.team.value = readUInt16();
      debugger.radius.value = readUInt16();
      debugger.health.value = readUInt16();
      debugger.healthMax.value = readUInt16();
      debugger.x.value = readDouble();
      debugger.y.value = readDouble();
      debugger.z.value = readDouble();
      debugger.position.x = debugger.x.value;
      debugger.position.y = debugger.y.value;
      debugger.position.z = debugger.z.value;
      debugger.destinationX.value = readDouble();
      debugger.destinationY.value = readDouble();
      debugger.pathIndex.value = readInt16();
      debugger.pathEnd.value = readInt16();
      debugger.pathTargetIndex.value = readInt16();
      for (var i = 0; i < debugger.pathEnd.value; i++) {
        debugger.path[i] = readUInt16();
      }

      debugger.characterType.value = readByte();
      debugger.characterState.value = readByte();
      debugger.characterComplexion.value = readByte();
      debugger.characterStateDuration.value = readInt16();
      debugger.characterStateDurationRemaining.value = readUInt16();

      debugger.weaponType.value = readUInt16();
      debugger.weaponDamage.value = readUInt16();
      debugger.weaponRange.value = readUInt16();
      debugger.weaponState.value = readByte();
      debugger.weaponStateDuration.value = readUInt16();

      debugger.autoAttack.value = readBool();
      debugger.pathFindingEnabled.value = readBool();
      debugger.runToDestinationEnabled.value = readBool();
      debugger.arrivedAtDestination.value = readBool();

      final characterSelectedTarget = readBool();
      debugger.targetSet.value = characterSelectedTarget;
      if (!characterSelectedTarget) return;
      debugger.targetType.value = readString();
      debugger.targetX.value = readDouble();
      debugger.targetY.value = readDouble();
      debugger.targetZ.value = readDouble();
    }
  }

  void readScene() {
    options.game.value = options.amulet;

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
    scene.loaded = true;
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
    gameObject.subType = readUInt16();
    gameObject.health = readUInt16();
    gameObject.maxHealth = readUInt16();
    readIsometricPosition(gameObject);

    if (gameObject.type == ItemType.Object && gameObject.subType == GameObjectType.Crystal_Glowing_False){
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
    final editor = this.editor;
    editor.gameObject.value = gameObject;
    editor.gameObjectSelectedHitable.value = readBool();
    editor.gameObjectSelectedFixed.value = readBool();
    editor.gameObjectSelectedCollectable.value = readBool();
    editor.gameObjectSelectedPhysical.value = readBool();
    editor.gameObjectSelectedPersistable.value = readBool();
    editor.gameObjectSelectedGravity.value = readBool();
    editor.gameObjectSelectedInteractable.value = readBool();
    editor.gameObjectSelectedCollidable.value = readBool();

    editor.gameObjectSelectedType.value          = gameObject.type;
    editor.gameObjectSelectedSubType.value       = gameObject.subType;

    editor.gameObjectSelectedEmission.value = gameObject.emissionType;
    editor.gameObjectSelectedEmissionIntensity.value = gameObject.emissionIntensity;
  }

  var bytesSaved = 0;

  void readNetworkResponseCharacters(){
    final scene = this.scene;
    scene.totalCharacters = 0;

    while (readBool()) {
      final compressionA = readByte();
      final character = scene.getCharacterInstance();
      final readCharacterTypeAndTeam = readBitFromByte(compressionA, 0);
      final readCharacterState = readBitFromByte(compressionA, 1);
      final readHealth = readBitFromByte(compressionA, 2);
      final readAilments = readBitFromByte(compressionA, 3);
      final readDirection = readBitFromByte(compressionA, 4);
      final readFrameChanged = readBitFromByte(compressionA, 5);
      final readFrameChangedByOne = readBitFromByte(compressionA, 6);
      final readPosition = readBitFromByte(compressionA, 7);

      if (readCharacterTypeAndTeam) {
        final value = readByte();
        final characterType = value & Hex00111111;
        final team = value >> 6;
        character.characterType = characterType;
        character.team = team;
      }

      if (readCharacterState) {
        character.state = readByte();
      }

      if (readHealth) {
        character.health = readPercentage();
      }

      if (readAilments){
        character.ailments = readByte();
      }

      if (readDirection) {
        character.direction = readByte();
      }

      if (readFrameChanged) {
        if (readFrameChangedByOne){
          bytesSaved++;
          character.animationFrame++;
        } else {
          character.animationFrame = readByte();
        }
      }

      if (readPosition){
        final compressionB = readByte();
        final changeTypeX = (compressionB & Hex00001100) >> 2;
        final changeTypeY =  (compressionB & Hex00110000) >> 4;
        final changeTypeZ = (compressionB & Hex11000000) >> 6;
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
      }

      if (character.characterType == CharacterType.Human){
        readCharacterTemplate(character);
      }

      if (CharacterState.supportsAction.contains(character.state)){
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
    events.onGameEvent(type, x, y, z);
  }

  void readNetworkResponseProjectiles(){
    final projectiles = scene.projectiles;
    var i = 0;

    while (readBool()){
      if (i >= projectiles.length){
        projectiles.add(Projectile());
      }
      final projectile = projectiles[i];
      projectile.x = readDouble();
      projectile.y = readDouble();
      projectile.z = readDouble();
      projectile.type = readByte();
      projectile.angle = readDouble() * degreesToRadians;
      i++;
    }
    scene.totalProjectiles = i;
  }

  // TODO OPTIMIZE
  void readCharacterTemplate(Character character){

    final compression = readByte();
    final readA = readBitFromByte(compression, 0);
    final readB = readBitFromByte(compression, 1);
    final readC = readBitFromByte(compression, 2);

    if (readA) {
      character.weaponType = readByte();
      character.armorType = readByte();
      character.helmType = readByte();
      character.legType = readByte();
    }

    if (readB) {
      character.complexion = readByte();
      character.shoeType = readByte();
      character.gender = readByte();
      character.headType = readByte();
    }

    if (readC){
      character.handTypeLeft = readByte();
      character.handTypeRight = readByte();
      character.hairType = readByte();
      character.hairColor = readByte();
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
    final marks = Uint32List(length);
    scene.marks = marks;
    for (var i = 0; i < length; i++) {
      marks[i] = readUInt32();
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

  // void readNetworkResponseAmuletPlayer() {
  //   final amulet = this.amulet;
  //   switch (readByte()) {
  //
  //   }
  // }

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
    options.cameraPlayFollowPlayer = !cameraTargetSet;
    if (cameraTargetSet) {
      readIsometricPosition(options.cameraPlay);
    }
  }

  void readZoom() {
    final value = readDouble();
    engine.targetZoom = value / 10.0;
  }

  void readNetworkResponseOptions() {
    switch (readByte()){
      case NetworkResponseOptions.setTimeVisible:
        options.timeVisible.value = readBool();
        break;
      case NetworkResponseOptions.setHighlightIconInventory:
        options.highlightIconInventory.value = readBool();
        break;
      default:
        throw Exception('invalid readNetworkResponseOptions()');
    }
  }

  @override
  void close() {
    // TODO: implement close
  }
}