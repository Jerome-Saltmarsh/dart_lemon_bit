
import 'dart:typed_data';

import 'classes/Character.dart';
import 'common/ServerResponse.dart';
import 'common/compile_util.dart';

final byteCompiler = _ByteCompiler();

class _ByteCompiler {
  final _buffer = Int8List(1000);

  final List<Int8List> buffers = [];

  _ByteCompiler(){
    for (int i = 0; i < 10; i++) {
      buffers.add(Int8List(i * 100));
    }
  }

  var _index = 0;

  void writeByte(int value){
    assert(value <= 256);
    _buffer[_index] = value;
    _index++;
  }

  void writePercentage(double value){
    writeByte((value * 100).toInt());
  }

  void writeBigInt(num value){
    assert(value <= 65536);
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
      writeZombie(zombie);
    }
  }

  void writeZombie(Character zombie){
    writeByte(zombie.state.index);
    writeByte(zombie.direction);
    writeBigInt(zombie.x);
    writeBigInt(zombie.y);
    writeByte(zombie.animationFrame);
    writePercentage(zombie.health / zombie.maxHealth);
    writeByte(zombie.team);
  }

  List<int> _getSendBuffer(){
     for (var i = 0; i < buffers.length; i++) {
       final buff = buffers[i];
       if (_index < buff.length){
         return buff;
       }
     }
     final newBufferLength = _index ~/ 100 * 100 + 100;
     final buffer = Int8List(newBufferLength);
     buffers.add(buffer);
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