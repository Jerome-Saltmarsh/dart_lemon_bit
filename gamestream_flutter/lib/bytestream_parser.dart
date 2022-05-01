import 'dart:convert';
import 'package:lemon_math/library.dart';
import 'dart:typed_data';

import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/modules/game/state.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/enums.dart';
import 'package:lemon_watch/watch.dart';

import 'modules/isometric/classes.dart';
import 'modules/isometric/enums.dart';
import 'game.dart';

final byteStreamParser = _ByteStreamParser();
final byteLength = Watch(0);
final bufferSize = Watch(0);
final totalEvents = Watch(0);
final framesSinceUpdateReceived = Watch(0);
final msSinceLastUpdate = Watch(0);
final averageUpdate = Watch(0.0);
final sync = Watch(0.0);
var durationTotal = 0;


final _player = modules.game.state.player;
final _orbs = _player.orbs;
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

Character? findPlayerCharacter(){
  final total = game.totalPlayers.value;
  for (var i = 0; i < total; i++) {
    final character = game.players[i];
    if (character.x != _player.x) continue;
    if (character.y != _player.y) continue;
    return character;
  }
  return null;
}

var _previousPlayerScreenX1 = 0.0;
var _previousPlayerScreenY1 = 0.0;
var _previousPlayerScreenX2 = 0.0;
var _previousPlayerScreenY2 = 0.0;
var _previousPlayerScreenX3 = 0.0;
var _previousPlayerScreenY3 = 0.0;

class _ByteStreamParser {
  var _index = 0;
  var values = <int>[];
  final _byteStreamPool = <int, Uint8List>{};

  void parse(List<int> values) {
    if (modules.game.state.debugPanelVisible.value){
      updateSync();
    }

    framesSinceUpdateReceived.value = 0;
    _index = 0;
    bufferSize.value = values.length;
    this.values = values;
    while (true) {
      final response = nextByte();
      switch(response){
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
        case ServerResponse.Player_Attack_Target:
          _player.attackTarget.x = nextDouble();
          _player.attackTarget.y = nextDouble();
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
          var type = nextByte();
          while (type != END) {
            final collectable = collectables[total];
            collectable.type = type;
            readVector2(collectable);
            total++;
            type = nextByte();
          }
          game.totalCollectables = total;
          break;
        case ServerResponse.Structures:
          final structures = isometric.structures;
          var total = 0;
          var type = nextByte();
          while (type != END) {
             final structure = structures[total];
             structure.x = nextDouble();
             structure.y = nextDouble();
             structure.type = type;
             total++;
             type = nextByte();
          }
          isometric.totalStructures = total;
          break;

        case ServerResponse.Tech_Types:
          _player.levelPickaxe.value = nextByte();
          _player.levelSword.value = nextByte();
          _player.levelBow.value = nextByte();
          _player.levelAxe.value = nextByte();
          break;

        case ServerResponse.Damage_Applied:
          final x = nextDouble();
          final y = nextDouble() - 5;
          final amount = nextInt();
          isometric.spawnFloatingText(x, y, amount.toString());
          break;

        case ServerResponse.Paths:
          modules.game.state.compilePaths.value = true;
          final paths = modules.isometric.paths;
          var index = 0;
          while (true) {
            final pathIndex = nextInt();
            paths[index] = pathIndex.toDouble();
            index++;
            if (pathIndex == 250) break;
            for (var i = 0; i < pathIndex; i++) {
              paths[index] = nextDouble();
              paths[index + 1] = nextDouble();
              index += 2;
            }
          }
          final targets = modules.isometric.targets;
          var i = 0;

          while(nextByte() != 0) {
             targets[i] = nextDouble();
             targets[i + 1] = nextDouble();
             targets[i + 2] = nextDouble();
             targets[i + 3] = nextDouble();
             i += 4;
          }
          modules.isometric.targetsTotal = i;
          break;
        case ServerResponse.Game_Time:
          _hours.value = nextByte();
          _minutes.value = nextByte();
          break;
        case ServerResponse.Player:
          _player.x = nextDouble();
          _player.y = nextDouble();

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

          _player.health.value = nextDouble();
          _player.maxHealth = nextDouble();
          _player.magic.value = nextDouble();
          _player.maxMagic.value = nextDouble();
          _player.equipped.value = nextByte();
          _player.armour.value = nextByte();
          _player.helm.value = nextByte();
          // readSlot(_slots.weapon);
          // _slots.armour.type.value = nextByte();
          // _slots.helm.type.value = nextByte();
          _player.alive.value = readBool();
          _player.storeVisible.value = readBool();
          _player.wood.value = nextInt();
          _player.stone.value = nextInt();
          _player.gold.value = nextInt();
          break;


        case ServerResponse.Player_Orbs:
          _orbs.topaz.value = nextInt();
          _orbs.emerald.value = nextInt();
          _orbs.ruby.value = nextInt();
          break;

        case ServerResponse.Player_Slots:
          // readSlot(_slots.slot1);
          // readSlot(_slots.slot2);
          // readSlot(_slots.slot3);
          // readSlot(_slots.slot4);
          // readSlot(_slots.slot5);
          // readSlot(_slots.slot6);
          break;


        case ServerResponse.End:
          byteLength.value = _index;
          _index = 0;
          engine.redrawCanvas();
          return;

        default:
          throw Exception("Cannot parse $response");
      }
    }
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
      final type = nextByte();
      final x = nextDouble();
      final y = nextDouble();
      final angle = nextDouble() * degreesToRadians;
      modules.game.events.onGameEvent(type, x, y, angle);
  }

