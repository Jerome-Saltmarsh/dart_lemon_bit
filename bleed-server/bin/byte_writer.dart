
import 'dart:convert' show utf8;
import 'dart:typed_data';

import 'package:lemon_math/library.dart';

import 'classes/library.dart';
import 'common/library.dart';

class ByteWriter {
  var _index = 0;
  final _buffer = Uint8List(50000); // 100kb
  final _buffers = <int, Uint8List>{};

  List<int> writeToSendBuffer() {
    writeByte(ServerResponse.End);
    final sendBuffer = _getSendBuffer();
    for (var i = 0; i < _index; i++) {
      sendBuffer[i] = _buffer[i];
    }
    _index = 0;
    return sendBuffer;
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
      writeInt(pathIndex + 1);
      for (var i = pathIndex; i >= 0; i--) {
        writeInt(zombie.pathX[i]);
        writeInt(zombie.pathY[i]);
      }
    }
    writeInt(250);

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

  void writePlayerEvent(int value){
    writeByte(ServerResponse.Player_Events);
    writeByte(value);
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
    writeInt(total);
  }

  void writeTotalAlive(List<Health> values){
    var total = 0;
    for (final gameObject in values) {
      if (gameObject.dead) continue;
      total++;
    }
    writeInt(total);
  }

  void writeProjectile(Projectile projectile){
    if (!projectile.active) return;
    final degrees = getAngle(projectile.xv, projectile.yv) * radiansToDegrees;
    writePosition(projectile);
    writeByte(projectile.type);
    writeInt(degrees);
  }

  void writeDamageApplied(Position target, int amount) {
    if (amount <= 0) return;
    writeByte(ServerResponse.Damage_Applied);
    writePosition(target);
    writeInt(amount);
  }

  void writePlayer(Player player) {
    writeCharacter(player, player);
    writePercentage(player.magicPercentage);
    writeByte(player.equipped);
    writeByte(SlotType.Empty); // armour
    writeByte(SlotType.Empty); // helm
    writeString(player.name);
    writeInt(player.score);
  }
  
  void writeString(String value){
    writeInt(value.length);
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
    final bufferIndex = _index ~/ 100;
    final buffer = _buffers[bufferIndex];
    if (buffer != null) return buffer;
    final newBufferLength = (bufferIndex + 1) * 100;
    final newBuffer = Uint8List(newBufferLength);
    _buffers[bufferIndex] = newBuffer;
    return newBuffer;
  }

  void writePercentage(double value){
    if (value.isNaN) {
      writeByte(0);
      return;
    }
    writeByte((value * 100).toInt());
  }

  void writeVector2(Vector2 value){
    writeInt(value.x);
    writeInt(value.y);
  }

  void writePosition(Position value){
    writeInt(value.x);
    writeInt(value.y);
  }

  void writeInt(num value){
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
    writeInt(slot.amount);
  }
}