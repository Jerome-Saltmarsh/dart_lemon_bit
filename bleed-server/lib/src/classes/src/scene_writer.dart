
import 'dart:io';
import 'dart:typed_data';

import 'package:bleed_server/gamestream.dart';
import 'package:lemon_byte/byte_reader.dart';
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
    final compressedNodeTypes = encoder.convert(scene.nodeTypes);
    final compressedNodeOrientations = encoder.convert(scene.nodeOrientations);
    assert (!compressedNodeTypes.any((element) => element > 256));
    assert (!compressedNodeTypes.any((element) => element < 0));
    writeByte(ScenePart.Nodes);
    writeUInt16(scene.gridHeight);
    writeUInt16(scene.gridRows);
    writeUInt16(scene.gridColumns);
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
      writeUInt16(gameObject.type);
      writeUDouble16(gameObject.startX);
      writeUDouble16(gameObject.startY);
      writeUDouble16(gameObject.startZ);
    }
  }

  void writePlayerSpawnPoints(Scene scene) {
    writeByte(ScenePart.Player_SpawnPoints);
    List<int> values = [];
     for (var i = 0; i < scene.gridVolume; i++){
        if (scene.nodeTypes[i] != NodeType.Spawn_Player) continue;
        values.add(i);
     }
     writeUInt16(values.length);
     writeUint16List(values);
  }

  void writeSpawnPoints(Scene scene){
    scene.detectSpawnPoints();

    writeByte(ScenePart.Spawn_Points);
    writeUInt16(scene.spawnPoints.length);
    writeUint16List(scene.spawnPoints);
  }

  Uint8List _compileScene(Scene scene, {required bool gameObjects}){
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
  var gameObjects = <GameObject>[];

  static Scene readScene(Uint8List bytes, {int startIndex = 0}) => _instance._readScene(bytes, startIndex: startIndex);

  Scene _readScene(Uint8List bytes, {int startIndex = 0}){
    this.index = startIndex;
    this.totalColumns = 0;
    this.totalRows = 0;
    this.totalColumns = 0;
    this.nodeTypes = Uint8List(0);
    this.nodeOrientations = Uint8List(0);
    this.playerSpawnPoints = Uint16List(0);
    this.spawnPoints = Uint16List(0);
    this.gameObjects = <GameObject>[];
    this.values = bytes;
    readLoop();

    return Scene(
        name: 'test',
        nodeTypes: nodeTypes,
        nodeOrientations: nodeOrientations,
        gridHeight: totalZ,
        gridRows: totalRows,
        gridColumns: totalColumns,
        gameObjects: gameObjects,
        spawnPoints: spawnPoints,
        spawnPointTypes: Uint16List(0),
        spawnPointsPlayers: playerSpawnPoints,
    );
  }

  void readLoop() {
    while (this.index < values.length){
      switch (readByte()){
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
          throw Exception("could not read scene");
      }
    }
  }

  void readGameObjects() {
    gameObjects.clear();
    var id = 0;
    final total = readUInt16();
    for (var i = 0; i < total; i++){
      final type = readUInt16();
      final x = readUDouble16();
      final y = readUDouble16();
      final z = readUDouble16();
      gameObjects.add(
        GameObject(x: x, y: y, z: z, type: type, id: id++)
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
}