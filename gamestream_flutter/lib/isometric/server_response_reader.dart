import 'dart:typed_data';

import 'package:gamestream_flutter/isometric/events/on_changed_scene.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:lemon_byte/byte_reader.dart';
import 'package:lemon_math/library.dart';

import 'ai.dart';
import 'player_store.dart';

final serverResponseReader = ServerResponseReader();



class ServerResponseReader with ByteReader {
  final byteLength = Watch(0);
  final bufferSize = Watch(0);
  final updateFrame = Watch(0, onChanged: GameState.onChangedUpdateFrame);

  void readBytes(Uint8List values) {
    updateFrame.value++;
    index = 0;
    GameState.totalCharacters = 0;
    GameState.totalGameObjects = 0;
    bufferSize.value = values.length;
    this.values = values;

    while (true) {
      switch (readByte()) {
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
        case ServerResponse.GameObject:
          readGameObject();
          break;
        case ServerResponse.Game_Waves:
          // readServerResponseGameWaves();
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
          GameState.spawnParticle(
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
          GameState.gameType.value = readByte();
          break;
        case ServerResponse.Player_Slots:
          GameState.player.weaponSlot1.type.value = readByte();
          GameState.player.weaponSlot1.capacity.value = readInt();
          GameState.player.weaponSlot1.rounds.value = readInt();

          GameState.player.weaponSlot2.type.value = readByte();
          GameState.player.weaponSlot2.capacity.value = readInt();
          GameState.player.weaponSlot2.rounds.value = readInt();

          GameState.player.weaponSlot3.type.value = readByte();
          GameState.player.weaponSlot3.capacity.value = readInt();
          GameState.player.weaponSlot3.rounds.value = readInt();
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
          readVector3(GameState.player.target);
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
          // EditState.selectedNodeData.value = SpawnNodeData(
          //    spawnType: spawnType,
          //    spawnAmount: spawnAmount,
          //    spawnRadius: spawnRadius,
          // );
          break;
        case ServerResponse.Render_Map:
          GameUI.mapVisible.value = readBool();
          break;
        case ServerResponse.Options:
          final optionType = readByte();
          switch(optionType){
            case GameOption.Set_Control_Scheme:
              final controlsScheme = readByte();
              print(controlsScheme);
              break;
          }
          break;
        default:
          if (debugging) {
            return;
          }
          print(values);
          debugging = true;
          readBytes(values);
          return;
      }
    }
  }

  var debugging = false;

  void readServerResponseEnvironment() {
    final environmentResponse = readByte();
    switch (environmentResponse) {
      case EnvironmentResponse.Shade:
        GameState.ambientShade.value = readByte();
        break;
      case EnvironmentResponse.Rain:
        GameState.rain.value = readRain();
        break;
      case EnvironmentResponse.Lightning:
        GameState.lightning.value = readLightning();
        break;
      case EnvironmentResponse.Wind:
        GameState.windAmbient.value = readWind();
        break;
      case EnvironmentResponse.Breeze:
        GameState.weatherBreeze.value = readBool();
        break;
    }
  }

  void readGameObject() {
    final instance = GameState.getInstanceGameObject();
    instance.type = readByte();
    readVector3(instance);
  }

  void readServerResponseGameWaves() {
    // final gameWavesResponse = readByte();
    // switch (gameWavesResponse) {
    //   case GameWavesResponse.timer:
    //     gameWaves.timer.value = readPercentage();
    //     break;
    //   case GameWavesResponse.round:
    //     gameWaves.round.value = readInt();
    //     break;
    //   case GameWavesResponse.clear_upgrades:
    //     gameWaves.purchasePrimary.clear();
    //     gameWaves.purchaseSecondary.clear();
    //     gameWaves.purchaseTertiary.clear();
    //     gameWaves.refresh.value++;
    //     break;
    //   case GameWavesResponse.purchase:
    //     final position = readByte();
    //     final type = readByte();
    //     final cost = readInt();
    //     final purchase = Purchase(type, cost);
    //
    //     switch (position){
    //       case TypePosition.Primary:
    //         gameWaves.purchasePrimary.add(purchase);
    //         break;
    //       case TypePosition.Secondary:
    //         gameWaves.purchaseSecondary.add(purchase);
    //         break;
    //       case TypePosition.Tertiary:
    //         gameWaves.purchaseTertiary.add(purchase);
    //         break;
    //     }
    //     gameWaves.refresh.value++;
    //     break;
    // }
  }

  void readServerResponsePlayer() {
    final apiPlayer = readByte();
    switch (apiPlayer) {
      case ApiPlayer.Position:
        GameState.player.previousPosition.x = GameState.player.x;
        GameState.player.previousPosition.y = GameState.player.y;
        GameState.player.previousPosition.z = GameState.player.z;
        readVector3(GameState.player);
        break;
      case ApiPlayer.Health:
        GameState.player.health.value = readInt();
        break;
      case ApiPlayer.Max_Health:
        GameState.player.maxHealth = readInt();
        break;
      case ApiPlayer.Armour_Type:
       GameState.player.armourType.value = readByte();
        break;
      case ApiPlayer.Head_Type:
       GameState.player.headType.value = readByte();
        break;
      case ApiPlayer.Pants_Type:
       GameState.player.pantsType.value = readByte();
        break;
      case ApiPlayer.Alive:
       GameState.player.alive.value = readBool();
        break;
      case ApiPlayer.Experience_Percentage:
       GameState.player.experience.value = readPercentage();
        break;
      case ApiPlayer.Level:
       GameState.player.level.value = readInt();
        break;
      case ApiPlayer.Aim_Angle:
       GameState.player.mouseAngle = readAngle();
        break;
      case ApiPlayer.Points:
       GameState.player.points.value = readInt();
        break;
      case ApiPlayer.Weapon_Type:
       GameState.player.weapon.type.value = readByte();
        break;
      case ApiPlayer.Weapon_Rounds:
       GameState.player.weapon.rounds.value = readInt();
        break;
      case ApiPlayer.Weapon_Capacity:
       GameState.player.weapon.capacity.value = readInt();
        break;
      case ApiPlayer.Message:
       GameState.player.message.value = readString();
        break;
      default:
        throw Exception("Cannot parse apiPlayer $apiPlayer");
    }
  }

  void readGameObjectStatic() {
    final gameObject = GameState.getInstanceGameObject();
    readVector3(gameObject);
    gameObject.type = readByte();
  }

  void readPlayerAttackTargetName() {
   GameState.player.mouseTargetName.value = readString();
   GameState.player.mouseTargetAllie.value = readBool();
   GameState.player.mouseTargetHealth.value = readPercentage();
  }

  void readMapCoordinate() {
   GameState.player.mapTile.value = readByte();
  }

  void readEditorGameObjectSelected() {
    readVector3(GameEditor.gameObject);
    final type = readByte();
    GameEditor.gameObject.type = type;
    GameEditor.gameObjectSelectedType.value = type;
    if (type == GameObjectType.Particle_Emitter){
      GameEditor.gameObjectSelectedParticleType.value = readByte();
      GameEditor.gameObjectSelectedParticleSpawnRate.value = readInt();
    }

    GameEditor.gameObjectSelected.value = true;
    GameEditor.cameraCenterSelectedObject();
  }

  void readGameObjectButterfly() {
    final gameObject = GameState.getInstanceGameObject();
    gameObject.type = GameObjectType.Butterfly;
    readVector3(gameObject);
    gameObject.direction = readByte();
  }

  void readGameObjectChicken(){
    final gameObject = GameState.getInstanceGameObject();
    gameObject.type = GameObjectType.Chicken;
    readVector3(gameObject);
    gameObject.state = readByte();
    gameObject.direction = readByte();
  }

  void readGameObjectJellyfish(){
    final gameObject = GameState.getInstanceGameObject();
    gameObject.type = GameObjectType.Jellyfish;
    readVector3(gameObject);
    gameObject.state = readByte();
    gameObject.direction = readByte();
  }

  void readGameObjectJellyfishRed(){
    final gameObject = GameState.getInstanceGameObject();
    gameObject.type = GameObjectType.Jellyfish_Red;
    readVector3(gameObject);
    gameObject.state = readByte();
    gameObject.direction = readByte();
  }

  void readCharacterRat() {
    final character = GameState.getCharacterInstance();
    character.characterType = CharacterType.Rat;
    readCharacter(character);
    GameState.totalCharacters++;
  }

  void readCharacterZombie() {
    final character = GameState.getCharacterInstance();
    character.characterType = CharacterType.Zombie;
    readCharacter(character);
    GameState.totalCharacters++;
  }

  void readCharacterSlime() {
    final character = GameState.getCharacterInstance();
    character.characterType = CharacterType.Slime;
    readCharacter(character);
    GameState.totalCharacters++;
  }

  void readCharacterTemplate() {
    final character = GameState.getCharacterInstance();
    character.characterType = CharacterType.Template;
    readCharacter(character);
    readCharacterEquipment(character);
    GameState.totalCharacters++;
  }

  void readCharacterPlayer(){
    final character = GameState.getCharacterInstance();
    final teamDirectionState = readByte();
    character.characterType = CharacterType.Template;
    readTeamDirectionState(character, teamDirectionState);
    character.x = readDouble();
    character.y = readDouble();
    character.z = readDouble();
    _parseCharacterFrameHealth(character, readByte());
    readCharacterEquipment(character);
    character.name = readString();
    character.text = readString();
    character.lookRadian = readAngle();
    character.weaponFrame = readByte();
    GameState.totalCharacters++;
  }

  void readInteractingNpcName() {
   GameState.player.interactingNpcName.value = readString();
  }

  void readPlayerQuests() {
   GameState.player.questsInProgress.value = readQuests();
   GameState.player.questsCompleted.value = readQuests();
  }

  void readNpcTalk() {
   GameState.player.npcTalk.value = readString();
    final totalOptions = readByte();
    final options = <String>[];
    for (var i = 0; i < totalOptions; i++) {
       options.add(readString());
    }
   GameState.player.npcTalkOptions.value = options;
  }

  void readSceneMetaData() {
    GameState.sceneEditable.value = readBool();
    GameState.sceneMetaDataSceneName.value = readString();
  }

  void readWeather() {
    GameState.rain.value = readRain();
    GameState.weatherBreeze.value = readBool();
    GameState.lightning.value = readLightning();
    GameState.watchTimePassing.value = readBool();
    GameState.windAmbient.value = readWind();
    GameState.ambientShade.value = readByte();
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
    Engine.redrawCanvas();
  }

  void readStoreItems() {
    storeItems.value = readWeapons();
  }

  void readNode() {
    final nodeIndex = readPositiveInt();
    final nodeType = readByte();
    final nodeOrientation = readByte();
    assert(NodeType.supportsOrientation(nodeType, nodeOrientation));
    GameState.nodesType[nodeIndex] = nodeType;
    GameState.nodesOrientation[nodeIndex] = nodeOrientation;
    GameEvents.onChangedNodes();
  }

  void readPlayerWeapons() {
   GameState.player.weapons.value = readWeapons();
  }

  void readPlayerTarget() {
    readVector3(GameState.player.abilityTarget);
  }

  void readPlayerSpawned() {
   GameState.player.x = readDouble();
   GameState.player.y = readDouble();
   GameActions.cameraCenterOnPlayer();
    Engine.zoom = 1.0;
    Engine.targetZoom = 1.0;
  }

  void readGameTime() {
    GameState.hours.value = readByte();
    GameState.minutes.value = readByte();
  }

  void readDamageApplied() {
    final x = readDouble();
    final y = readDouble() - 5;
    final amount = readInt();
    GameState.spawnFloatingText(x, y, amount.toString());
  }

  void readTechTypes() {
   GameState.player.levelPickaxe.value = readByte();
   GameState.player.levelSword.value = readByte();
   GameState.player.levelBow.value = readByte();
   GameState.player.levelAxe.value = readByte();
   GameState.player.levelHammer.value = readByte();
  }

  void readPlayerAttackTargetNone() {
   GameState.player.attackTarget.x = 0;
   GameState.player.attackTarget.y = 0;
   GameState.player.mouseTargetName.value = null;
    Engine.cursorType.value = CursorType.Basic;
  }

  void readPlayerAttackTarget() {
    readVector3(GameState.player.attackTarget);
    Engine.cursorType.value = CursorType.Click;
  }

  void readDebugMode() {
    GameUI.debug.value = readBool();
  }

  void readGrid() {
    GameState.nodesTotalZ = readInt();
    GameState.nodesTotalRows = readInt();
    GameState.nodesTotalColumns = readInt();
    GameState.nodesArea = GameState.nodesTotalRows * GameState.nodesTotalColumns;
    final totalNodes = GameState.nodesTotalZ * GameState.nodesTotalRows * GameState.nodesTotalColumns;
    if (GameState.nodesType.length < totalNodes) {
      GameState.nodesType = Uint8List(totalNodes);
      GameState.nodesOrientation = Uint8List(totalNodes);
      GameState.nodesShade = Uint8List(totalNodes);
      GameState.nodesBake = Uint8List(totalNodes);
      GameState.nodesWind = Uint8List(totalNodes);
      GameState.nodesVariation = List.generate(totalNodes, (index) => false, growable: false);
      GameState.nodesVisible = List.generate(totalNodes, (index) => true, growable: false);
      GameState.nodesVisibleIndex = Uint16List(totalNodes);
      GameState.nodesDynamicIndex = Uint16List(totalNodes);
    }
    GameState.nodesTotal = totalNodes;

    var gridIndex = 0;
    var total = 0;
    var currentRow = 0;
    var currentColumn = 0;

    while (total < totalNodes) {
      final nodeType = readByte();
      final nodeOrientation = readByte();

      if(!NodeType.supportsOrientation(nodeType, nodeOrientation)) {
         print("node type ${NodeType.getName(nodeType)} does not support orientation ${NodeOrientation.getName(nodeOrientation)}");
      }

      var count = readPositiveInt();
      total += count;

      while (count > 0) {
        GameState.nodesType[gridIndex] = nodeType;
        GameState.nodesOrientation[gridIndex] = nodeOrientation;

        if (nodeType == NodeType.Grass) {
          GameState.nodesVariation[gridIndex] = randomBool();
        }

        gridIndex++;
        count--;
        currentColumn++;
        if (currentColumn >= GameState.nodesTotalColumns) {
          currentColumn = 0;
          currentRow++;
          if (currentRow >= GameState.nodesTotalRows) {
            currentRow = 0;
          }
        }
      }
    }
    assert(total == totalNodes);
    GameEvents.onChangedNodes();
    onChangedScene();
  }

  void readPaths() {
    GameUI.debug.value = true;
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
      GameEvents.onGameEvent(type, x, y, z, angle);
  }

  void readProjectiles(){
    GameState.totalProjectiles = readInt();
    while (GameState.totalProjectiles >= GameState.projectiles.length){
      GameState.projectiles.add(Projectile());
    }
    for (var i = 0; i < GameState.totalProjectiles; i++) {
      final projectile = GameState.projectiles[i];
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
    GameState.totalNpcs = 0;
    var npcLength = GameState.npcs.length;
    while (true) {
      final stateInt = readByte();
      if (stateInt == END) break;
      if (GameState.totalNpcs >= npcLength){
        GameState.npcs.add(Character());
        npcLength++;
      }
      final npc = GameState.npcs[GameState.totalNpcs];
      readTeamDirectionState(npc, stateInt);
      npc.x = readDouble();
      npc.y = readDouble();
      npc.z = readDouble();
      _parseCharacterFrameHealth(npc, readByte());
      readCharacterEquipment(npc);
      GameState.totalNpcs++;
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
    character.weaponType = readByte();
    character.weaponState = readByte();
    character.bodyType = readByte();
    character.headType = readByte();
    character.legType = readByte();
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