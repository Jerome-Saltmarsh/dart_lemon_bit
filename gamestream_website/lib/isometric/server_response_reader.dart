import 'dart:typed_data';

import 'package:bleed_common/character_type.dart';
import 'package:bleed_common/library.dart';
import 'package:bleed_common/quest.dart';
import 'package:gamestream_flutter/isometric/characters.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/classes/deck_card.dart';
import 'package:gamestream_flutter/isometric/classes/game_object.dart';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:gamestream_flutter/isometric/classes/weapon.dart';
import 'package:gamestream_flutter/isometric/collectables.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/events/on_changed_scene.dart';
import 'package:gamestream_flutter/isometric/events/on_game_event.dart';
import 'package:gamestream_flutter/isometric/events/on_player_event.dart';
import 'package:gamestream_flutter/isometric/factories/generate_grid_node.dart';
import 'package:gamestream_flutter/isometric/floating_texts.dart';
import 'package:gamestream_flutter/isometric/gameobjects.dart';
import 'package:gamestream_flutter/isometric/grid/state/wind.dart';
import 'package:gamestream_flutter/isometric/io/custom_game_names.dart';
import 'package:gamestream_flutter/isometric/npcs.dart';
import 'package:gamestream_flutter/isometric/projectiles.dart';
import 'package:gamestream_flutter/isometric/watches/ambient_shade.dart';
import 'package:gamestream_flutter/isometric/watches/lightning.dart';
import 'package:gamestream_flutter/isometric/watches/rain.dart';
import 'package:gamestream_flutter/isometric/watches/scene_meta_data.dart';
import 'package:gamestream_flutter/isometric/weather/time_passing.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:lemon_byte/byte_reader.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/enums.dart';
import 'package:lemon_math/library.dart';
import 'package:lemon_watch/watch.dart';

import 'ai.dart';
import 'camera.dart';
import 'classes/node.dart';
import 'classes/npc_debug.dart';
import 'classes/projectile.dart';
import 'grid.dart';
import 'items.dart';
import 'player.dart';
import 'player_store.dart';
import 'time.dart';
import 'weather/breeze.dart';

final serverResponseReader = ServerResponseReader();
final byteLength = Watch(0);
final bufferSize = Watch(0);
final totalEvents = Watch(0);
final framesSinceUpdateReceived = Watch(0);
final msSinceLastUpdate = Watch(0);
final averageUpdate = Watch(0.0);
final sync = Watch(0.0);
var durationTotal = 0;

var time = DateTime.now();

class ServerResponseReader with ByteReader {
  final gameObjects = <GameObject>[];
  final bulletHoles = <Vector2>[];
  final npcDebug = <NpcDebug>[];
  var bulletHoleIndex = 0;
  var itemsTotal = 0;

