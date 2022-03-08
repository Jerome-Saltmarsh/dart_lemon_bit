
import 'dart:typed_data';

import 'classes/Character.dart';
import 'classes/Player.dart';
import 'common/ServerResponse.dart';
import 'common/compile_util.dart';

final byteCompiler = _ByteCompiler();

class _ByteCompiler {
  var _index = 0;

  final _buffer = Int8List(2000);
  final List<Int8List> _buffers = [];

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
    var total = 0;
    for (final zombie in zombies) {
      if (zombie.active) total++;
    }
    writeBigInt(total);
    for (final zombie in zombies) {
      if (!zombie.active) continue;
      writeCharacter(zombie);
    }
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

  List<int> _getSendBuffer(){
     for (var i = 0; i < _buffers.length; i++) {
       final buff = _buffers[i];
       if (_index < buff.length){
         return buff;
       }
     }
     final newBufferLength = _index ~/ 100 * 100 + 100;
     final buffer = Int8List(newBufferLength);
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