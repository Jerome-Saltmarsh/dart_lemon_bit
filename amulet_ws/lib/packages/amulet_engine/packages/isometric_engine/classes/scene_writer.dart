
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../isometric_engine.dart';

class SceneWriter extends ByteWriter {

  final encoder = ZLibEncoder();

  Uint8List compileScene(Scene scene, {required bool gameObjects}){
    clear();
    writeNodes(scene);
    writeMarks(scene);
    writeKeys(scene.keys);

    if (scene.variations.length != scene.types.length){
      scene.variations = Uint8List(scene.types.length);
    }

    writeVariations(scene);
    if (gameObjects) {
      writeGameObjects(scene.gameObjects);
      writeByte(ScenePart.End);
    }
    return compile();
  }


  void writeNodes(Scene scene){
    scene.removeUnusedNodes();

    final compressedNodeTypes = encoder.encode(scene.types);
    final compressedNodeOrientations = encoder.encode(scene.shapes);
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

      writeByte(writeBits(
          gameObject.collidable,
          gameObject.collectable,
          gameObject.fixed,
          gameObject.gravity,
          gameObject.hitable,
          gameObject.physical,
          gameObject.interactable,
          gameObject.destroyable,
      ));

      writeUInt16(gameObject.startPositionX.toInt());
      writeUInt16(gameObject.startPositionY.toInt());
      writeUInt16(gameObject.startPositionZ.toInt());
    }
  }

  void writeMarks(Scene scene){
    writeByte(ScenePart.Marks);
    writeUInt16(scene.marks.length);
    writeUint32List(scene.marks);
  }

  void writeKeys(Map<String, int> keys){
    final length = keys.length;
    writeByte(ScenePart.Keys);
    writeUInt16(length);
    final entries = keys.entries;
    for (final entry in entries){
      writeString(entry.key);
      writeUInt16(entry.value);
    }
  }

  void writeVariations(Scene scene) {
    writeByte(ScenePart.Variations);
    compressAndWrite(scene.variations);
  }

  void compressAndWrite(Uint8List values){
    final compressedValues = encoder.encode(values);
    writeUInt24(compressedValues.length);
    writeUint8List(compressedValues);
  }
}

