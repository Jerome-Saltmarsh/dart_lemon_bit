
import 'dart:io';
import 'dart:typed_data';

import 'package:gamestream_server/common/src/isometric/scene_part.dart';
import 'package:gamestream_server/common/src/isometric/node_type.dart';

import 'isometric_gameobject.dart';
import 'isometric_scene.dart';
import 'package:lemon_byte/byte_reader.dart';
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
      writeUInt16(gameObject.type);
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

class SceneReader extends ByteReader {

  static final decoder = ZLibDecoder();
  static final _instance = SceneReader();

  var totalZ = 0;
  var totalRows = 0;
  var totalColumns = 0;
  var nodeTypes = Uint8List(0);
  var nodeOrientations = Uint8List(0);
  var playerSpawnPoints = Uint16List(0);
  var spawnPoints = Uint16List(0);
  var gameObjects = <IsometricGameObject>[];

  static IsometricScene readScene(Uint8List bytes, {int startIndex = 0}) => _instance._readScene(bytes, startIndex: startIndex);

  IsometricScene _readScene(Uint8List bytes, {int startIndex = 0}){
    this.index = startIndex;
    this.totalColumns = 0;
    this.totalRows = 0;
    this.totalColumns = 0;
    this.nodeTypes = Uint8List(0);
    this.nodeOrientations = Uint8List(0);
    this.playerSpawnPoints = Uint16List(0);
    this.spawnPoints = Uint16List(0);
    this.gameObjects = <IsometricGameObject>[];
    this.values = bytes;
    readLoop();

    return IsometricScene(
        name: 'test',
        types: nodeTypes,
        shapes: nodeOrientations,
        height: totalZ,
        rows: totalRows,
        columns: totalColumns,
        gameObjects: gameObjects,
        spawnPoints: spawnPoints,
        spawnPointTypes: Uint16List(0),
        spawnPointsPlayers: playerSpawnPoints,
    );
  }

  void readLoop() {
    while (this.index < values.length){
      final scenePart = readByte();
      switch (scenePart){
        case ScenePart.Nodes:
          readNodes();
          break;
        case ScenePart.GameObjects:
          readGameObjects();
          break;
        case ScenePart.Player_SpawnPoints:
          readPlayerSpawnPoints();
          break;
        case ScenePart.Spawn_Points:
          readSpawnPoints();
          break;
        case ScenePart.End:
          return;
        default:
          throw Exception("could not read scene. index: $index");
      }
    }
  }

  void readGameObjects() {
    gameObjects.clear();
    var id = 0;
    final total = readUInt16();
    for (var i = 0; i < total; i++){
      final type = readUInt16();
      final x = readUInt16().toDouble();
      final y = readUInt16().toDouble();
      final z = readUInt16().toDouble();
      gameObjects.add(
        IsometricGameObject(x: x, y: y, z: z, type: type, id: id++)
      );
    }
  }

  void readPlayerSpawnPoints() {
    final playerSpawnPointLength = readUInt16();
    playerSpawnPoints = readUint16List(playerSpawnPointLength);
  }

  void readSpawnPoints(){
    final length = readUInt16();
    spawnPoints = readUint16List(length);
  }

  void readNodes() {
    totalZ = readUInt16();
    totalRows = readUInt16();
    totalColumns = readUInt16();
    final compressedNodeTypeLength = readUInt24();
    final compressedNodeOrientationLength = readUInt24();
    final compressedNodeTypes = readUint8List(compressedNodeTypeLength);
    final compressedNodeOrientations = readUint8List(
        compressedNodeOrientationLength);
    nodeTypes = Uint8List.fromList(decoder.convert(compressedNodeTypes));
    nodeOrientations = Uint8List.fromList(decoder.convert(compressedNodeOrientations));
  }

    // void writeUDouble16(double value) {
    //     writeUInt16(value.toInt());
    //   }

}