  void _parseProjectiles(){
    final total = nextInt();
    final projectiles = game.projectiles;
    game.totalProjectiles = total;
    for (var i = 0; i < total; i++) {
      final projectile = projectiles[i];
      projectile.x = nextDouble();
      projectile.y = nextDouble();
      projectile.type = nextByte();
      projectile.angle = nextDouble() * degreesToRadians;
    }
  }

  void _parseCharacterTeamDirectionState(Character character){
    final teamDirectionState = nextByte();
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
      final stateInt = nextByte();
      if (stateInt == END) break;
      final character = zombies[total];
      readTeamDirectionState(character, stateInt);
      character.x = nextDouble();
      character.y = nextDouble();
      _parseCharacterFrameHealth(character, nextByte());
      total++;
    }
    game.totalZombies.value = total;
  }

  void _parseItems(){
    final items = isometric.items;
    var index = 0;
    while(true) {
      final itemTypeIndex = nextByte();
      if (itemTypeIndex == END) break;
      final item = items[index];
      item.type = itemTypeIndex;
      item.x = nextDouble();
      item.y = nextDouble();
      index++;
    }
    game.itemsTotal = index;
  }

  void _parsePlayers() {
    final players = game.players;
    var total = 0;
    while(true) {
      final teamDirectionState = nextByte();
      if (teamDirectionState == END) break;
      final character = players[total];
      readTeamDirectionState(character, teamDirectionState);
      character.x = nextDouble();
      character.y = nextDouble();
      _parseCharacterFrameHealth(character, nextByte());
      character.magic = _nextPercentage();
      character.equipped = nextByte();
      character.armour = nextByte();
      character.helm = nextByte();
      character.name = readString();
      character.score = nextInt();
      character.text = readString();
      total++;
    }
    game.totalPlayers.value = total;
    game.updateScoreText();
  }

  void _parseNpcs() {
    final total = nextInt();
    final npcs = game.interactableNpcs;
    game.totalNpcs = total;
    for (var i = 0; i < total; i++){
      _readNpc(npcs[i]);
    }
  }

  void _readNpc(Character character){
    _readCharacter(character);
    character.equipped = nextByte();
  }

  void _readCharacter(Character character){
     _parseCharacterTeamDirectionState(character);
     character.x = nextDouble();
     character.y = nextDouble();
     _parseCharacterFrameHealth(character, nextByte());
  }

  void _parseCharacterFrameHealth(Character character, int byte){
    final frame = byte % 10;
    final health = (byte - frame) / 240.0;
    character.frame = frame;
    character.health = health;
  }

  void readSlot(Slot slot) {
     slot.type.value = readSlotType();
     slot.amount.value = nextInt();
  }

  int readSlotType(){
    return nextByte();
  }

  double _nextPercentage(){
    return nextByte() / 100.0;
  }

  int nextByte(){
    return values[_index++];
  }

  bool readBool(){
    return nextByte() == 1;
  }

  int nextInt(){
    final value = readNumberFromByteArray(values, index: _index);
    _index += 2;
    return value;
  }

  double nextDouble(){
    return nextInt().toDouble();
  }

  String readString() {
    const emptyString = "";
    final length = nextInt();
    if (length == 0) return emptyString;
    return utf8.decode(readBytes(length));
  }

  List<int> readBytes(int length){
    final values = _getByteStream(length);
    for (var i = 0; i < length; i++) {
      values[i] = nextByte();
    }
    return values;
  }

  /// Recycles bytestreams to prevent memory leak
  List<int> _getByteStream(int length){
    var stream = _byteStreamPool[length];
    if (stream != null) return stream;
    stream = Uint8List(length);
    _byteStreamPool[length] = stream;
    return stream;
  }

  void _parsePlayerEvents() {
    _events.onPlayerEvent(nextByte());
  }

  void parseDynamicObjects() {
    var total = 0;
    while (true) {
      final typeIndex = nextByte();
      if (typeIndex == END) break;
      final dynamicObject = game.dynamicObjects[total];
      dynamicObject.type = typeIndex;
      dynamicObject.x = nextDouble();
      dynamicObject.y = nextDouble();
      dynamicObject.id = nextInt();
      total++;
    }
    game.totalDynamicObjects.value = total;
  }

  void readVector2(Vector2 value){
    value.x = nextDouble();
    value.y = nextDouble();
  }
}