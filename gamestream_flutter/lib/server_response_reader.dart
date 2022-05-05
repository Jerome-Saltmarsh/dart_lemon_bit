import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/classes/DynamicObject.dart';
import 'package:gamestream_flutter/modules/game/state.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:lemon_byte/byte_reader.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/enums.dart';
import 'package:lemon_math/library.dart';
import 'package:lemon_watch/watch.dart';

import 'classes/EnvironmentObject.dart';
import 'game.dart';
import 'modules/isometric/classes.dart';
import 'modules/isometric/enums.dart';

final byteStreamParser = ServerResponseReader();
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

class ServerResponseReader extends ByteReader {

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
        case ServerResponse.Dynamic_Objects:
          parseDynamicObjects();
          break;

        case ServerResponse.EnvironmentObjects:
          parseStaticObjects();
          break;

        case ServerResponse.Tiles:
          parseTiles();
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
          final collectables = game.collectables;
          var total = 0;
          var type = readByte();
          while (type != END) {
            final collectable = collectables[total];
            collectable.type = type;
            readVector2(collectable);
            total++;
            type = readByte();
          }
          game.totalCollectables = total;
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
          game.dynamicObjects.removeWhere((dynamicObject) => dynamicObject.id == id);
          break;

        case ServerResponse.Dynamic_Object_Spawned:
          final instance = DynamicObject();
          instance.type = readByte();
          instance.x = readDouble();
          instance.y = readDouble();
          instance.id = readInt();
          game.dynamicObjects.add(instance);
          sortVertically(game.dynamicObjects);
          break;

        case ServerResponse.Paths:
          modules.game.state.compilePaths.value = true;
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
          _player.equipped.value = readByte();
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
          break;

        case ServerResponse.Player_Slots:
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
    final total = readInt();
    final projectiles = game.projectiles;
    game.totalProjectiles = total;
    for (var i = 0; i < total; i++) {
      final projectile = projectiles[i];
      projectile.x = readDouble();
      projectile.y = readDouble();
      projectile.type = readByte();
      projectile.angle = readDouble() * degreesToRadians;
    }
  }

  void _parseCharacterTeamDirectionState(Character character){
    final teamDirectionState = readByte();
    readTeamDirectionState(character, teamDirectionState);
  }

  void readTeamDirectionState(Character character, int byte){
    final allie = byte >= 100;
    final direction = (byte % 100) ~/ 10;
    final state = byte % 10;
    character.allie = allie;
    character.direction = direction;
    character.state = state;
  }

  void _parseZombies() {
    final zombies = game.zombies;
    var total = 0;
    while(true) {
      final stateInt = readByte();
      if (stateInt == END) break;
      final character = zombies[total];
      readTeamDirectionState(character, stateInt);
      character.x = readDouble();
      character.y = readDouble();
      _parseCharacterFrameHealth(character, readByte());
      total++;
    }
    game.totalZombies.value = total;
  }

  void _parseItems(){
    final items = isometric.items;
    var index = 0;
    while(true) {
      final itemTypeIndex = readByte();
      if (itemTypeIndex == END) break;
      final item = items[index];
      item.type = itemTypeIndex;
      item.x = readDouble();
      item.y = readDouble();
      index++;
    }
    game.itemsTotal = index;
  }

  void _parsePlayers() {
    final players = game.players;
    var total = 0;
    while(true) {
      final teamDirectionState = readByte();
      if (teamDirectionState == END) break;
      final character = players[total];
      readTeamDirectionState(character, teamDirectionState);
      character.x = readDouble();
      character.y = readDouble();
      _parseCharacterFrameHealth(character, readByte());
      character.magic = _nextPercentage();
      character.equipped = readByte();
      character.armour = readByte();
      character.helm = readByte();
      character.name = readString();
      character.score = readInt();
      character.text = readString();
      total++;
    }
    game.totalPlayers.value = total;
    game.updateScoreText();
  }

  void _parseNpcs() {
    final total = readInt();
    final npcs = game.interactableNpcs;
    game.totalNpcs = total;
    for (var i = 0; i < total; i++){
      _readNpc(npcs[i]);
    }
  }

  void _readNpc(Character character){
    _readCharacter(character);
    character.equipped = readByte();
  }

  void _readCharacter(Character character){
     _parseCharacterTeamDirectionState(character);
     character.x = readDouble();
     character.y = readDouble();
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

  void parseStaticObjects() {
    final environmentObjects = modules.isometric.environmentObjects;
    environmentObjects.clear();
    while (true) {
      final typeIndex = readByte();
      if (typeIndex == END) break;
      final x = readDouble();
      final y = readDouble();
      environmentObjects.add(
          EnvironmentObject(
              x: x,
              y: y,
              type: objectTypes[typeIndex],
              radius: 10
          )
      );
    }
    sortVertically(environmentObjects);
  }


  void parseDynamicObjects() {
    game.dynamicObjects.clear();
    while (true) {
      final typeIndex = readByte();
      if (typeIndex == END) break;
      final instance = DynamicObject();
      instance.type = typeIndex;
      instance.x = readDouble();
      instance.y = readDouble();
      instance.id = readInt();
      game.dynamicObjects.add(instance);
    }
  }

  void readVector2(Vector2 value){
    value.x = readDouble();
    value.y = readDouble();
  }
}