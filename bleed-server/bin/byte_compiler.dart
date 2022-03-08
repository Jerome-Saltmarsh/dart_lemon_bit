
import 'dart:typed_data';

import 'package:lemon_math/angle.dart';

import 'classes/Character.dart';
import 'classes/GameObject.dart';
import 'classes/Player.dart';
import 'classes/Projectile.dart';
import 'common/ServerResponse.dart';
import 'common/compile_util.dart';
import 'common/constants.dart';

final byteCompiler = _ByteCompiler();

class _ByteCompiler {
  var _index = 0;
  final _buffer = Uint8List(2000);
  final List<Uint8List> _buffers = [];

  void writeByte(int value){
    assert(value <= 256);
    assert(value >= 0);
    _buffer[_index] = value;
    _index++;
  }

  void writePercentage(double value){
    writeByte((value * 100).toInt());
  }

  void writeBigInt(num value){
    compileNumber(value: value, list: _buffer, index: _index);
    _index += 3;
  }

  void writeZombies(List<Character> zombies){
    writeByte(ServerResponse.Zombies.index);
    writeTotalActive(zombies);
    for (final zombie in zombies) {
      if (!zombie.active) continue;
      writeCharacter(zombie);
    }
  }

  void writeProjectiles(List<Projectile> projectiles){
    writeByte(ServerResponse.Projectiles.index);
    writeTotalActive(projectiles);
    projectiles.forEach(writeProjectile);
  }

  void writeTotalActive(List<GameObject> values){
    var total = 0;
    for (final gameObject in values) {
      if (!gameObject.active) continue;
      total++;
    }
    writeBigInt(total);
  }

  void writeProjectile(Projectile projectile){
    if (!projectile.active) return;
    final degrees = angle(projectile.xv, projectile.yv) * radiansToDegrees;
    writeBigInt(projectile.x);
    writeBigInt(projectile.y);
    writeByte(projectile.type.index);
    writeBigInt(degrees);
  }

  void writePlayers(List<Player> players){
    writeByte(ServerResponse.Players.index);
    final total = players.length;
    writeBigInt(total);
    players.forEach(writePlayer);
  }

  void writeCharacter(Character character){
    writeByte(character.state.index);
    writeByte(character.direction);
    writeBigInt(character.x);
    writeBigInt(character.y);
    writeByte(character.animationFrame);
    writePercentage(character.health / character.maxHealth);
    writeByte(character.team);
  }

  void writePlayer(Player player) {
    writeCharacter(player);
    writePercentage(player.magic / player.maxMagic);
    writeByte(player.weapon.index);
    writeByte(player.slots.armour.index);
    writeByte(player.slots.helm.index);
  }

  void writeNpcs(List<Character> npcs){
    writeByte(ServerResponse.Npcs.index);
    writeTotalActive(npcs);
    npcs.forEach(writeNpc);
  }

  void writeNpc(Character npc) {
    if (!npc.active) return;
    writeCharacter(npc);
    writeByte(npc.weapon.index);
  }

  List<int> _getSendBuffer(){
     for (var i = 0; i < _buffers.length; i++) {
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

  List<int> writeToSendBuffer() {
    writeByte(ServerResponse.End.index);
    final sendBuffer = _getSendBuffer();
    for (var i = 0; i < _index; i++) {
      sendBuffer[i] = _buffer[i];
    }
    _index = 0;
    return sendBuffer;
  }
}