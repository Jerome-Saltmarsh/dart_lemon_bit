import 'dart:convert';
import 'dart:typed_data';

import 'package:gamestream_flutter/classes/Character.dart';
import 'package:bleed_common/CharacterState.dart';
import 'package:bleed_common/GameEventType.dart';
import 'package:bleed_common/ServerResponse.dart';
import 'package:bleed_common/SlotType.dart';
import 'package:bleed_common/compile_util.dart';
import 'package:bleed_common/constants.dart';
import 'package:bleed_common/enums/ProjectileType.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/enums.dart';
import 'package:lemon_watch/watch.dart';

import 'state/game.dart';


final _player = modules.game.state.player;

final byteStreamParser = _ByteStreamParser();

const _100D = 100.0;
const _1 = 1;
const _2 = 2;
const _3 = 3;

final _hours = modules.isometric.state.hours;
final _minutes = modules.isometric.state.minutes;

final byteLength = Watch<int>(0);
final bufferSize = Watch<int>(0);

var previousY = 0.0;

class _ByteStreamParser {

  var _index = 0;
  late List<int> values;

  void parse(List<int> values){
    _index = 0;
    bufferSize.value = values.length;
    this.values = values;
    while (true) {
      final response = _nextServerResponse();
      switch(response){
        case ServerResponse.Zombies:
          _parseZombies();
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
        case ServerResponse.Player:
          final player = modules.game.state.player;
          final slots = player.slots;
          final orbs = player.orbs;
          player.x = _nextDouble();
          player.y = _nextDouble();
          player.health.value = _nextDouble();
          player.maxHealth = _nextDouble();
          player.magic.value = _nextDouble();
          player.maxMagic.value = _nextDouble();
          slots.weapon.value = _readSlotType();
          slots.armour.value = _readSlotType();
          slots.helm.value = _readSlotType();
          slots.slot1.value = _readSlotType();
          slots.slot2.value = _readSlotType();
          slots.slot3.value = _readSlotType();
          slots.slot4.value = _readSlotType();
          slots.slot5.value = _readSlotType();
          slots.slot6.value = _readSlotType();
          orbs.topaz.value = _nextInt();
          orbs.emerald.value = _nextInt();
          orbs.ruby.value = _nextInt();
          player.alive.value = readBool();
          break;
        case ServerResponse.End:
          byteLength.value = _index;
          _index = 0;
          return;

        default:
          throw Exception("Cannot parse $response");
      }
    }
  }

  void _parseGameEvents(){
    final total = _nextInt();
    final gameEvents = game.gameEvents;
    for(var i = 0; i < total; i++){
      final id = _nextInt();
      final type = gameEventTypes[_nextByte()];
      final x = _nextDouble();
      final y = _nextDouble();
      final angle = _nextDouble();
      if (gameEvents.containsKey(id)) {
        continue;
      }
      gameEvents[id] = true;
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

  void _parseZombies() {
    final zombies = game.zombies;
    var total = 0;
    while(true) {
      final stateInt = _nextByte();
      if (stateInt == END) break;
      final character = zombies[total];
      character.state = characterStates[stateInt];
      character.direction = _nextByte();
      character.x = _nextDouble();
      character.y = _nextDouble();
      character.frame = _nextByte();
      character.health = _nextPercentage();
      character.team = _nextByte();
      total++;
    }
    game.totalZombies.value = total;
  }

  void _parsePlayers() {
    final players = game.players;
    var total = 0;
    while(true){
      final stateInt = _nextByte();
      if (stateInt == END) break;
      final character = players[total];
      character.state = characterStates[stateInt];
      character.direction = _nextByte();
      character.x = _nextDouble();
      character.y = _nextDouble();
      character.frame = _nextByte();
      character.health = _nextPercentage();
      character.team = _nextByte();
      character.magic = _nextPercentage();
      character.equippedWeapon = _readSlotType();
      character.equippedArmour = _readSlotType();
      character.equippedHead = _readSlotType();
      character.name = readString();
      character.text = readString();
      total++;
    }
    game.totalPlayers = total;
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
     character.state = _readCharacterState();
     character.direction = _nextByte();
     character.x = _nextDouble();
     character.y = _nextDouble();
     character.frame = _nextByte();
     character.health = _nextPercentage();
     character.team = _nextByte();
  }

  CharacterState _readCharacterState(){
    return characterStates[_nextByte()];
  }

  SlotType _readSlotType(){
    return slotTypes[_nextByte()];
  }

  ProjectileType _readProjectileType(){
    return projectileTypes[_nextByte()];
  }

  double _nextPercentage(){
    return _nextByte() / _100D;
  }

  ServerResponse _nextServerResponse(){
    return serverResponses[_nextByte()];
  }

  int _nextByte(){
    final value = values[_index];
    _index++;
    return value;
  }

  bool readBool(){
    final value = _nextByte();
    return value == 1;
  }

  int _nextInt(){
    final pivot = values[_index];
    final value = readNumberFromByteArray(values, index: _index);
    if (pivot <= _1){
      _index += _2;
    } else {
      _index += _3;
    }
    return value;
  }

  double _nextDouble(){
    return _nextInt().toDouble();
  }

  String readString(){
     final length = _nextInt();
     if (length == 0) return "";
     return utf8.decode(readBytes(length));
  }

  List<int> readBytes(int length){
    final values = Uint8List(length);
    for (var i = 0; i < length; i++) {
      values[i] = _nextByte();
    }
    return values;
  }

}