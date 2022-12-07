
import 'dart:typed_data';

import 'package:bleed_server/gamestream.dart';
import 'package:lemon_byte/byte_reader.dart';
import 'package:lemon_byte/byte_writer.dart';

class SceneWriter extends ByteWriter {

  static final _instance = SceneWriter();

  static Uint8List compileScene(Scene scene){
    return _instance._compileScene(scene);
  }

  Uint8List _compileScene(Scene scene){
    resetIndex();
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
    return compile();
  }
}

class SceneReader extends ByteReader {

  static final _instance = SceneReader();

  static Scene readScene(List<int> bytes) => _instance._readScene(bytes);

  Scene _readScene(List<int> bytes){
    // copyBytes(bytes);
    this.index = 0;
    this.values = bytes;
    final totalZ = readUInt16();
    final totalRows = readUInt16();
    final totalColumns = readUInt16();
    final nodesArea = totalRows * totalColumns;
    final totalNodes = totalZ * nodesArea;
    final nodeTypes = Uint8List(totalNodes);
    final nodeOrientations = Uint8List(totalNodes);

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

    return Scene(
        name: 'test',
        nodeTypes: nodeTypes,
        nodeOrientations: nodeOrientations,
        gridHeight: totalZ,
        gridRows: totalRows,
        gridColumns: totalColumns,
        gameObjects: [],
        spawnPoints: Uint16List(0),
        spawnPointTypes: Uint16List(0),
        spawnPointsPlayers: Uint16List(0),
    );
  }
}