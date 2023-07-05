import 'dart:io';
import 'dart:typed_data';

import 'package:gamestream_server/common/src/isometric/scene_part.dart';
import 'package:lemon_byte/byte_reader.dart';

import 'isometric_gameobject.dart';
import 'isometric_scene.dart';

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

  static IsometricScene readScene(Uint8List bytes, {int startIndex = 0}) =>
      _instance._readScene(bytes, startIndex: startIndex);

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
      final type = readByte();
      final subType = readByte();
      final team = readByte();
      final x = readUInt16().toDouble();
      final y = readUInt16().toDouble();
      final z = readUInt16().toDouble();
      gameObjects.add(
          IsometricGameObject(
            x: x,
            y: y,
            z: z,
            type: type,
            subType: subType,
            id: id++,
            team: team, // TODO READ FROM FILE
          )
            ..fixed = true
            ..persistable = true
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