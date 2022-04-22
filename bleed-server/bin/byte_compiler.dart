
import 'dart:convert' show utf8;
import 'dart:typed_data';

import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/angle.dart';

import 'classes/Character.dart';
import 'classes/Game.dart';
import 'classes/Player.dart';
import 'classes/Projectile.dart';
import 'classes/components.dart';
import 'common/ServerResponse.dart';
import 'common/compile_util.dart';
import 'common/constants.dart';

final byteCompiler = _ByteCompiler();

class _ByteCompiler {
  var _index = 0;
  final _buffer = Uint8List(100000); // 100kb
  final List<Uint8List> _buffers = [];


  _ByteCompiler(){
    _buffers.add(Uint8List(75));
    _buffers.add(Uint8List(85));
    _buffers.add(Uint8List(100));
    _buffers.add(Uint8List(125));
    _buffers.add(Uint8List(150));
    _buffers.add(Uint8List(175));
    _buffers.add(Uint8List(200));
    _buffers.add(Uint8List(250));
    _buffers.add(Uint8List(300));
    _buffers.add(Uint8List(350));
  }

  List<int> writeToSendBuffer() {
    writeByte(ServerResponse.End);
    final sendBuffer = _getSendBuffer();
    for (var i = 0; i < _index; i++) {
      sendBuffer[i] = _buffer[i];
    }
    _index = 0;
    return sendBuffer;
  }

  void writeStructures(Player player) {
    writeByte(ServerResponse.Structures);
    final structures = player.game.structures;
    for(final structure in structures){
      if (structure.dead) continue;
       writeByte(structure.type);
       writeVector2(structure);
    }
    writeByte(END);
  }

  void writeCollectables(Player player) {
    writeByte(ServerResponse.Collectables);
    final collectables = player.game.collectables;
    for (final collectable in collectables) {
      if (collectable.inactive) continue;
      writeByte(collectable.type);
      writeVector2(collectable);
    }
    writeByte(END);
  }

  void writePlayerOrbs(Player player) {
    writeByte(ServerResponse.Player_Orbs);
    final orbs = player.orbs;
    writeBigInt(orbs.topaz); // 2
    writeBigInt(orbs.emerald); // 2
    writeBigInt(orbs.ruby); // 2
  }

  void writePlayerSlots(Player player) {
    writeByte(ServerResponse.Player_Slots);
    final slots = player.slots;
    writeSlot(slots.slot1); // 3
    writeSlot(slots.slot2); // 3
    writeSlot(slots.slot3); // 3
    writeSlot(slots.slot4); // 3
    writeSlot(slots.slot5); // 3
    writeSlot(slots.slot6); // 3
  }

  void writePlayerGame(Player player){
    final slots = player.slots;
    final game = player.game;
    writeByte(ServerResponse.Player);
    writeBigInt(player.x);
    writeBigInt(player.y);
    writeBigInt(player.health); // 2
    writeBigInt(player.maxHealth); // 2
    writeBigInt(player.magic); // 2
    writeBigInt(player.maxMagic); // 2
    writeSlot(slots.weapon); // 3
    writeByte(slots.armour.type); // 1
    writeByte(slots.helm.type); // 1
    writeBool(player.alive); // 1
    writeBool(player.storeVisible); // 1
    writeBigInt(player.wood); // 1

    writeStructures(player);
    writeCollectables(player);
    writePlayers(player);
    writeAttackTarget(player);
    writeProjectiles(game.projectiles);
    writeNpcs(player);
    writeGameTime(game);
    writePlayerZombies(player);
    writeItems(player);
    writeDynamicObjects(player);

    if (game.debugMode)
      writePaths(game);
  }

  void writeDynamicObjects(Player player) {
     writeByte(ServerResponse.Dynamic_Objects);
     final dynamicObjects = player.game.scene.dynamicObjects;
     for (final dynamicObject in dynamicObjects) {
       if (dynamicObject.health <= 0) continue;
       if (dynamicObject.x < player.screenLeft) continue;
       if (dynamicObject.x > player.screenRight) continue;
       if (dynamicObject.y < player.screenTop) continue;
       if (dynamicObject.y > player.screenBottom) break;
       writeByte(dynamicObject.type);
       writeVector2(dynamicObject);
       writePercentage(dynamicObject.health / dynamicObject.maxHealth);
     }
     writeByte(END);
  }

  void writeBool(bool value){
    writeByte(value ? 1 : 0);
  }

  void writePaths(Game game) {
    writeByte(ServerResponse.Paths);
    final zombies = game.zombies;
    for (final zombie in zombies) {
      if (zombie.dead) continue;
      final pathIndex = zombie.pathIndex;
      if (pathIndex < 0) continue;
      writeBigInt(pathIndex + 1);
      for (var i = pathIndex; i >= 0; i--) {
        writeBigInt(zombie.pathX[i]);
        writeBigInt(zombie.pathY[i]);
      }
    }
    writeBigInt(250);

    for (final zombie in zombies) {
      if (zombie.dead) continue;
      final aiTarget = zombie.target;
      if (aiTarget is Character) {
        writeByte(1);
        writeVector2(zombie);
        writeVector2(aiTarget);
      }
    }
    writeByte(0);
  }

  void writeItems(Player player){
    writeByte(ServerResponse.Items);
    final items = player.game.items;
    for(final item in items){
      if (!item.collidable) continue;
      if (item.left < player.screenLeft) continue;
      if (item.right > player.screenRight) continue;
      if (item.top < player.screenTop) continue;
      if (item.bottom > player.screenBottom) break;
      writeByte(item.type);
      writeVector2(item);
    }
    writeByte(END);
  }

