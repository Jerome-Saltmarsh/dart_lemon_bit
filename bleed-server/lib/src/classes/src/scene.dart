import 'dart:typed_data';

import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/games/isometric/isometric_ai.dart';
import 'package:bleed_server/src/games/isometric/isometric_gameobject.dart';
import 'package:bleed_server/src/lang_utils.dart';
import 'package:lemon_math/library.dart';

late IsometricAI pathFindAI;
var pathFindSearchID = 0;

class Scene {
  late Uint8List nodeTypes;
  late Uint8List nodeOrientations;
  Uint8List? compiled;

  var gridHeight = 0;
  var gridRows = 0;
  var gridColumns = 0;
  var gridVolume = 0;
  var gridArea = 0;
  var name = "";
  final List<IsometricGameObject> gameObjects;

  Uint16List spawnPoints;
  Uint16List spawnPointsPlayers;
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
    required this.spawnPointsPlayers,
  }) {
    // assert (spawnPoints.length == spawnPointTypes.length);
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

  bool inboundsV3(Position3 v3) => inboundsXYZ(v3.x, v3.y, v3.z);

  bool inboundsXYZ(double x, double y, double z) =>
      x >= 0                &&
      y >= 0                &&
      z >= 0                &&
      x < gridRowLength     &&
      y < gridColumnLength  &&
      z < gridHeightLength   ;

  void setNode(int z, int row, int column, int type, int orientation) {
    if (outOfBounds(z, row, column)) return;
    final index = getNodeIndex(z, row, column);
    final currentType = nodeTypes[index];
    final currentOrientation = nodeOrientations[index];
    if (currentType == type && currentOrientation == orientation) {
      return;
    }
    nodeTypes[index] = type;
    nodeOrientations[index] = orientation;
  }

  int getNodeTypeXYZ(double x, double y, double z) =>
      isInboundXYZ(x, y, z)
          ? nodeTypes[getNodeIndexXYZ(x, y, z)]
          : NodeType.Boundary;

  int getNodeIndexV3(Position3 position3) =>
      getNodeIndexXYZ(
        position3.x,
        position3.y,
        position3.z,
      );

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

  bool isInboundV3(Position3 pos ) =>
    isInboundXYZ(pos.x, pos.y, pos.z);

  bool isInboundXYZ(double x, double y, double z) =>
    z >= 0 &&
    x >= 0 &&
    y >= 0 &&
    z < gridHeightLength &&
    x < gridRowLength &&
    y < gridColumnLength;

  bool getCollisionAt(double x, double y, double z) {
    final orientation = getNodeOrientationXYZ(x, y, z);
    if (orientation == NodeOrientation.None) return false;
    if (orientation == NodeOrientation.Solid) return true;
    final percX = ((x % Node_Size) / Node_Size);
    final percY = ((y % Node_Size) / Node_Size);
    return ((z ~/ Node_Height) * Node_Height)
        + (NodeOrientation.getGradient(orientation, percX, percY) * Node_Height)
        >= z;
  }

  double convertNodeIndexToPositionZ(int index) =>
      convertNodeIndexToZ(index) * Node_Height;

  double convertNodeIndexToPositionY(int index) =>
      (convertNodeIndexToColumn(index) * Node_Size) + Node_Size_Half;

  double convertNodeIndexToPositionX(int index) =>
      (convertNodeIndexToRow(index) * Node_Size) + Node_Size_Half;

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

  /// WARNING - EXPENSIVE
  List<int> findNodesOfType(int type){
    final values = <int>[];
    for (var i = 0; i < gridVolume; i++){
      if (nodeTypes[i] != type) continue;
      values.add(i);
    }
    return values;
  }

  void detectSpawnPoints() =>
      spawnPoints = copyUInt16List(findNodesOfType(NodeType.Spawn));

  bool raycastCollisionXY(double x1, double y1, double x2, double y2, double z) {
    final distance = getDistanceXY(x1, y1, x2, y2);
    final jumps = distance ~/ Node_Size_Half;
    if (jumps <= 0) return false;
    final angle = getAngleBetween(x1, y1, x2, y2);
    for (var i = 0; i < jumps; i++) {
      final x = x1 + getAdjacent(angle, i * Node_Size_Half);
      final y = y1 + getOpposite(angle, i * Node_Size_Half);
      if (getCollisionAt(x, y, z)) return true;
    }
    return false;
  }

  int getNodeIndexZ(int nodeIndex) => nodeIndex ~/ gridArea;

  int getNodeIndexRow(int nodeIndex) => (nodeIndex % gridArea) ~/ gridColumns;

  int getNodeIndexColumn(int nodeIndex) => nodeIndex % gridRows;
}
