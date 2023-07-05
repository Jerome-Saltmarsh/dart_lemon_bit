
import 'dart:io';
import 'dart:typed_data';

import 'package:gamestream_server/common/src/isometric/scene_part.dart';
import 'package:gamestream_server/common/src/isometric/node_type.dart';
import 'package:gamestream_server/utils/byte_utils.dart';

import 'isometric_gameobject.dart';
import 'isometric_scene.dart';
import 'package:lemon_byte/byte_writer.dart';

class IsometricSceneWriter extends ByteWriter {

  static final _instance = IsometricSceneWriter();
  final encoder = ZLibEncoder(
            level: ZLibOption.minLevel,
            memLevel: ZLibOption.minMemLevel,
            strategy: ZLibOption.strategyFixed,
        );

  static Uint8List compileScene(IsometricScene scene, {required bool gameObjects}){
    return _instance._compileScene(scene, gameObjects: gameObjects);
  }

  void writeNodes(IsometricScene scene){
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

  void writeGameObjects(List<IsometricGameObject> gameObjects){
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

  void writePlayerSpawnPoints(IsometricScene scene) {
    writeByte(ScenePart.Player_SpawnPoints);
    List<int> values = [];
     for (var i = 0; i < scene.volume; i++){
        if (scene.types[i] != NodeType.Spawn_Player) continue;
        values.add(i);
     }
     writeUInt16(values.length);
     writeUint16List(values);
  }

  void writeSpawnPoints(IsometricScene scene){
    scene.detectSpawnPoints();

    writeByte(ScenePart.Spawn_Points);
    writeUInt16(scene.spawnPoints.length);
    writeUint16List(scene.spawnPoints);
  }

  Uint8List _compileScene(IsometricScene scene, {required bool gameObjects}){
    clear();
    writeNodes(scene);
    if (gameObjects) {
      writePlayerSpawnPoints(scene);
      writeGameObjects(scene.gameObjects);
      writeSpawnPoints(scene);
      writeByte(ScenePart.End);
    }
    return compile();
  }
}

