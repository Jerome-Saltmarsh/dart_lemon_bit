import 'dart:typed_data';

import 'package:bleed_server/gamestream.dart';
import 'package:lemon_byte/byte_writer.dart';

class GameScript extends ByteWriter {
  var timer = 0;
  var script = Uint8List(0);

  void writeDeactivate(int target){
    writeUInt8(ScriptType.Action_Deactivate);
    writeUInt8(target);
  }

  void writeSpawnGameObject({
    required int type,
    required double x,
    required double y,
    required double z,
  }){
    writeUInt8(ScriptType.Spawn_GameObject);
    writeUInt16(type);
    writeUInt16(x.toInt());
    writeUInt16(y.toInt());
    writeUInt16(z.toInt());
  }
}
