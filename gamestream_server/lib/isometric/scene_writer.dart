
import 'dart:io';
import 'dart:typed_data';

import 'package:gamestream_server/lemon_bits.dart';
import 'package:gamestream_server/common.dart';

import 'gameobject.dart';
import 'scene.dart';
import 'package:lemon_byte/byte_writer.dart';

class SceneWriter extends ByteWriter {

  static final _instance = SceneWriter();
  final encoder = ZLibEncoder(
            level: ZLibOption.minLevel,
            memLevel: ZLibOption.minMemLevel,
            strategy: ZLibOption.strategyFixed,
        );

  static Uint8List compileScene(Scene scene, {required bool gameObjects}){
    return _instance._compileScene(scene, gameObjects: gameObjects);
  }

  void writeNodes(Scene scene){
    final compressedNodeTypes = encoder.convert(scene.types);
    final compressedNodeOrientations = encoder.convert(scene.shapes);
    assert (!compressedNodeTypes.any((element) => element > 256));
    assert (!compressedNodeTypes.any((element) => element < 0));
    writeByte(ScenePart.Nodes);
    writeUInt16(scene.height);
    writeUInt16(scene.rows);
    writeUInt16(scene.columns);
    writeUInt24(compressedNodeTypes.length);
    writeUInt24(compressedNodeOrientations.length);
    writeUint8List(compressedNodeTypes);
    writeUint8List(compressedNodeOrientations);
  }

  void writeGameObjects(List<GameObject> gameObjects){
    writeByte(ScenePart.GameObjects);
    var total = 0;
    for (final gameObject in gameObjects){
       if (!gameObject.persistable) continue;
       total++;
    }
    writeUInt16(total);
    for (final gameObject in gameObjects){
      if (!gameObject.persistable) continue;
      writeByte(gameObject.type);
      writeByte(gameObject.subType);
      writeByte(gameObject.team);

      writeByte(writeBitsToByte(
          gameObject.collidable,
          gameObject.collectable,
          gameObject.fixed,
          gameObject.gravity,
          gameObject.hitable,
          gameObject.physical,
          gameObject.interactable,
          gameObject.destroyable,
      ));

      writeUInt16(gameObject.startX.toInt());
      writeUInt16(gameObject.startY.toInt());
      writeUInt16(gameObject.startZ.toInt());
    }
  }

  void writeMarks(Scene scene){
    writeByte(ScenePart.Marks);
    writeUInt16(scene.marks.length);
    writeUint32List(scene.marks);
  }

  Uint8List _compileScene(Scene scene, {required bool gameObjects}){
    clear();
    writeNodes(scene);
    writeMarks(scene);
    if (gameObjects) {
      // writePlayerSpawnPoints(scene);
      writeGameObjects(scene.gameObjects);
      // writeSpawnPoints(scene);
      writeByte(ScenePart.End);
    }
    return compile();
  }
}

