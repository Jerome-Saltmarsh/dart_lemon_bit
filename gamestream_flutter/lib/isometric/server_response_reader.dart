import 'dart:typed_data';

import 'package:bleed_common/api_player.dart';
import 'package:bleed_common/character_type.dart';
import 'package:bleed_common/environment_response.dart';
import 'package:bleed_common/game_option.dart';
import 'package:bleed_common/game_waves_response.dart';
import 'package:bleed_common/library.dart';
import 'package:bleed_common/node_orientation.dart';
import 'package:bleed_common/quest.dart';
import 'package:bleed_common/type_position.dart';
import 'package:gamestream_flutter/control/state/game_type.dart';
import 'package:gamestream_flutter/isometric/characters.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:gamestream_flutter/isometric/classes/weapon.dart';
import 'package:gamestream_flutter/isometric/edit.dart';
import 'package:gamestream_flutter/isometric/events/on_changed_scene.dart';
import 'package:gamestream_flutter/isometric/events/on_game_event.dart';
import 'package:gamestream_flutter/isometric/events/on_player_event.dart';
import 'package:gamestream_flutter/isometric/floating_texts.dart';
import 'package:gamestream_flutter/isometric/game.dart';
import 'package:gamestream_flutter/isometric/gameobjects.dart';
import 'package:gamestream_flutter/isometric/grid/state/wind.dart';
import 'package:gamestream_flutter/isometric/grid_state.dart';
import 'package:gamestream_flutter/isometric/io/custom_game_names.dart';
import 'package:gamestream_flutter/isometric/npcs.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
import 'package:gamestream_flutter/isometric/projectiles.dart';
import 'package:gamestream_flutter/isometric/watches/ambient_shade.dart';
import 'package:gamestream_flutter/isometric/watches/lightning.dart';
import 'package:gamestream_flutter/isometric/watches/rain.dart';
import 'package:gamestream_flutter/isometric/watches/scene_meta_data.dart';
import 'package:gamestream_flutter/isometric/weather/time_passing.dart';
import 'package:gamestream_flutter/modules/game/render.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/state/game_options.dart';
import 'package:gamestream_flutter/state/state_game_waves.dart';
import 'package:lemon_byte/byte_reader.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/enums.dart';
import 'package:lemon_math/library.dart';
import 'package:lemon_watch/watch.dart';

import 'ai.dart';
import 'camera.dart';
import 'classes/projectile.dart';
import 'grid.dart';
import 'player.dart';
import 'player_store.dart';
import 'time.dart';
import 'weather/breeze.dart';

final serverResponseReader = ServerResponseReader();
final triggerAlarmNoMessageReceivedFromServer = Watch(false);

void onChangedRendersSinceUpdate(int value){
   triggerAlarmNoMessageReceivedFromServer.value = value > 200;
}

void onChangedUpdateFrame(int value){
  rendersSinceUpdate.value = 0;
}

class ServerResponseReader with ByteReader {
  final byteLength = Watch(0);
  final bufferSize = Watch(0);
  final updateFrame = Watch(0, onChanged: onChangedUpdateFrame);

