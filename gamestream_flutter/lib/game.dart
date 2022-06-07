import 'package:bleed_common/card_type.dart';
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/classes/deck_card.dart';
import 'package:gamestream_flutter/classes/game_object.dart';
import 'package:gamestream_flutter/classes/GeneratedObject.dart';
import 'package:gamestream_flutter/modules/game/state.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:lemon_byte/byte_reader.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/enums.dart';
import 'package:lemon_math/library.dart';
import 'package:lemon_watch/watch.dart';

import 'classes/Explosion.dart';
import 'classes/NpcDebug.dart';
import 'classes/Projectile.dart';
import 'modules/isometric/classes.dart';
import 'modules/isometric/enums.dart';
import 'ui/builders/player.dart';

final game = Game();
final byteLength = Watch(0);
final bufferSize = Watch(0);
final totalEvents = Watch(0);
final framesSinceUpdateReceived = Watch(0);
final msSinceLastUpdate = Watch(0);
final averageUpdate = Watch(0.0);
final sync = Watch(0.0);
var durationTotal = 0;

final _player = modules.game.state.player;
final _hours = modules.isometric.hours;
final _minutes = modules.isometric.minutes;
final _events = modules.game.events;

var time = DateTime.now();

void cameraCenterOnPlayer(){
  print("cameraCenterOnPlayer()");
  engine.cameraCenter(_player.x, _player.y);
  _previousPlayerScreenX1 = worldToScreenX(_player.x);
  _previousPlayerScreenY1 = worldToScreenY(_player.y);
  _previousPlayerScreenX2 = _previousPlayerScreenX1;
  _previousPlayerScreenY2 = _previousPlayerScreenY1;
  _previousPlayerScreenX3 = _previousPlayerScreenX1;
  _previousPlayerScreenY3 = _previousPlayerScreenY1;
}

var _previousPlayerScreenX1 = 0.0;
var _previousPlayerScreenY1 = 0.0;
var _previousPlayerScreenX2 = 0.0;
var _previousPlayerScreenY2 = 0.0;
var _previousPlayerScreenX3 = 0.0;
var _previousPlayerScreenY3 = 0.0;

class Game with ByteReader {

  final grid = <List<List<int>>>[];
  final type = Watch<GameType?>(null);
  final countDownFramesRemaining = Watch(0);
  final numberOfPlayersNeeded = Watch(0);
  final teamLivesWest = Watch(-1);
  final teamLivesEast = Watch(-1);
  final teamSize = Watch(0);
  final numberOfTeams = Watch(0);
  final totalZombies = Watch(0);
  final totalPlayers = Watch(0);
  final players = <Character>[];
  final zombies = <Character>[];
  final collectables = <Collectable>[];
  final interactableNpcs = <Character>[];
  final gameObjects = <GameObject>[];
  final generatedObjects = <GeneratedObject>[];
  final effects = <Effect>[];
  final torches = <GameObject>[]; // todo remove
  final projectiles = <Projectile>[];
  final crates = <Vector2>[];
  final bulletHoles = <Vector2>[];
  final npcDebug = <NpcDebug>[];
  final scoreBuilder = StringBuffer();
  final scoreText = Watch("");
  var customGameName = "";
  var totalNpcs = 0;
  var totalCollectables = 0;
  var bulletHoleIndex = 0;
  var totalProjectiles = 0;
  var itemsTotal = 0;

  Game(){
    for (var i = 0; i < 150; i++) {
      players.add(Character());
    }
    for (var i = 0; i < 50; i++) {
      interactableNpcs.add(Character());
    }
    for (var i = 0; i < 2000; i++) {
      zombies.add(Character());
    }
    for (var i = 0; i < 50; i++) {
      bulletHoles.add(Vector2(0, 0));
    }
    for (var i = 0; i < 200; i++) {
      projectiles.add(Projectile());
    }
    for (var i = 0; i < 500; i++) {
      collectables.add(Collectable());
    }
  }