  void writePlayerZombies(Player player) {
    writeByte(ServerResponse.Zombies);
    final zombies = player.game.zombies;
    final length = zombies.length;
    final top = player.screenTop;
    final bottom = player.screenBottom;
    final left = player.screenLeft;
    final right = player.screenRight;
    final lengthMinusOne = length - 1;

    if (length == 0) {
      writeByte(END);
      return;
    }
    var start = 0;
    for (start = 0; start < lengthMinusOne; start++){
      final zombieY = zombies[start].y;
      if (zombieY > top) {
        if (zombieY > bottom){
          writeByte(END);
          return;
        }
        break;
      }
    }

    var end = start;
    for (end = start; end < lengthMinusOne; end++) {
      if (zombies[end].y > bottom) break;
    }

    for(var i = start; i <= end; i++){
      final zombie = zombies[i];
      if (zombie.dead) continue;
      if (zombie.x < left) continue;
      if (zombie.x > right) continue;
      writeCharacter(player, zombie);
    }
    writeByte(END);
  }

  void writePlayerEvents(int value){
    writeByte(ServerResponse.Player_Events);
    writeByte(value);
  }

  void writeGameEvent(Player player, int type, double x, double y, double angle){
    writeByte(ServerResponse.Game_Events);
    writeByte(type);
    writeBigInt(x);
    writeBigInt(y);
    writeBigInt(angle * radiansToDegrees);
  }

  void writeProjectiles(List<Projectile> projectiles){
    writeByte(ServerResponse.Projectiles);
    writeTotalActive(projectiles);
    projectiles.forEach(writeProjectile);
  }

  void writeGameTime(Game game){
    writeByte(ServerResponse.Game_Time);
    final totalMinutes = game.getTime() ~/ 60;
    writeByte(totalMinutes ~/ 60);
    writeByte(totalMinutes % 60);
  }

  void writeTotalActive(List<Active> values){
    var total = 0;
    for (final gameObject in values) {
      if (!gameObject.active) continue;
      total++;
    }
    writeBigInt(total);
  }

  void writeTotalAlive(List<Health> values){
    var total = 0;
    for (final gameObject in values) {
      if (gameObject.dead) continue;
      total++;
    }
    writeBigInt(total);
  }

  void writeProjectile(Projectile projectile){
    if (!projectile.active) return;
    final degrees = angle(projectile.xv, projectile.yv) * radiansToDegrees;
    writeVector2(projectile);
    writeByte(projectile.type.index);
    writeBigInt(degrees);
  }

  void writePlayers(Player player){
    writeByte(ServerResponse.Players);
    final players = player.game.players;
    for (final otherPlayer in players) {
      if (otherPlayer.dead) continue;
      writePlayer(otherPlayer);
      if (sameTeam(otherPlayer, player)){
        writeString(otherPlayer.text);
      } else {
        writeBigInt(0);
      }
    }
    writeByte(END);
  }

  void writeAttackTarget(Player player){
    final aimTarget = player.aimTarget;
    if (aimTarget == null){
      writeByte(ServerResponse.Player_Attack_Target_None);
      return;
    }
    writeByte(ServerResponse.Player_Attack_Target);
    writeVector2(aimTarget);
  }

  void writePlayer(Player player) {
    final slots = player.slots;
    writeCharacter(player, player);
    writePercentage(player.magicPercentage);
    writeByte(slots.weapon.type);
    writeByte(slots.armour.type);
    writeByte(slots.helm.type);
    writeString(player.name);
    writeBigInt(player.score);
  }
  
  void writeString(String value){
    writeBigInt(value.length);
    if (value.length == 0) return;
    final encoded = utf8.encode(value);
    for(final character in encoded){
      writeByte(character);
    }
  }

  void writeNpcs(Player player){
    final npcs = player.game.npcs;
    writeByte(ServerResponse.Npcs);
    writeTotalAlive(npcs);
    for(final npc in npcs) {
      writeNpc(player, npc);
    }
  }

  void writeNpc(Player player, Character npc) {
    if (npc.dead) return;
    writeCharacter(player, npc);
    writeByte(npc.slots.weapon.type);
  }

  void writeCharacter(Player player, Character character) {
    // final allie = sameTeam(player, character) ? 100 : 0;
    // final directionInt = character.direction * 10;
    // final stateInt = character.state;
    // final value = allie + directionInt + stateInt;
    writeByte((sameTeam(player, character) ? 100 : 0) + (character.direction * 10) + character.state); // 1
    writeVector2(character);
    writeByte((((character.health / character.maxHealth) * 24).toInt() * 10) + character.animationFrame);
  }

  List<int> _getSendBuffer() {
    final buffersLength = _buffers.length;
     for (var i = 0; i < buffersLength; i++) {
       final buff = _buffers[i];
       if (_index < buff.length){
         return buff;
       }
     }
     final newBufferLength = _index ~/ 100 * 100 + 100;
     final buffer = Uint8List(newBufferLength);
     _buffers.add(buffer);
     return buffer;
  }

  void writePercentage(double value){
    if (value.isNaN) {
      writeByte(0);
      return;
    }
    writeByte((value * 100).toInt());
  }

  void writeVector2(Vector2 value){
    writeBigInt(value.x);
    writeBigInt(value.y);
  }

  void writeBigInt(num value){
    writeNumberToByteArray(number: value, list: _buffer, index: _index);
    _index += 2;
  }

  void writeByte(int value){
    assert(value <= 256);
    assert(value >= 0);
    _buffer[_index++] = value;
  }

  void writeSlot(Slot slot){
    writeByte(slot.type);
    writeBigInt(slot.amount);
  }
}