  void readBytes(Uint8List values) {
    updateFrame.value++;
    index = 0;
    totalCharacters = 0;
    totalGameObjects = 0;
    bufferSize.value = values.length;
    this.values = values;

    while (true) {
      final response = readByte();
      switch (response){
        case ServerResponse.Character_Rat:
          readCharacterRat();
          break;
        case ServerResponse.Character_Zombie:
          readCharacterZombie();
          break;
        case ServerResponse.Character_Template:
          readCharacterTemplate();
          break;
        case ServerResponse.Character_Player:
          readCharacterPlayer();
          break;
        case ServerResponse.Character_Slime:
          readCharacterSlime();
          break;
        case ServerResponse.GameObject_Static:
          readGameObjectStatic();
          break;
        case ServerResponse.GameObject:
          readGameObject();
          break;
        case ServerResponse.Game_Waves:
          readServerResponseGameWaves();
          break;
        case ServerResponse.GameObject_Loot:
          readGameObjectLoot();
          break;
        case ServerResponse.GameObject_Butterfly:
          readGameObjectButterfly();
          break;
        case ServerResponse.GameObject_Chicken:
          readGameObjectChicken();
          break;
        case ServerResponse.GameObject_Jellyfish:
          readGameObjectJellyfish();
          break;
        case ServerResponse.GameObject_Jellyfish_Red:
          readGameObjectJellyfishRed();
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
          readGrid();
          break;
        case ServerResponse.Game_Status:
          readGameStatus();
          break;
        case ServerResponse.Debug_Mode:
          readDebugMode();
          break;
        case ServerResponse.Player_Attack_Target:
          readPlayerAttackTarget();
          break;
        case ServerResponse.Player_Attack_Target_Name:
          readPlayerAttackTargetName();
          break;
        case ServerResponse.Player_Attack_Target_None:
          readPlayerAttackTargetNone();
          break;
        case ServerResponse.Damage_Applied:
          readDamageApplied();
          break;
        case ServerResponse.Paths:
          readPaths();
          break;
        case ServerResponse.Game_Time:
          readGameTime();
          break;
        case ServerResponse.Player:
          readServerResponsePlayer();
          break;
        case ServerResponse.Spawn_Particle:
          final x = readDouble();
          final y = readDouble();
          final z = readDouble();
          final particleType = readByte();
          final duration = readInt();
          final angle = readAngle();
          final speed = readDouble() * 0.01;
          final weight = readDouble() * 0.01;
          final zv = readDouble() * 0.01;
          spawnParticle(
              type: particleType,
              x: x,
              y: y,
              z: z,
              angle: angle,
              speed: speed,
              duration: duration,
              weight: weight,
              zv: zv,
          );
          break;
        case ServerResponse.Game_Type:
          gameType.value = readByte();
          break;
        case ServerResponse.Player_Slots:
          player.weaponSlot1.type.value = readByte();
          player.weaponSlot1.capacity.value = readInt();
          player.weaponSlot1.rounds.value = readInt();

          player.weaponSlot2.type.value = readByte();
          player.weaponSlot2.capacity.value = readInt();
          player.weaponSlot2.rounds.value = readInt();

          player.weaponSlot3.type.value = readByte();
          player.weaponSlot3.capacity.value = readInt();
          player.weaponSlot3.rounds.value = readInt();
          break;
        case ServerResponse.Player_Spawned:
          readPlayerSpawned();
          break;
        case ServerResponse.Player_Weapons:
          readPlayerWeapons();
          break;
        case ServerResponse.Environment:
          readServerResponseEnvironment();
          break;
        case ServerResponse.Node:
          readNode();
          break;
        case ServerResponse.Player_Target:
          readVector3(player.target);
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
        case ServerResponse.Custom_Game_Names:
          readCustomGameNames();
          break;
        case ServerResponse.Scene_Meta_Data:
          readSceneMetaData();
          break;
        case ServerResponse.Map_Coordinate:
          readMapCoordinate();
          break;
        case ServerResponse.Interacting_Npc_Name:
          readInteractingNpcName();
          break;
        case ServerResponse.Editor_GameObject_Selected:
          readEditorGameObjectSelected();
          break;
        case ServerResponse.Node_Data:
          final spawnType = readByte();
          final spawnAmount = readInt();
          final spawnRadius = readInt();
          edit.selectedNodeData.value = SpawnNodeData(
             spawnType: spawnType,
             spawnAmount: spawnAmount,
             spawnRadius: spawnRadius,
          );
          break;
        case ServerResponse.Render_Map:
          game.mapVisible.value = readBool();
          break;
        case ServerResponse.Options:
          final optionType = readByte();
          switch(optionType){
            case GameOption.Set_Control_Scheme:
              gameOptions.controlScheme.value = readByte();
              break;
          }
          break;
        default:
          throw Exception("Cannot parse $response at index: $index");
      }
    }
  }