  void parse(List<int> values) {
    // if (modules.game.state.debugPanelVisible.value){
    //   updateSync();
    // }
    framesSinceUpdateReceived.value = 0;
    index = 0;
    bufferSize.value = values.length;
    this.values = values;
    while (true) {
      final response = readByte();
      switch (response){
        case ServerResponse.Zombies:
          _parseZombies();
          break;
        case ServerResponse.Items:
          _parseItems();
          break;
        case ServerResponse.Players:
          _parsePlayers();
          break;
        case ServerResponse.Npcs:
          _parseNpcs();
          break;
        case ServerResponse.Projectiles:
          _parseProjectiles();
          break;
        case ServerResponse.Game_Events:
          _parseGameEvents();
          break;
        case ServerResponse.Player_Events:
          _parsePlayerEvents();
          break;
        case ServerResponse.Game_Objects:
          readGameObjects();
          break;

        case ServerResponse.Player_Deck_Cooldown:
          final length = readByte();
          assert (length == player.deck.value.length);
          for (var i = 0; i < length; i++){
              final card = player.deck.value[i];
              card.cooldownRemaining.value = readByte();
              card.cooldown.value = readByte();
          }
          break;

        case ServerResponse.Player_Deck:
          player.deck.value = readDeck();
          break;

        case ServerResponse.Grid:
          print("reading grid");
          final totalZ = readInt();
          final totalRows = readInt();
          final totalColumns = readInt();
          grid.clear();
          for (var z = 0; z < totalZ; z++) {
             final plain = <List<int>>[];
             grid.add(plain);
             for (var rowIndex = 0; rowIndex < totalRows; rowIndex++) {
                final row = <int>[];
                for (var columnIndex = 0; columnIndex < totalColumns; columnIndex++) {
                    row.add(readByte());
                }
             }
          }
          break;

        case ServerResponse.Player_Deck_Active_Ability:
          player.deckActiveCardIndex.value = readByte();
          player.deckActiveCardRange.value = readDouble();
          player.deckActiveCardRadius.value = readDouble();
          engine.cursorType.value = CursorType.Click;
          break;

        case ServerResponse.Player_Deck_Active_Ability_None:
          player.deckActiveCardIndex.value = -1;
          engine.cursorType.value = CursorType.Basic;
          break;

        case ServerResponse.Card_Choices:
          player.cardChoices.value = readCardTypes();
          break;

        case ServerResponse.Character_Select_Required:
          parseCharacterSelectRequired();
          break;

        case ServerResponse.Game_Status:
          core.state.status.value = gameStatuses[readByte()];
          break;

        case ServerResponse.Tiles:
          parseTiles();
          break;

        case ServerResponse.Debug_Mode:
          modules.game.state.debug.value = readBool();
          break;

        case ServerResponse.Player_Attack_Target:
          _player.attackTarget.x = readDouble();
          _player.attackTarget.y = readDouble();
          engine.cursorType.value = CursorType.Click;
          break;
        case ServerResponse.Player_Attack_Target_None:
          _player.attackTarget.x = 0;
          _player.attackTarget.y = 0;
          engine.cursorType.value = CursorType.Basic;
          break;
        case ServerResponse.Collectables:
          var total = 0;
          var type = readByte();
          while (type != END) {
            final collectable = collectables[total];
            collectable.type = type;
            readVector2(collectable);
            total++;
            type = readByte();
          }
          totalCollectables = total;
          break;
          
        case ServerResponse.Structures:
          final structures = isometric.structures;
          var total = 0;
          var type = readByte();
          while (type != END) {
             final structure = structures[total];
             structure.x = readDouble();
             structure.y = readDouble();
             structure.type = type;
             total++;
             type = readByte();
          }
          isometric.totalStructures = total;
          break;

        case ServerResponse.Tech_Types:
          _player.levelPickaxe.value = readByte();
          _player.levelSword.value = readByte();
          _player.levelBow.value = readByte();
          _player.levelAxe.value = readByte();
          _player.levelHammer.value = readByte();
          break;

        case ServerResponse.Damage_Applied:
          final x = readDouble();
          final y = readDouble() - 5;
          final amount = readInt();
          isometric.spawnFloatingText(x, y, amount.toString());
          break;

        case ServerResponse.Dynamic_Object_Destroyed:
          final id = readInt();
          gameObjects.removeWhere((dynamicObject) => dynamicObject.id == id);
          break;

        case ServerResponse.Dynamic_Object_Spawned:
          final instance = GameObject();
          instance.type = readByte();
          instance.x = readDouble();
          instance.y = readDouble();
          instance.id = readInt();
          gameObjects.add(instance);
          sortVertically(gameObjects);
          break;

        case ServerResponse.Lives_Remaining:
          modules.game.state.lives.value = readByte();
          break;

        case ServerResponse.Paths:
          modules.game.state.debug.value = true;
          final paths = modules.isometric.paths;
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
          final targets = modules.isometric.targets;
          var i = 0;

          while(readByte() != 0) {
             targets[i] = readDouble();
             targets[i + 1] = readDouble();
             targets[i + 2] = readDouble();
             targets[i + 3] = readDouble();
             i += 4;
          }
          modules.isometric.targetsTotal = i;
          break;

        case ServerResponse.Game_Time:
          _hours.value = readByte();
          _minutes.value = readByte();
          break;

        case ServerResponse.Player:
          _player.x = readDouble();
          _player.y = readDouble();

          switch(modules.game.state.cameraMode.value){
            case CameraMode.Chase:
              const cameraFollowSpeed = 0.001;
              final playerScreenX = worldToScreenX(_player.x);
              final playerScreenY = worldToScreenY(_player.y);
              engine.cameraFollow(_player.x, _player.y, cameraFollowSpeed);
              final playerScreenX2 = worldToScreenX(_player.x);
              final playerScreenY2 = worldToScreenY(_player.y);
              final distanceWorldX = ((playerScreenX2 - playerScreenX) / engine.zoom) * 0.5;
              final distanceWorldY = ((playerScreenY2 - playerScreenY) / engine.zoom) * 0.5;

              engine.camera.x += distanceWorldX * 0.5;
              engine.camera.y += distanceWorldY * 0.5;

              final distanceWorldX2 = ((playerScreenX2 - _previousPlayerScreenX2) / engine.zoom) * 0.5;
              final distanceWorldY2 = ((playerScreenY2 - _previousPlayerScreenY2) / engine.zoom) * 0.5;

              engine.camera.x += distanceWorldX2 * 0.4;
              engine.camera.y += distanceWorldY2 * 0.4;

              final distanceWorldX3 = ((playerScreenX2 - _previousPlayerScreenX3) / engine.zoom) * 0.5;
              final distanceWorldY3 = ((playerScreenY2 - _previousPlayerScreenY3) / engine.zoom) * 0.5;

              engine.camera.x += distanceWorldX3 * 0.3;
              engine.camera.y += distanceWorldY3 * 0.3;

              _previousPlayerScreenX3 = _previousPlayerScreenX2;
              _previousPlayerScreenY3 = _previousPlayerScreenY2;
              _previousPlayerScreenX2 = _previousPlayerScreenX1;
              _previousPlayerScreenY2 = _previousPlayerScreenY1;
              _previousPlayerScreenX1 = worldToScreenX(_player.x);
              _previousPlayerScreenY2 = worldToScreenY(_player.y);
              break;
            case CameraMode.Locked:
              engine.cameraCenter(_player.x, _player.y);
              break;
            case CameraMode.Free:
              break;
          }

          _player.health.value = readDouble();
          _player.maxHealth = readDouble();
          _player.magic.value = readDouble();
          _player.maxMagic.value = readDouble();
          _player.equippedWeapon.value = readByte();
          _player.armour.value = readByte();
          _player.helm.value = readByte();
          // readSlot(_slots.weapon);
          // _slots.armour.type.value = nextByte();
          // _slots.helm.type.value = nextByte();
          _player.alive.value = readBool();
          _player.storeVisible.value = readBool();
          _player.wood.value = readInt();
          _player.stone.value = readInt();
          _player.gold.value = readInt();
          _player.experience.value = readPercentage();
          _player.level.value = readByte();
          _player.skillPoints.value = readByte();
          break;

        case ServerResponse.Player_Slots:
          break;

        case ServerResponse.Player_Spawned:
          player.x = readDouble();
          player.y = readDouble();
          isometric.resetLighting();
          cameraCenterOnPlayer();
          engine.zoom = 1.0;
          engine.targetZoom = 1.0;
          break;

        case ServerResponse.Player_Target:
          readPosition(player.abilityTarget);
          break;

        case ServerResponse.End:
          byteLength.value = index;
          index = 0;
          engine.redrawCanvas();
          return;

        default:
          throw Exception("Cannot parse $response");
      }
    }
  }

