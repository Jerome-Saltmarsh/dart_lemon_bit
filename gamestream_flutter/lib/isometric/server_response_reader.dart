import 'package:bleed_common/Rain.dart';
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/classes/deck_card.dart';
import 'package:gamestream_flutter/isometric/classes/game_object.dart';
import 'package:gamestream_flutter/isometric/classes/weapon.dart';
import 'package:gamestream_flutter/isometric/collectables.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/events/on_game_event.dart';
import 'package:gamestream_flutter/isometric/events/on_player_event.dart';
import 'package:gamestream_flutter/isometric/floating_texts.dart';
import 'package:gamestream_flutter/isometric/grid/state/wind.dart';
import 'package:gamestream_flutter/isometric/io/custom_game_names.dart';
import 'package:gamestream_flutter/isometric/npcs.dart';
import 'package:gamestream_flutter/isometric/players.dart';
import 'package:gamestream_flutter/isometric/projectiles.dart';
import 'package:gamestream_flutter/isometric/watches/rain.dart';
import 'package:gamestream_flutter/isometric/watches/scene_meta_data.dart';
import 'package:gamestream_flutter/isometric/weather/lightning.dart';
import 'package:gamestream_flutter/isometric/weather/time_passing.dart';
import 'package:gamestream_flutter/isometric/zombies.dart';
import 'package:gamestream_flutter/modules/game/state.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:lemon_byte/byte_reader.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/enums.dart';
import 'package:lemon_math/library.dart';
import 'package:lemon_watch/watch.dart';