  void readServerResponseEnvironment() {
    final environmentResponse = readByte();
    switch (environmentResponse) {
      case EnvironmentResponse.Shade:
        ambientShade.value = readByte();
        break;
      case EnvironmentResponse.Rain:
        rain.value = readRain();
        break;
      case EnvironmentResponse.Lightning:
        lightning.value = readLightning();
        break;
      case EnvironmentResponse.Wind:
        windAmbient.value = readWind();
        break;
      case EnvironmentResponse.Breeze:
        weatherBreeze.value = readBool();
        break;
    }
  }

  void readGameObject() {
    final instance = getInstanceGameObject();
    instance.type = readByte();
    readVector3(instance);
  }

  void readServerResponseGameWaves() {
    final gameWavesResponse = readByte();
    switch (gameWavesResponse) {
      case GameWavesResponse.timer:
        gameWaves.timer.value = readPercentage();
        break;
      case GameWavesResponse.round:
        gameWaves.round.value = readInt();
        break;
      case GameWavesResponse.clear_upgrades:
        gameWaves.purchasePrimary.clear();
        gameWaves.purchaseSecondary.clear();
        gameWaves.purchaseTertiary.clear();
        gameWaves.refresh.value++;
        break;
      case GameWavesResponse.purchase:
        final position = readByte();
        final type = readByte();
        final cost = readInt();
        final purchase = Purchase(type, cost);

        switch (position){
          case TypePosition.Primary:
            gameWaves.purchasePrimary.add(purchase);
            break;
          case TypePosition.Secondary:
            gameWaves.purchaseSecondary.add(purchase);
            break;
          case TypePosition.Tertiary:
            gameWaves.purchaseTertiary.add(purchase);
            break;
        }
        gameWaves.refresh.value++;
        break;
    }
  }

  void readServerResponsePlayer() {
    final apiPlayer = readByte();
    switch (apiPlayer) {
      case ApiPlayer.Position:
        player.previousPosition.x = player.x;
        player.previousPosition.y = player.y;
        player.previousPosition.z = player.z;
        readVector3(player);
        break;
      case ApiPlayer.Health:
        player.health.value = readInt();
        break;
      case ApiPlayer.Max_Health:
        player.maxHealth = readInt();
        break;
      case ApiPlayer.Armour_Type:
        player.armourType.value = readByte();
        break;
      case ApiPlayer.Head_Type:
        player.headType.value = readByte();
        break;
      case ApiPlayer.Pants_Type:
        player.pantsType.value = readByte();
        break;
      case ApiPlayer.Alive:
        player.alive.value = readBool();
        break;
      case ApiPlayer.Experience_Percentage:
        player.experience.value = readPercentage();
        break;
      case ApiPlayer.Level:
        player.level.value = readInt();
        break;
      case ApiPlayer.Aim_Angle:
        player.mouseAngle = readAngle();
        break;
      case ApiPlayer.Points:
        player.points.value = readInt();
        break;
      case ApiPlayer.Weapon_Type:
        player.weapon.type.value = readByte();
        break;
      case ApiPlayer.Weapon_Rounds:
        player.weapon.rounds.value = readInt();
        break;
      case ApiPlayer.Weapon_Capacity:
        player.weapon.capacity.value = readInt();
        break;
      default:
        throw Exception("Cannot parse apiPlayer $apiPlayer");
    }
  }

  void readGameObjectLoot() {
    final gameObject = getInstanceGameObject();
    readVector3(gameObject);
    gameObject.type = GameObjectType.Loot;
    gameObject.lootType = readByte();
  }

  void readGameObjectStatic() {
    final gameObject = getInstanceGameObject();
    readVector3(gameObject);
    gameObject.type = readByte();
  }