  void readBytes(Uint8List values) {
    framesSinceUpdateReceived.value = 0;
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
        case ServerResponse.GameObject_Static:
          final gameObject = getInstanceGameObject();
          readVector3(gameObject);
          gameObject.type = readByte();
          totalGameObjects++;
          break;
        case ServerResponse.GameObject_Butterfly:
          readGameObjectButterfly();
          break;
        case ServerResponse.GameObject_Chicken:
          readGameObjectChicken();
          break;
        case ServerResponse.End:
          return readEnd();
        case ServerResponse.Items:
          readerItems();
          break;
        case ServerResponse.Projectiles:
          readProjectiles();
          break;
        case ServerResponse.Game_Events:
          readGameEvents();
          break;
        case ServerResponse.Player_Events:
          readPlayerEvents();
          break;
        case ServerResponse.Player_Deck_Cooldown:
          readPlayerDeckCooldown();
          break;
        case ServerResponse.Player_Deck:
          readPlayerDeck();
          break;
        case ServerResponse.Grid:
          readGrid();
          break;
        case ServerResponse.Player_Deck_Active_Ability:
          readPlayerDeckActiveAbility();
          break;
        case ServerResponse.Player_Deck_Active_Ability_None:
          readPlayerDeckActiveAbilityNone();
          break;
        case ServerResponse.Card_Choices:
          readCardChoices();
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
          player.mouseTargetName.value = readString();
          player.mouseTargetHealth.value = readPercentage();
          break;
        case ServerResponse.Player_Attack_Target_None:
          readPlayerAttackTargetNone();
          break;
        case ServerResponse.Collectables:
          readCollectables();
          break;
        case ServerResponse.Damage_Applied:
          readDamageApplied();
          break;
        case ServerResponse.Lives_Remaining:
          readLivesRemaining();
          break;
        case ServerResponse.Paths:
          readPaths();
          break;
        case ServerResponse.Game_Time:
          readGameTime();
          break;
        case ServerResponse.Player:
          readPlayer();
          break;
        case ServerResponse.Player_Slots:
          break;
        case ServerResponse.Player_Spawned:
          readPlayerSpawned();
          break;
        // case ServerResponse.Player_Target:
        //   readPlayerTarget();
        //   break;
        case ServerResponse.Player_Weapons:
          readPlayerWeapons();
          break;
        case ServerResponse.Player_Equipped_Weapon:
          readPlayerEquippedWeapon();
          break;
        case ServerResponse.Block_Set:
          readBlockSet();
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
          player.mapTile.value = readByte();
          break;
        case ServerResponse.Interacting_Npc_Name:
          readInteractingNpcName();
          break;
        case ServerResponse.Editor_GameObject_Selected:
          readVector3(edit.gameObject);
          final type = readByte();
          edit.gameObject.type = type;
          edit.gameObjectSelectedType.value = type;
          if (type == GameObjectType.Spawn) {
            edit.gameObjectSelectedSpawnType.value = readByte();
          }
          edit.gameObjectSelected.value = true;
          edit.cameraCenterSelectedObject();
          break;
        default:
          throw Exception("Cannot parse $response at index: $index");
      }
    }
  }

  void readGameObjectButterfly() {
    final gameObject = getInstanceGameObject();
    gameObject.type = GameObjectType.Butterfly;
    readVector3(gameObject);
    gameObject.direction = readByte();
    totalGameObjects++;
  }

  void readGameObjectChicken(){
    final gameObject = getInstanceGameObject();
    gameObject.type = GameObjectType.Chicken;
    readVector3(gameObject);
    gameObject.state = readByte();
    gameObject.direction = readByte();
    totalGameObjects++;
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
    character.magic = _nextPercentage();
    character.weapon = readByte();
    character.armour = readByte();
    character.helm = readByte();
    character.pants = readByte();
    character.name = readString();
    character.text = readString();
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

  void readBlockSet() {
    final z = readInt();
    final row = readInt();
    final column = readInt();
    final type = readInt();
    grid[z][row][column] = generateNode(z, row, column, type);
    edit.refreshSelected();
    onGridChanged();
  }

  void readPlayerEquippedWeapon() {
    player.weapon.value = readWeapon();
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

  void readLivesRemaining() {
    modules.game.state.lives.value = readByte();
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

  void readCollectables() {
    var totalCollectables = 0;
    var type = readByte();
    while (type != END) {
      final collectable = collectables[totalCollectables];
      collectable.type = type;
      readVector2(collectable);
      totalCollectables++;
      type = readByte();
    }
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
    modules.game.state.debug.value = readBool();
  }

  void readGameStatus() {
    core.state.status.value = gameStatuses[readByte()];
  }

  void readCardChoices() {
    player.cardChoices.value = readCardTypes();
  }

  void readPlayerDeckActiveAbilityNone() {
    player.deckActiveCardIndex.value = -1;
    engine.cursorType.value = CursorType.Basic;
  }

  void readPlayerDeckActiveAbility() {
    player.deckActiveCardIndex.value = readByte();
    player.deckActiveCardRange.value = readDouble();
    player.deckActiveCardRadius.value = readDouble();
    engine.cursorType.value = CursorType.Click;
  }

  void readPlayerDeck() {
    player.deck.value = readDeck();
  }

  void readPlayerDeckCooldown() {
    final length = readByte();
    assert (length == player.deck.value.length);
    for (var i = 0; i < length; i++){
        final card = player.deck.value[i];
        card.cooldownRemaining.value = readByte();
        card.cooldown.value = readByte();
    }
  }

  void readGrid() {
    gridTotalZ = readInt();
    gridTotalRows = readInt();
    gridTotalColumns = readInt();

    grid = List.generate(gridTotalZ, (indexZ) =>
        List.generate(gridTotalRows, (indexRow) =>
            List.generate(gridTotalColumns, (indexColumn) => Node.empty)
        )
    );

    final grandTotal = gridTotalZ * gridTotalRows * gridTotalColumns;
    var total = 0;

    var currentZ = 0;
    var currentRow = 0;
    var currentColumn = 0;

    while (total < grandTotal) {
      var type = readByte();
      var count = readPositiveInt();
      total += count;

      while (count > 0) {
        count--;
        grid[currentZ][currentRow][currentColumn] = generateNode(currentZ, currentRow, currentColumn, type);
        currentColumn++;
        if (currentColumn >= gridTotalColumns) {
          currentColumn = 0;
          currentRow++;
          if (currentRow >= gridTotalRows) {
            currentRow = 0;
            currentZ++;
          }
        }
      }
    }
    assert(total == grandTotal);
    onGridChanged();
    onChangedScene();
  }

  void readPaths() {
    modules.game.state.debug.value = true;
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

  void readPlayerDebug(){
    player.state.value = readByte();
    player.angle = readDouble() / 100.0;
    player.mouseAngle = readDouble() / 100.0;
  }

  void readPlayer() {
    player.x = readDouble();
    player.y = readDouble();
    player.z = readDouble();
    player.health.value = readDouble();
    player.maxHealth = readDouble();
    player.weaponType.value = readByte();
    player.weaponDamage.value = readByte();
    player.armourType.value = readByte();
    player.headType.value = readByte();
    player.pantsType.value = readByte();
    player.alive.value = readBool();
    player.experience.value = readPercentage();
    player.level.value = readByte();
    updateCameraMode();
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

  void updateSync() {
    final now = DateTime.now();
    final duration = now.difference(time);
    time = now;
    msSinceLastUpdate.value = duration.inMilliseconds;
    totalEvents.value++;
    durationTotal += duration.inMilliseconds;
    if (durationTotal == 0){
      durationTotal = 35;
    }
    averageUpdate.value = durationTotal / totalEvents.value;
    sync.value = duration.inMilliseconds / averageUpdate.value;
  }

  void readGameEvents(){
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
    character.direction = (byte % 100) ~/ 10;
    character.state = byte % 10;
  }

  void readerItems(){
    itemsTotal = 0;
    while (true) {
      final itemTypeIndex = readByte();
      if (itemTypeIndex == END) break;
      final item = items[index];
      item.type = itemTypeIndex;
      item.x = readDouble();
      item.y = readDouble();
      itemsTotal++;
    }
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
    character.armour = readByte();
    character.helm = readByte();
    character.pants = readByte();
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

  double _nextPercentage(){
    return readByte() / 100.0;
  }

  void readPlayerEvents() {
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

  List<CardType> readCardTypes(){
    final numberOfCards = readByte();
    final cards = <CardType>[];
    for (var i = 0; i < numberOfCards; i++) {
      cards.add(cardTypes[readByte()]);
    }
    return cards;
  }

  List<DeckCard> readDeck(){
    final numberOfCards = readByte();
    final cards = <DeckCard>[];
    for (var i = 0; i < numberOfCards; i++) {
      final type = readByte();
      final level = readByte();
      cards.add(DeckCard(cardTypes[type], level));
    }
    return cards;
  }

  List<Quest> readQuests(){
    final total = readInt();
    final values = <Quest>[];
    for (var i = 0; i < total; i++){
      values.add(quests[readByte()]);
    }
    return values;
  }
}