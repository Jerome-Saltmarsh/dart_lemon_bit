
import 'dart:convert' show utf8;
import 'dart:typed_data';

import 'package:lemon_math/library.dart';

import 'classes/library.dart';
import 'common/library.dart';

class ByteWriter {
  var _index = 0;
  final _buffer = Uint8List(50000); // 100kb
  final _buffers = <Uint8List>[];

  List<int> writeToSendBuffer() {
    writeByte(ServerResponse.End);
    final sendBuffer = _getSendBuffer();
    for (var i = 0; i < _index; i++) {
      sendBuffer[i] = _buffer[i];
    }
    _index = 0;
    return sendBuffer;
  }

  void writePlayerSlots(Player player) {
    writeByte(ServerResponse.Player_Slots);
    // final slots = player.slots;
    // writeSlot(slots.slot1); // 3
    // writeSlot(slots.slot2); // 3
    // writeSlot(slots.slot3); // 3
    // writeSlot(slots.slot4); // 3
    // writeSlot(slots.slot5); // 3
    // writeSlot(slots.slot6); // 3
  }

  void writeTechTypes(Player player){
    writeByte(ServerResponse.Tech_Types);
    writeByte(player.techTree.pickaxe);
    writeByte(player.techTree.sword);
    writeByte(player.techTree.bow);
  }

  void writeDynamicObjects(Player player) {
     writeByte(ServerResponse.Dynamic_Objects);
     final dynamicObjects = player.game.scene.dynamicObjects;
     for (final dynamicObject in dynamicObjects) {
       if (dynamicObject.dead) continue;
       if (dynamicObject.x < player.screenLeft) continue;
       if (dynamicObject.x > player.screenRight) continue;
       if (dynamicObject.y < player.screenTop) continue;
       if (dynamicObject.y > player.screenBottom) break;
       writeByte(dynamicObject.type);
       writePosition(dynamicObject);
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
        writePosition(zombie);
        writePosition(aiTarget);
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
      writePosition(item);
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
    final degrees = getAngle(projectile.xv, projectile.yv) * radiansToDegrees;
    writePosition(projectile);
    writeByte(projectile.type);
    writeBigInt(degrees);
  }

  void writeDamageApplied(Position target, int amount) {
    if (amount <= 0) return;
    writeByte(ServerResponse.Damage_Applied);
    writePosition(target);
    writeBigInt(amount);
  }

  void writePlayer(Player player) {
    writeCharacter(player, player);
    writePercentage(player.magicPercentage);
    writeByte(player.equipped);
    writeByte(SlotType.Empty); // armour
    writeByte(SlotType.Empty); // helm
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
    writeByte(npc.equipped);
  }

  void writeCharacter(Player player, Character character) {
    writeByte((sameTeam(player, character) ? 100 : 0) + (character.direction * 10) + character.state); // 1
    writePosition(character);
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

  void writePosition(Position value){
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