  void readPlayerAttackTargetName() {
    player.mouseTargetName.value = readString();
    player.mouseTargetAllie.value = readBool();
    player.mouseTargetHealth.value = readPercentage();
  }

  void readMapCoordinate() {
    player.mapTile.value = readByte();
  }

  void readEditorGameObjectSelected() {
    readVector3(edit.gameObject);
    final type = readByte();
    edit.gameObject.type = type;
    edit.gameObjectSelectedType.value = type;
    if (type == GameObjectType.Particle_Emitter){
      edit.gameObjectSelectedParticleType.value = readByte();
      edit.gameObjectSelectedParticleSpawnRate.value = readInt();
    }

    edit.gameObjectSelected.value = true;
    edit.cameraCenterSelectedObject();
  }

  void readGameObjectButterfly() {
    final gameObject = getInstanceGameObject();
    gameObject.type = GameObjectType.Butterfly;
    readVector3(gameObject);
    gameObject.direction = readByte();
  }

  void readGameObjectChicken(){
    final gameObject = getInstanceGameObject();
    gameObject.type = GameObjectType.Chicken;
    readVector3(gameObject);
    gameObject.state = readByte();
    gameObject.direction = readByte();
  }

  void readGameObjectJellyfish(){
    final gameObject = getInstanceGameObject();
    gameObject.type = GameObjectType.Jellyfish;
    readVector3(gameObject);
    gameObject.state = readByte();
    gameObject.direction = readByte();
  }

  void readGameObjectJellyfishRed(){
    final gameObject = getInstanceGameObject();
    gameObject.type = GameObjectType.Jellyfish_Red;
    readVector3(gameObject);
    gameObject.state = readByte();
    gameObject.direction = readByte();
  }

  void readCharacterRat() {
    final character = getCharacterInstance();
    character.type = CharacterType.Rat;
    readCharacter(character);
    totalCharacters++;
  }

  void readCharacterZombie() {
    final character = getCharacterInstance();
    character.type = CharacterType.Zombie;
    readCharacter(character);
    totalCharacters++;
  }

  void readCharacterSlime() {
    final character = getCharacterInstance();
    character.type = CharacterType.Slime;
    readCharacter(character);
    totalCharacters++;
  }

  void readCharacterTemplate() {
    final character = getCharacterInstance();
    character.type = CharacterType.Template;
    readCharacter(character);
    readCharacterEquipment(character);
    totalCharacters++;
  }

  void readCharacterPlayer(){
    final character = getCharacterInstance();
    final teamDirectionState = readByte();
    character.type = CharacterType.Template;
    readTeamDirectionState(character, teamDirectionState);
    character.x = readDouble();
    character.y = readDouble();
    character.z = readDouble();
    _parseCharacterFrameHealth(character, readByte());
    readCharacterEquipment(character);
    character.name = readString();
    character.text = readString();
    character.aimAngle = readAngle();
    character.usingWeapon = readBool();
    if (character.usingWeapon){
      character.weaponFrame = readInt();
    } else {
      character.weaponFrame = 0;
    }
    totalCharacters++;
  }

  void readInteractingNpcName() {
    player.interactingNpcName.value = readString();
  }

