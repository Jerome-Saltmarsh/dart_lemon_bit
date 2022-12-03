import 'dart:typed_data';

import 'package:bleed_server/gamestream.dart';
import 'package:lemon_byte/byte_writer.dart';

late AI pathFindAI;
var pathFindSearchID = 0;

final writer = ByteWriter();

class Scene {
  late Uint8List nodeTypes;
  late Uint8List nodeOrientations;

  var gridHeight = 0;
  var gridRows = 0;
  var gridColumns = 0;
  var gridVolume = 0;
  var gridArea = 0;
  var name = "";
  var dirty = false;
  final List<GameObject> gameObjects;

  Uint16List spawnPoints;
  Uint16List spawnPointTypes;

  late double gridRowLength;
  late double gridColumnLength;
  late double gridHeightLength;

  int get columnsPerRow => gridRows;
  int get rowsPerZ => gridColumns;

  Scene({
    required this.name,
    required this.nodeTypes,
    required this.nodeOrientations,
    required this.gridHeight,
    required this.gridRows,
    required this.gridColumns,
    required this.gameObjects,
    required this.spawnPoints,
    required this.spawnPointTypes,
  }) {
    assert (spawnPoints.length == spawnPointTypes.length);
    refreshGridMetrics();
  }

  void refreshGridMetrics(){
    gridArea = gridRows * gridColumns;
    gridVolume = gridHeight * gridArea;
    gridRowLength = gridRows * Node_Size;
    gridColumnLength = gridColumns * Node_Size;
    gridHeightLength = gridHeight * Node_Height;
  }

  int getGridType(int z, int row, int column) =>
      outOfBounds(z, row, column)
          ? NodeType.Boundary
          : nodeTypes[getNodeIndex(z, row, column)];

  int getGridOrientation(int z, int row, int column) =>
      outOfBounds(z, row, column)
          ? NodeType.Boundary
          : nodeOrientations[getNodeIndex(z, row, column)];


  int getNodeIndex(int z, int row, int column) {
    assert (!outOfBounds(z, row, column));
    return (z * gridArea) + (row * gridColumns) + column;
  }

  bool outOfBounds(int z, int row, int column){
     if (z < 0) return true;
     if (row < 0) return true;
     if (column < 0) return true;
     if (z >= gridHeight) return true;
     if (row >= gridRows) return true;
     if (column >= gridColumns) return true;
     return false;
  }

  void setNode(int z, int row, int column, int type, int orientation) {
    if (outOfBounds(z, row, column)) return;
    final index = getNodeIndex(z, row, column);
    final currentType = nodeTypes[index];
    final currentOrientation = nodeOrientations[index];
    if (currentType == type && currentOrientation == orientation) {
      return;
    }
    dirty = true;
    nodeTypes[index] = type;
    nodeOrientations[index] = orientation;
  }

  int getNodeTypeXYZ(double x, double y, double z) =>
      getNodeInBoundsXYZ(x, y, z)
          ? nodeTypes[getNodeIndexXYZ(x, y, z)]
          : NodeType.Boundary;

  int getNodeIndexXYZ(double x, double y, double z) =>
    getNodeIndex(
        z ~/ Node_Size_Half,
        x ~/ Node_Size,
        y ~/ Node_Size,
    );

  int getNodeOrientationXYZ(double x, double y, double z){
     if (x < 0) return NodeOrientation.Solid;
     if (y < 0) return NodeOrientation.Solid;
     if (x >= gridRowLength) return NodeOrientation.Solid;
     if (y >= gridColumnLength) return NodeOrientation.Solid;
     if (z >= gridHeightLength) return NodeOrientation.None;
     if (z < 0) return NodeOrientation.None;

     if (getNodeIndexXYZ(x, y, z) >= nodeOrientations.length) {
       throw Exception();
     }

     return nodeOrientations[getNodeIndexXYZ(x, y, z)];
  }

  bool getNodeInBoundsXYZ(double x, double y, double z) =>
    z >= 0 &&
    x >= 0 &&
    y >= 0 &&
    z < gridHeightLength &&
    x < gridRowLength &&
    y < gridColumnLength;

  bool getCollisionAt(double x, double y, double z) {
     if (x < 0) return true;
     if (y < 0) return true;
     if (x >= gridRowLength) return true;
     if (y >= gridColumnLength) return true;
     if (z >= gridHeightLength) return false;
     if (z < 0) return false;

     final orientation = getNodeOrientationXYZ(x, y, z);
     if (orientation == NodeOrientation.None) return false;
     if (orientation == NodeOrientation.Solid) return true;
     final percX = ((x % Node_Size) / Node_Size);
     final percY = ((y % Node_Size) / Node_Size);
     return ((z ~/ Node_Height) * Node_Height)
         + (NodeOrientation.getGradient(orientation, percX, percY) * Node_Height)
         >= z;
  }

  double convertNodeIndexToZPosition(int index) =>
      convertNodeIndexToZ(index) * Node_Height;

  double convertNodeIndexToYPosition(int index) =>
      convertNodeIndexToColumn(index) * Node_Size;

  double convertNodeIndexToXPosition(int index) =>
      convertNodeIndexToRow(index) * Node_Size;

  int convertNodeIndexToRow(int index) =>
      (index - (convertNodeIndexToZ(index) * gridArea)) ~/ gridColumns;

  int convertNodeIndexToColumn(int index) =>
      index - ((convertNodeIndexToZ(index) * gridArea) + (convertNodeIndexToRow(index) * gridColumns));

  int convertNodeIndexToZ(int index) => index ~/ gridArea;

  /// Warning Expensive, (Do not call during runtime)
  void refreshSpawnPoints() {
    final newSpawnPoints = <int>[];
    for (var i = 0; i < nodeTypes.length; i++){
      if (nodeTypes[i] != NodeType.Spawn) continue;
      newSpawnPoints.add(i);
    }
    if (spawnPoints.length != newSpawnPoints){
      spawnPoints = Uint16List(newSpawnPoints.length);
    }
    for (var i = 0; i < spawnPoints.length; i++){
       spawnPoints[i] = newSpawnPoints[i];
    }
  }

  Uint8List compile(){
      writer.writeInt(gridHeight);
      writer.writeInt(gridRows);
      writer.writeInt(gridColumns);
      var previousType = nodeTypes[0];
      var previousOrientation = nodeOrientations[0];
      var count = 0;
      for (var z = 0; z < gridHeight; z++){
        for (var row = 0; row < gridRows; row++){
          for (var column = 0; column < gridColumns; column++) {
            final nodeIndex = getNodeIndex(z, row, column);
            final nodeType = nodeTypes[nodeIndex];
            final nodeOrientation = nodeOrientations[nodeIndex];

            if (nodeType == previousType && nodeOrientation == previousOrientation){
              count++;
            } else {
              writer.writeByte(previousType);
              writer.writeByte(previousOrientation);
              writer.writeUInt16(count);
              previousType = nodeType;
              previousOrientation = nodeOrientation;
              count = 1;
            }
          }
        }
      }
      writer.writeByte(previousType);
      writer.writeByte(previousOrientation);
      writer.writeUInt16(count);
      return writer.writeToSendBuffer();
  }
}
