import 'dart:convert';
import 'dart:typed_data';

import 'package:bleed_common/DynamicObjectType.dart';
import 'package:bleed_common/GameEventType.dart';
import 'package:bleed_common/ItemType.dart';
import 'package:bleed_common/PlayerEvent.dart';
import 'package:bleed_common/ServerResponse.dart';
import 'package:bleed_common/SlotType.dart';
import 'package:bleed_common/compile_util.dart';
import 'package:bleed_common/constants.dart';
import 'package:bleed_common/enums/ProjectileType.dart';
import 'package:gamestream_flutter/classes/Character.dart';
import 'package:gamestream_flutter/modules/game/state.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/send.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/enums.dart';
import 'package:lemon_watch/watch.dart';

import 'state/game.dart';

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
final _slots = _player.slots;
final _orbs = _player.orbs;
final _hours = modules.isometric.state.hours;
final _minutes = modules.isometric.state.minutes;


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

    framesSinceUpdateReceived.value = 0;
    _index = 0;
    bufferSize.value = values.length;
    this.values = values;
    while (true) {
      final response = _nextByte();
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
          _parseDynamicObjects();
          break;
        case ServerResponse.Player_Attack_Target:
          _player.attackTarget.x = _nextDouble();
          _player.attackTarget.y = _nextDouble();
          engine.cursorType.value = CursorType.Click;
          break;
        case ServerResponse.Player_Attack_Target_None:
          _player.attackTarget.x = 0;
          _player.attackTarget.y = 0;
          engine.cursorType.value = CursorType.Basic;
          break;
        case ServerResponse.Paths:
          modules.game.state.compilePaths.value = true;
          final paths = modules.isometric.state.paths;
          var index = 0;
          while (true) {
            final pathIndex = _nextInt();
            paths[index] = pathIndex.toDouble();
            index++;
            if (pathIndex == 250) break;
            for (var i = 0; i < pathIndex; i++) {
              paths[index] = _nextDouble();
              paths[index + 1] = _nextDouble();
              index += 2;
            }
          }
          break;
        case ServerResponse.Game_Time:
          _hours.value = _nextByte();
          _minutes.value = _nextByte();
          break;
        case ServerResponse.No_Change:
          print("ServerResponse.No_Change");
          modules.game.update.readPlayerInput();
          sendRequestUpdatePlayer();
          return;
        case ServerResponse.Player:
          final nextServerFrame =  _nextInt();
          if (nextServerFrame == _player.serverFrame.value){
            // HOW IS THIS STILL BEING REACHED, PATCHED SHOULD BE GETTING RETURNED
            // print("NO CHANGE FROM SERVER");
            // modules.game.update.readPlayerInput();
            // sendRequestUpdatePlayer();
            return;
          }

          final previousX = _player.x;
          final previousY = _player.y;
          final x = _nextDouble();
          final y = _nextDouble();

          final velocityX = x - previousX;
          final velocityY = y - previousY;

          _player.velocity.x = velocityX;
          _player.velocity.y = velocityY;

          _player.x = x;
          _player.y = y;

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

          _player.health.value = _nextDouble();
          _player.maxHealth = _nextDouble();
          _player.magic.value = _nextDouble();
          _player.maxMagic.value = _nextDouble();
          readSlot(_slots.weapon);
          _slots.armour.type.value = _readSlotType();
          _slots.helm.type.value = _readSlotType();
          readSlot(_slots.slot1);
          readSlot(_slots.slot2);
          readSlot(_slots.slot3);
          readSlot(_slots.slot4);
          readSlot(_slots.slot5);
          readSlot(_slots.slot6);
          _orbs.topaz.value = _nextInt();
          _orbs.emerald.value = _nextInt();
          _orbs.ruby.value = _nextInt();
          _player.alive.value = readBool();
          _player.storeVisible.value = readBool();
          _player.serverFrame.value = nextServerFrame;
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

  void _parseGameEvents(){
    while (true) {
      final typeIndex = _nextByte();
      if (typeIndex == END) break;
      final type = gameEventTypes[typeIndex];
      final x = _nextDouble();
      final y = _nextDouble();
      final angle = _nextDouble() * degreesToRadians;
      modules.game.events.onGameEvent(type, x, y, angle);
    }
  }

  void _parseProjectiles(){
    final total = _nextInt();
    final projectiles = game.projectiles;
    game.totalProjectiles = total;
    for (var i = 0; i < total; i++) {
      final projectile = projectiles[i];
      projectile.x = _nextDouble();
      projectile.y = _nextDouble();
      projectile.type = _readProjectileType();
      projectile.angle = _nextDouble() * degreesToRadians;
    }
  }

  void _parseCharacterTeamDirectionState(Character character){
    final teamDirectionState = _nextByte();
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
      final stateInt = _nextByte();
      if (stateInt == END) break;
      final character = zombies[total];
      readTeamDirectionState(character, stateInt);
      character.x = _nextDouble();
      character.y = _nextDouble();
      _parseCharacterFrameHealth(character, _nextByte());
      total++;
    }
    game.totalZombies.value = total;
  }

  void _parseItems(){
    final items = isometric.state.items;
    var index = 0;
    while(true) {
      final itemTypeIndex = _nextByte();
      if (itemTypeIndex == END) break;
      final item = items[index];
      item.type = itemTypes[itemTypeIndex];
      item.x = _nextDouble();
      item.y = _nextDouble();
      index++;
    }
    game.itemsTotal = index;
  }

  void _parsePlayers() {
    final players = game.players;
    var total = 0;
    while(true) {
      final teamDirectionState = _nextByte();
      if (teamDirectionState == END) break;
      final character = players[total];
      readTeamDirectionState(character, teamDirectionState);
      character.x = _nextDouble();
      character.y = _nextDouble();
      _parseCharacterFrameHealth(character, _nextByte());
      character.magic = _nextPercentage();
      character.equippedWeapon = _readSlotType();
      character.equippedArmour = _readSlotType();
      character.equippedHead = _readSlotType();
      character.name = readString();
      character.score = _nextInt();
      character.text = readString();
      total++;
    }
    game.totalPlayers.value = total;
    game.updateScoreText();
  }

  void _parseNpcs() {
    final total = _nextInt();
    final npcs = game.interactableNpcs;
    game.totalNpcs = total;
    for (var i = 0; i < total; i++){
      _readNpc(npcs[i]);
    }
  }

  void _readNpc(Character character){
    _readCharacter(character);
    character.equippedWeapon = _readSlotType();
  }

  void _readCharacter(Character character){
     _parseCharacterTeamDirectionState(character);
     character.x = _nextDouble();
     character.y = _nextDouble();
     _parseCharacterFrameHealth(character, _nextByte());
  }

  void _parseCharacterFrameHealth(Character character, int byte){
    final frame = byte % 10;
    final health = (byte - frame) / 240.0;
    character.frame = frame;
    character.health = health;
  }

  void readSlot(Slot slot) {
     slot.type.value = _readSlotType();
     slot.amount.value = _nextInt();
  }

  SlotType _readSlotType(){
    return slotTypes[_nextByte()];
  }

  ProjectileType _readProjectileType(){
    return projectileTypes[_nextByte()];
  }

  double _nextPercentage(){
    return _nextByte() / 100.0;
  }

  int _nextByte(){
    return values[_index++];
  }

  bool readBool(){
    return _nextByte() == 1;
  }

  int _nextInt(){
    final value = readNumberFromByteArray(values, index: _index);
    _index += 2;
    return value;
  }

  double _nextDouble(){
    return _nextInt().toDouble();
  }

  String readString() {
    const emptyString = "";
    final length = _nextInt();
    if (length == 0) return emptyString;
    return utf8.decode(readBytes(length));
  }

  List<int> readBytes(int length){
    final values = _getByteStream(length);
    for (var i = 0; i < length; i++) {
      values[i] = _nextByte();
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
     final total = _nextByte();
     for(var i = 0; i < total; i++){
        modules.game.events.onPlayerEvent(playerEvents[_nextByte()]);
     }
  }

  void _parseDynamicObjects() {
      var total = 0;
      while (true) {
         final typeIndex = _nextByte();
         if (typeIndex == END) break;
         final dynamicObject = game.dynamicObjects[total];
         dynamicObject.type = dynamicObjectTypes[typeIndex];
         dynamicObject.x = _nextDouble();
         dynamicObject.y = _nextDouble();
         dynamicObject.health = _nextPercentage();
         total++;
      }
      game.totalDynamicObjects.value = total;
  }
}