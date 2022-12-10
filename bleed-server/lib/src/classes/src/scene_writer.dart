
import 'dart:typed_data';

import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/lang_utils.dart';
import 'package:lemon_byte/byte_reader.dart';
import 'package:lemon_byte/byte_writer.dart';

class SceneWriter extends ByteWriter {

  static final _instance = SceneWriter();

  static Uint8List compileScene(Scene scene, {required bool gameObjects}){
    return _instance._compileScene(scene, gameObjects: gameObjects);
  }

  void writeNodes(Scene scene){
    writeByte(ScenePart.Nodes);
    writeUInt16(scene.gridHeight);
    writeUInt16(scene.gridRows);
    writeUInt16(scene.gridColumns);
    var previousType = scene.nodeTypes[0];
    var previousOrientation = scene.nodeOrientations[0];
    var count = 0;
    final nodeTypes = scene.nodeTypes;
    final nodeOrientations = scene.nodeOrientations;
    for (var nodeIndex = 0; nodeIndex < scene.gridVolume; nodeIndex++) {
      final nodeType = nodeTypes[nodeIndex];
      final nodeOrientation = nodeOrientations[nodeIndex];
      if (nodeType == previousType && nodeOrientation == previousOrientation){
        count++;
      } else {
        writeByte(previousType);
        writeByte(previousOrientation);
        writeUInt16(count);
        previousType = nodeType;
        previousOrientation = nodeOrientation;
        count = 1;
      }
    }
    writeByte(previousType);
    writeByte(previousOrientation);
    writeUInt16(count);
  }

  void writeGameObjects(Scene scene){
    writeByte(ScenePart.GameObjects);
    var total = 0;
    for (final gameObject in scene.gameObjects){
       if (!ItemType.isPersistable(gameObject.type)) continue;
       total++;
    }
    writeUInt16(total);
    for (final gameObject in scene.gameObjects){
      if (!ItemType.isPersistable(gameObject.type)) continue;
      writeUInt16(gameObject.type);
      writeUDouble16(gameObject.x);
      writeUDouble16(gameObject.y);
      writeUDouble16(gameObject.z);
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
     writeUInt16s(values);
  }

  void writeSpawnPoints(Scene scene){
    scene.detectSpawnPoints();

    writeByte(ScenePart.Spawn_Points);
    writeUInt16(scene.spawnPoints.length);
    writeUInt16s(scene.spawnPoints);
  }



  Uint8List _compileScene(Scene scene, {required bool gameObjects}){
    resetIndex();
    writeNodes(scene);
    if (gameObjects){
      writePlayerSpawnPoints(scene);
      writeGameObjects(scene);
      writeSpawnPoints(scene);
    }
    return compile();
  }
}

class SceneReader extends ByteReader {

  static final _instance = SceneReader();

  var totalZ = 0;
  var totalRows = 0;
  var totalColumns = 0;
  var nodeTypes = Uint8List(0);
  var nodeOrientations = Uint8List(0);
  var playerSpawnPoints = Uint16List(0);
  var spawnPoints = Uint16List(0);
  var gameObjects = <GameObject>[];

  static Scene readScene(List<int> bytes) => _instance._readScene(bytes);

  Scene _readScene(List<int> bytes){
    this.index = 0;
    this.totalColumns = 0;
    this.totalRows = 0;
    this.totalColumns = 0;
    this.nodeTypes = Uint8List(0);
    this.nodeOrientations = Uint8List(0);
    this.playerSpawnPoints = Uint16List(0);
    this.spawnPoints = Uint16List(0);
    this.gameObjects = <GameObject>[];
    this.values = bytes;

    while (this.index < bytes.length){
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
        default:
          throw Exception("could not read scene");
      }
    }

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

  void readGameObjects() {
    gameObjects.clear();
    final total = readUInt16();
    for (var i = 0; i < total; i++){
      final type = readUInt16();
      final x = readUDouble16();
      final y = readUDouble16();
      final z = readUDouble16();
      gameObjects.add(
        GameObject(x: x, y: y, z: z, type: type)
      );
    }
  }

  void readPlayerSpawnPoints() {
    final playerSpawnPointLength = readUInt16();
    playerSpawnPoints = readUInt16s(playerSpawnPointLength);
  }

  void readSpawnPoints(){
    final length = readUInt16();
    spawnPoints = readUInt16s(length);
  }

  void readNodes(){
    totalZ = readUInt16();
    totalRows = readUInt16();
    totalColumns = readUInt16();
    final nodesArea = totalRows * totalColumns;
    final totalNodes = totalZ * nodesArea;
    nodeTypes = Uint8List(totalNodes);
    nodeOrientations = Uint8List(totalNodes);

    var gridIndex = 0;
    var total = 0;
    var currentRow = 0;
    var currentColumn = 0;

    while (total < totalNodes) {
      final nodeType = readByte();
      final nodeOrientation = readByte();
      var count = readUInt16();
      total += count;

      while (count > 0) {
        nodeTypes[gridIndex] = nodeType;
        nodeOrientations[gridIndex] = nodeOrientation;

        gridIndex++;
        count--;
        currentColumn++;
        if (currentColumn >= totalColumns) {
          currentColumn = 0;
          currentRow++;
          if (currentRow >= totalRows) {
            currentRow = 0;
          }
        }
      }
    }
  }
}