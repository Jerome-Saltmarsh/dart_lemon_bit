import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/actions/initialize_isometric_game_state.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/classes/deck_card.dart';
import 'package:gamestream_flutter/isometric/classes/game_object.dart';
import 'package:gamestream_flutter/isometric/collectables.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/enums/camera_mode.dart';
import 'package:gamestream_flutter/isometric/events/on_game_event.dart';
import 'package:gamestream_flutter/isometric/events/on_player_event.dart';
import 'package:gamestream_flutter/isometric/floating_texts.dart';
import 'package:gamestream_flutter/isometric/players.dart';
import 'package:gamestream_flutter/isometric/projectiles.dart';
import 'package:gamestream_flutter/isometric/zombies.dart';
import 'package:gamestream_flutter/modules/game/state.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:lemon_byte/byte_reader.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/enums.dart';
import 'package:lemon_math/library.dart';
import 'package:lemon_watch/watch.dart';

import 'ai.dart';
import 'classes/npc_debug.dart';
import 'grid.dart';
import 'items.dart';
import 'particle_emitters.dart';
import 'player.dart';
import 'time.dart';

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

void cameraCenterOnPlayer(){
  engine.cameraCenter(player.x, player.y);
  _previousPlayerScreenX1 = worldToScreenX(player.x);
  _previousPlayerScreenY1 = worldToScreenY(player.y);
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


class ServerResponseReader with ByteReader {
  final interactableNpcs = <Character>[];
  final gameObjects = <GameObject>[];
  final bulletHoles = <Vector2>[];
  final npcDebug = <NpcDebug>[];
  final scoreBuilder = StringBuffer();
  final scoreText = Watch("");
  var totalNpcs = 0;
  var bulletHoleIndex = 0;
  var itemsTotal = 0;

  ServerResponseReader(){
    initializeIsometricGameState();
  }

  void readBytes(List<int> values) {
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
          readerItems();
          break;
        case ServerResponse.Players:
          _parsePlayers();
          break;
        case ServerResponse.Npcs:
          _parseNpcs();
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
          throw Exception("No longer ServerResponse.Tiles");

        case ServerResponse.Debug_Mode:
          modules.game.state.debug.value = readBool();
          break;

        case ServerResponse.Player_Attack_Target:
          player.attackTarget.x = readDouble();
          player.attackTarget.y = readDouble();
          engine.cursorType.value = CursorType.Click;
          break;
        case ServerResponse.Player_Attack_Target_None:
          player.attackTarget.x = 0;
          player.attackTarget.y = 0;
          engine.cursorType.value = CursorType.Basic;
          break;
        case ServerResponse.Collectables:
          var totalCollectables = 0;
          var type = readByte();
          while (type != END) {
            final collectable = collectables[totalCollectables];
            collectable.type = type;
            readVector2(collectable);
            totalCollectables++;
            type = readByte();
          }
          break;
          
        case ServerResponse.Structures:
          throw Exception("No longer supported ${ServerResponse.Structures}");

        case ServerResponse.Tech_Types:
          player.levelPickaxe.value = readByte();
          player.levelSword.value = readByte();
          player.levelBow.value = readByte();
          player.levelAxe.value = readByte();
          player.levelHammer.value = readByte();
          break;

        case ServerResponse.Damage_Applied:
          final x = readDouble();
          final y = readDouble() - 5;
          final amount = readInt();
          spawnFloatingText(x, y, amount.toString());
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
          break;

        case ServerResponse.Game_Time:
          hours.value = readByte();
          minutes.value = readByte();
          break;

        case ServerResponse.Player:
          player.x = readDouble();
          player.y = readDouble();
          player.z = readDouble();
          player.angle = readDouble() / 100.0;
          player.mouseAngle = readDouble() / 100.0;

          switch(modules.game.state.cameraMode.value){
            case CameraMode.Chase:
              const cameraFollowSpeed = 0.001;
              final playerScreenX = player.renderX;
              final playerScreenY = player.renderY;
              engine.cameraFollow(playerScreenX, playerScreenY, cameraFollowSpeed);
              final playerScreenX2 = player.renderX;
              final playerScreenY2 = player.renderY;
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
              _previousPlayerScreenX1 = player.renderX;
              _previousPlayerScreenY2 = player.renderY;
              break;
            case CameraMode.Locked:
              engine.cameraCenter(player.x, player.y);
              break;
            case CameraMode.Free:
              break;
          }

          player.health.value = readDouble();
          player.maxHealth = readDouble();
          player.magic.value = readDouble();
          player.maxMagic.value = readDouble();
          player.equippedWeapon.value = readByte();
          player.armour.value = readByte();
          player.helm.value = readByte();
          player.alive.value = readBool();
          player.storeVisible.value = readBool();
          player.wood.value = readInt();
          player.stone.value = readInt();
          player.gold.value = readInt();
          player.experience.value = readPercentage();
          player.level.value = readByte();
          player.skillPoints.value = readByte();
          break;

        case ServerResponse.Player_Slots:
          break;

        case ServerResponse.Player_Spawned:
          player.x = readDouble();
          player.y = readDouble();
          cameraCenterOnPlayer();
          engine.zoom = 1.0;
          engine.targetZoom = 1.0;
          break;

        case ServerResponse.Player_Target:
          readPosition(player.abilityTarget);
          break;

        case ServerResponse.Block_Set:
          final z = readInt();
          final row = readInt();
          final column = readInt();
          final type = readInt();
          grid[z][row][column] = type;
          edit.type.value = grid[edit.z][edit.row][edit.column];
          onGridChanged();
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
    player.selectCharacterRequired.value = readBool();
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

  void _parseZombies() {
    totalZombies = 0;
    while (true) {
      final stateInt = readByte();
      if (stateInt == END) break;
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
    totalPlayers = total;
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

  void readPlayerEvents() {
    onPlayerEvent(readByte());
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
        addSmokeEmitter(instance.x, instance.y);
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