import 'ai.dart';
import 'camera.dart';
import 'classes/npc_debug.dart';
import 'classes/projectile.dart';
import 'grid.dart';
import 'items.dart';
import 'particle_emitters.dart';
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
  final scoreBuilder = StringBuffer();
  final scoreText = Watch("");
  var bulletHoleIndex = 0;
  var itemsTotal = 0;

  void readBytes(List<int> values) {
    framesSinceUpdateReceived.value = 0;
    index = 0;
    bufferSize.value = values.length;
    this.values = values;
    while (true) {
      final response = readByte();
      switch (response){
        case ServerResponse.Zombies:
          readZombies();
          break;
        case ServerResponse.Items:
          readerItems();
          break;
        case ServerResponse.Players:
          readPlayers();
          break;
        case ServerResponse.Npcs:
          readNpcs();
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
        case ServerResponse.Game_Objects:
          readGameObjects();
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
        case ServerResponse.Character_Select_Required:
          readCharacterSelectRequired();
          break;
        case ServerResponse.Game_Status:
          readGameStatus();
          break;
        case ServerResponse.Tiles:
          throw Exception("No longer ServerResponse.Tiles");
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
        case ServerResponse.Tech_Types:
          readTechTypes();
          break;
        case ServerResponse.Damage_Applied:
          readDamageApplied();
          break;
        case ServerResponse.Dynamic_Object_Destroyed:
          readDynamicObjectDestroyed();
          break;
        case ServerResponse.Dynamic_Object_Spawned:
          readDynamicObjectSpawned();
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
        case ServerResponse.Player_Target:
          readPlayerTarget();
          break;
        case ServerResponse.Player_Weapons:
          readPlayerWeapons();
          break;
        case ServerResponse.Player_Equipped_Weapon:
          readPlayerEquippedWeapon();
          break;
        case ServerResponse.Block_Set:
          readBlockSet();
          break;
        case ServerResponse.Store_Items:
          readStoreItems();
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
        case ServerResponse.End:
          return readEnd();
        default:
          throw Exception("Cannot parse $response");
      }
    }
  }

  void readSceneMetaData() {
    sceneMetaDataPlayerIsOwner.value = readBool();
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
    weatherLightning.value = readBool();
    watchTimePassing.value = readBool();
    windAmbient.value = readByte();
  }

  Rain readRain(){
     return rainValues[readByte()];
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
    grid[z][row][column] = type;
    edit.refreshType();
    onGridChanged();
  }

  void readPlayerEquippedWeapon() {
    player.weapon.value = readWeapon();
  }

  void readPlayerWeapons() {
    player.weapons.value = readWeapons();
  }

  void readPlayerTarget() {
    readPosition(player.abilityTarget);
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

  void readDynamicObjectSpawned() {
    final instance = GameObject();
    instance.type = readByte();
    instance.x = readDouble();
    instance.y = readDouble();
    instance.id = readInt();
    gameObjects.add(instance);
    sortVertically(gameObjects);
  }

  void readDynamicObjectDestroyed() {
    final id = readInt();
    gameObjects.removeWhere((dynamicObject) => dynamicObject.id == id);
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
    player.attackTarget.x = readDouble();
    player.attackTarget.y = readDouble();
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
    final totalZ = readInt();
    final totalRows = readInt();
    final totalColumns = readInt();
    grid.clear();
    for (var z = 0; z < totalZ; z++) {
       final plain = <List<int>>[];
       grid.add(plain);
       for (var rowIndex = 0; rowIndex < totalRows; rowIndex++) {
          final row = <int>[];
          plain.add(row);
          for (var columnIndex = 0; columnIndex < totalColumns; columnIndex++) {
              row.add(readByte());
          }
       }
    }
    onGridChanged();
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

  void readPlayer() {
    player.x = readDouble();
    player.y = readDouble();
    player.z = readDouble();
    player.angle = readDouble() / 100.0;
    player.mouseAngle = readDouble() / 100.0;
    player.health.value = readDouble();
    player.maxHealth = readDouble();
    player.magic.value = readDouble();
    player.maxMagic.value = readDouble();
    player.weaponType.value = readByte();
    player.weaponDamage.value = readByte();
    player.armourType.value = readByte();
    player.headType.value = readByte();
    player.pantsType.value = readByte();
    player.alive.value = readBool();
    player.storeVisible.value = readBool();
    player.wood.value = readInt();
    player.stone.value = readInt();
    player.gold.value = readInt();
    player.experience.value = readPercentage();
    player.level.value = readByte();
    player.skillPoints.value = readByte();
    updateCameraMode();
  }

  void readCharacterSelectRequired() {
    player.selectCharacterRequired.value = readBool();
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

  void readZombies() {
    totalZombies = 0;
    var zombiesLength = zombies.length;
    while (true) {
      final stateInt = readByte();
      if (stateInt == END) break;
      if (totalZombies >= zombiesLength){
         zombies.add(Character());
         zombiesLength++;
      }
      final character = zombies[totalZombies];
      readTeamDirectionState(character, stateInt);
      character.x = readDouble();
      character.y = readDouble();
      character.z = readDouble();
      _parseCharacterFrameHealth(character, readByte());
      totalZombies++;
    }
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

  void readPlayers() {
    var total = 0;
    var playerLength = players.length;
    while (true) {
      final teamDirectionState = readByte();
      if (teamDirectionState == END) break;
      if (total >= playerLength){
         players.add(Character());
         playerLength = players.length;
      }
      final character = players[total];
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
      character.score = readInt();
      character.text = readString();
      total++;
    }
    totalPlayers = total;
    updateScoreText();
  }

  void readNpcs() {
    totalNpcs = readInt();
    while (totalNpcs >= npcs.length){
      npcs.add(Character());
    }
    for (var i = 0; i < totalNpcs; i++){
      readNpc(npcs[i]);
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

  void readSlot(Slot slot) {
     slot.type.value = readSlotType();
     slot.amount.value = readInt();
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

  void readGameObjects() {
    gameObjects.clear();
    while (true) {
      final typeIndex = readByte();
      if (typeIndex == END) break;
      final instance = GameObject();
      instance.type = typeIndex;
      readPosition(instance);
      // instance.id = readPositiveInt();
      gameObjects.add(instance);
      instance.refreshRowAndColumn();

      if (typeIndex == GameObjectType.Fireplace) {
        isometricParticleEmittersActionAddSmokeEmitter(instance.x, instance.y);
      }
    }
  }


  void readPosition(Position position){
    position.x = readDouble();
    position.y = readDouble();
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


  Character getNextHighestScore(){
    Character? highestPlayer;
    for(var i = 0; i < totalPlayers; i++){
      final player = players[i];
      if (player.scoreMeasured) continue;
      if (highestPlayer == null){
        highestPlayer = player;
        continue;
      }
      if (player.score < highestPlayer.score) continue;
      highestPlayer = player;
    }
    if (highestPlayer == null){
      throw Exception("Could not find highest player");
    }
    highestPlayer.scoreMeasured = true;
    return highestPlayer;
  }

  void updateScoreText(){
    scoreBuilder.clear();
    if (totalPlayers <= 0) return;
    scoreBuilder.write("SCORE\n");

    for (var i = 0; i < totalPlayers; i++) {
      final player = players[i];
      player.scoreMeasured = false;
    }

    for (var i = 0; i < totalPlayers; i++) {
      final player = getNextHighestScore();
      scoreBuilder.write('${i + 1}. ${player.name} ${player.score}\n');
    }
    scoreText.value = scoreBuilder.toString();
  }
}