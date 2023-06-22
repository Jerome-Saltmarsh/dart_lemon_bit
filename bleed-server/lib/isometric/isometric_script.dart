import 'package:lemon_byte/byte_writer.dart';

import 'isometric_gameobject.dart';
import 'isometric_script_type.dart';

class IsometricScript extends ByteWriter {
  var timer = 0;

  void writeGameObjectDeactivate(IsometricGameObject gameObject){
    writeUInt8(IsometricScriptType.GameObject_Deactivate);
    writeUInt16(gameObject.id);
  }

  void writeSpawnGameObject({
    required int type,
    required double x,
    required double y,
    required double z,
  }){
    writeUInt8(IsometricScriptType.Spawn_GameObject);
    writeUInt16(type);
    writeUInt16(x.toInt());
    writeUInt16(y.toInt());
    writeUInt16(z.toInt());
  }

  void writeSpawnAI({
    required int type,
    required double x,
    required double y,
    required double z,
    required int team,
  }){
    writeUInt8(IsometricScriptType.Spawn_AI);
    writeUInt16(type);
    writeUInt16(x.toInt());
    writeUInt16(y.toInt());
    writeUInt16(z.toInt());
    writeUInt8(team);
  }
}