  void readPlayerQuests() {
    player.questsInProgress.value = readQuests();
    player.questsCompleted.value = readQuests();
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

  void readPlayerDesigned() {
    player.designed.value = readBool();
  }

  void readSceneMetaData() {
    sceneMetaDataMapEditable.value = readBool();
    sceneMetaDataSceneName.value = readString();
  }

  void readCustomGameNames() {
    final length = readInt();
    final list = <String>[];
    for (var i = 0; i < length; i++) {
      list.add(readString());
    }
    customGameNames.value = list;
  }

  void readWeather() {
    rain.value = readRain();
    weatherBreeze.value = readBool();
    lightning.value = readLightning();
    watchTimePassing.value = readBool();
    windAmbient.value = readWind();
    ambientShade.value = readByte();
  }

  Rain readRain(){
     return rainValues[readByte()];
  }

  Wind readWind(){
    return windValues[readByte()];
  }

  Lightning readLightning(){
    return lightningValues[readByte()];
  }

  void readEnd() {
    byteLength.value = index;
    index = 0;
    engine.redrawCanvas();
  }

  void readStoreItems() {
    storeItems.value = readWeapons();
  }

  void readNode() {
    final nodeIndex = readPositiveInt();
    final nodeType = readByte();
    final nodeOrientation = readByte();
    assert(NodeType.supportsOrientation(nodeType, nodeOrientation));
    gridNodeTypes[nodeIndex] = nodeType;
    gridNodeOrientations[nodeIndex] = nodeOrientation;
    edit.refreshNodeSelectedIndex();
    onGridChanged();
  }

  void readPlayerWeapons() {
    player.weapons.value = readWeapons();
  }

  void readPlayerTarget() {
    readVector3(player.abilityTarget);
  }

  void readPlayerSpawned() {
    player.x = readDouble();
    player.y = readDouble();
    cameraCenterOnPlayer();
    engine.zoom = 1.0;
    engine.targetZoom = 1.0;
  }

  void readGameTime() {
    hours.value = readByte();
    minutes.value = readByte();
  }

  void readDamageApplied() {
    final x = readDouble();
    final y = readDouble() - 5;
    final amount = readInt();
    spawnFloatingText(x, y, amount.toString());
  }

  void readTechTypes() {
    player.levelPickaxe.value = readByte();
    player.levelSword.value = readByte();
    player.levelBow.value = readByte();
    player.levelAxe.value = readByte();
    player.levelHammer.value = readByte();
  }

  void readPlayerAttackTargetNone() {
    player.attackTarget.x = 0;
    player.attackTarget.y = 0;
    player.mouseTargetName.value = null;
    engine.cursorType.value = CursorType.Basic;
  }

  void readPlayerAttackTarget() {
    readVector3(player.attackTarget);
    engine.cursorType.value = CursorType.Click;
  }

  void readDebugMode() {
    game.debug.value = readBool();
  }

  void readGameStatus() {
    core.state.status.value = gameStatuses[readByte()];
  }

  void readGrid() {
    gridTotalZ = readInt();
    gridTotalRows = readInt();
    gridTotalColumns = readInt();
    gridTotalArea = gridTotalRows * gridTotalColumns;
    final grandTotal = gridTotalZ * gridTotalRows * gridTotalColumns;
    if (gridNodeTypes.length < grandTotal) {
      print('new buffers generated $grandTotal');
      gridNodeTypes = Uint8List(grandTotal);
      gridNodeOrientations = Uint8List(grandTotal);
      gridNodeShade = Uint8List(grandTotal);
      gridNodeBake = Uint8List(grandTotal);
      gridNodeWind = Uint8List(grandTotal);
      gridNodeVariation = List.generate(grandTotal, (index) => false, growable: false);
      gridNodeVisible = List.generate(grandTotal, (index) => true, growable: false);
    }
    gridNodeTotal = grandTotal;

    var gridIndex = 0;
    var total = 0;
    var currentRow = 0;
    var currentColumn = 0;

    while (total < grandTotal) {
      final nodeType = readByte();
      final nodeOrientation = readByte();

      if(!NodeType.supportsOrientation(nodeType, nodeOrientation)) {
         print("node type ${NodeType.getName(nodeType)} does not support orientation ${NodeOrientation.getName(nodeOrientation)}");
      }

      var count = readPositiveInt();
      total += count;

      while (count > 0) {
        gridNodeTypes[gridIndex] = nodeType;
        gridNodeOrientations[gridIndex] = nodeOrientation;

        if (nodeType == NodeType.Grass) {
          gridNodeVariation[gridIndex] = randomBool();
        }

        gridIndex++;
        count--;
        currentColumn++;
        if (currentColumn >= gridTotalColumns) {
          currentColumn = 0;
          currentRow++;
          if (currentRow >= gridTotalRows) {
            currentRow = 0;
          }
        }
      }
    }
    assert(total == grandTotal);
    onGridChanged();
    onChangedScene();
  }

  void readPaths() {
    game.debug.value = true;
    var index = 0;
    while (true) {
      final pathIndex = readInt();
      paths[index] = pathIndex.toDouble();
      index++;
      if (pathIndex == 250) break;
      for (var i = 0; i < pathIndex; i++) {
        paths[index] = readDouble();
        paths[index + 1] = readDouble();
        index += 2;
      }
    }
    var i = 0;

    while(readByte() != 0) {
       targets[i] = readDouble();
       targets[i + 1] = readDouble();
       targets[i + 2] = readDouble();
       targets[i + 3] = readDouble();
       i += 4;
    }
  }

  List<Weapon> readWeapons() {
    final weapons = <Weapon>[];
    final total = readInt();
    for (var i = 0; i < total; i++){
      weapons.add(readWeapon());
    }
    return weapons;
  }

  Weapon readWeapon(){
    final type = readByte();
    final damage = readInt();
    final uuid = readString();
    return Weapon(
      type: type,
      damage: damage,
      uuid: uuid,
    );
  }

  void readGameEvent(){
      final type = readByte();
      final x = readDouble();
      final y = readDouble();
      final z = readDouble();
      final angle = readDouble() * degreesToRadians;
      onGameEvent(type, x, y, z, angle);
  }

  void readProjectiles(){
    totalProjectiles = readInt();
    while (totalProjectiles >= projectiles.length){
       projectiles.add(Projectile());
    }
    for (var i = 0; i < totalProjectiles; i++) {
      final projectile = projectiles[i];
      projectile.x = readDouble();
      projectile.y = readDouble();
      projectile.z = readDouble();
      projectile.type = readByte();
      projectile.angle = readDouble() * degreesToRadians;
    }
  }

  void _parseCharacterTeamDirectionState(Character character){
    readTeamDirectionState(character, readByte());
  }

  void readTeamDirectionState(Character character, int byte){
    character.allie = byte >= 100;
    character.direction = ((byte % 100) ~/ 10);
    character.state = byte % 10;
  }

  void readNpcs() {
    totalNpcs = 0;
    var npcLength = npcs.length;
    while (true) {
      final stateInt = readByte();
      if (stateInt == END) break;
      if (totalNpcs >= npcLength){
        npcs.add(Character());
        npcLength++;
      }
      final npc = npcs[totalNpcs];
      readTeamDirectionState(npc, stateInt);
      npc.x = readDouble();
      npc.y = readDouble();
      npc.z = readDouble();
      _parseCharacterFrameHealth(npc, readByte());
      readCharacterEquipment(npc);
      totalNpcs++;
    }
  }

  void readNpc(Character character){
    readCharacter(character);
    readCharacterEquipment(character);
  }

  void readCharacter(Character character){
     _parseCharacterTeamDirectionState(character);
     character.x = readDouble();
     character.y = readDouble();
     character.z = readDouble();
     _parseCharacterFrameHealth(character, readByte());
  }

  void readCharacterEquipment(Character character){
    character.weapon = readByte();
    character.weaponState = readByte();
    character.body = readByte();
    character.head = readByte();
    character.legs = readByte();
  }

  void _parseCharacterFrameHealth(Character character, int byte){
    final frame = byte % 10;
    final health = (byte - frame) / 240.0;
    character.frame = frame;
    character.health = health;
  }

  int readSlotType(){
    return readByte();
  }

  void readPlayerEvent() {
    onPlayerEvent(readByte());
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
     return value / 256.0;
  }

  List<Quest> readQuests(){
    final total = readInt();
    final values = <Quest>[];
    for (var i = 0; i < total; i++){
      values.add(quests[readByte()]);
    }
    return values;
  }

  double readAngle() => readDouble() * degreesToRadians;
}