  void parseCharacterSelectRequired() {
    modules.game.state.player.selectCharacterRequired.value = readBool();
  }

  void parseTiles() {
    print("parse.tiles()");
    final isometric = modules.isometric;
    final rows = readInt();
    final columns = readInt();
    final tiles = isometric.tiles;
    tiles.clear();
    isometric.totalRows.value = rows;
    isometric.totalColumns.value = columns;
    isometric.totalRowsInt = rows;
    isometric.totalColumnsInt = columns;
    for (var row = 0; row < rows; row++) {
      final List<int> column = [];
      for (var columnIndex = 0; columnIndex < columns; columnIndex++) {
        column.add(readByte());
      }
      tiles.add(column);
    }
    isometric.refreshGeneratedObjects();
    isometric.updateTileRender();
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

  void _parseGameEvents(){
      final type = readByte();
      final x = readDouble();
      final y = readDouble();
      final angle = readDouble() * degreesToRadians;
      modules.game.events.onGameEvent(type, x, y, angle);
  }

  void _parseProjectiles(){
    totalProjectiles = readInt();
    for (var i = 0; i < totalProjectiles; i++) {
      final projectile = projectiles[i];
      projectile.x = readDouble();
      projectile.y = readDouble();
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

  void _parseZombies() {
    var total = 0;
    while (true) {
      final stateInt = readByte();
      if (stateInt == END) break;
      final character = zombies[total];
      readTeamDirectionState(character, stateInt);
      character.x = readDouble();
      character.y = readDouble();
      _parseCharacterFrameHealth(character, readByte());
      total++;
    }
    totalZombies.value = total;
  }

  void _parseItems(){
    final items = isometric.items;
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

  void _parsePlayers() {
    var total = 0;
    while (true) {
      final teamDirectionState = readByte();
      if (teamDirectionState == END) break;
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
      character.name = readString();
      character.score = readInt();
      character.text = readString();
      total++;
    }
    totalPlayers.value = total;
    updateScoreText();
  }

  void _parseNpcs() {
    totalNpcs = readInt();
    final npcs = interactableNpcs;
    for (var i = 0; i < totalNpcs; i++){
      _readNpc(npcs[i]);
    }
  }

  void _readNpc(Character character){
    _readCharacter(character);
    character.weapon = readByte();
  }

  void _readCharacter(Character character){
     _parseCharacterTeamDirectionState(character);
     character.x = readDouble();
     character.y = readDouble();
     character.z = readDouble();
     _parseCharacterFrameHealth(character, readByte());
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

  void _parsePlayerEvents() {
    _events.onPlayerEvent(readByte());
  }

  // void parseGameObject() {
  //   final staticObjects = isometric.staticObjects;
  //   staticObjects.clear();
  //   while (true) {
  //     final typeIndex = readByte();
  //     if (typeIndex == END) break;
  //     final x = readDouble();
  //     final y = readDouble();
  //     staticObjects.add(
  //         StaticObject(
  //             x: x,
  //             y: y,
  //             type: objectTypes[typeIndex],
  //         )
  //     );
  //     if (typeIndex == ObjectType.Fireplace.index) {
  //       isometric.addSmokeEmitter(x, y);
  //     }
  //   }
  //   sortVertically(staticObjects);
  // }

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
        isometric.addSmokeEmitter(instance.x, instance.y);
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
    final numberOfPlayers = totalPlayers.value;
    for(var i = 0; i < numberOfPlayers; i++){
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
    final totalNumberOfPlayers = totalPlayers.value;
    if (totalNumberOfPlayers <= 0) return;
    scoreBuilder.write("SCORE\n");

    for (var i = 0; i < totalNumberOfPlayers; i++) {
      final player = players[i];
      player.scoreMeasured = false;
    }

    for (var i = 0; i < totalNumberOfPlayers; i++) {
      final player = getNextHighestScore();
      scoreBuilder.write('${i + 1}. ${player.name} ${player.score}\n');
    }
    scoreText.value = scoreBuilder.toString();
  }
}