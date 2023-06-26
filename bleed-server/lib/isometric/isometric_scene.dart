import 'dart:typed_data';

import 'package:bleed_server/common.dart';
import 'package:lemon_math/library.dart';

import 'isometric_gameobject.dart';
import 'isometric_position.dart';

class IsometricScene {

  static const Not_Visited = -1;

  Uint8List nodeTypes;
  Uint8List nodeOrientations;
  Uint8List? compiled;

  /// used for pathfinding to contains the the index of a previous path
  Int32List path = Int32List(0);

  static final visitHistory = Uint32List(10000);
  static final visitStack = Uint32List(10000);

  static var visitHistoryIndex = 0;
  static var visitStackIndex = 0;

  var gridHeight = 0;
  var gridRows = 0;
  var gridColumns = 0;
  var gridVolume = 0;
  var gridArea = 0;
  var name = "";

  Uint16List spawnPoints;
  Uint16List spawnPointsPlayers;
  Uint16List spawnPointTypes;

  late double gridRowLength;
  late double gridColumnLength;
  late double gridHeightLength;

  final List<IsometricGameObject> gameObjects;

  IsometricScene({
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
    refreshMetrics();
  }

  void refreshMetrics(){
    if (path.length != nodeTypes.length){
      path = Int32List(nodeTypes.length);
      for (var i = 0; i < path.length; i++){
        path[i] = Not_Visited;
      }
    }
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

  bool outOfBounds(int z, int row, int column) =>
        z < 0 ||
        row < 0 ||
        column < 0 ||
        z >= gridHeight ||
        row >= gridRows ||
        column >= gridColumns;

  bool inboundsV3(IsometricPosition v3) => inboundsXYZ(v3.x, v3.y, v3.z);

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

  int getNodeIndexV3(IsometricPosition position3) =>
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
     if (x < 0 || y < 0 || x >= gridRowLength || y >= gridColumnLength)
       return NodeOrientation.Solid;
     if (z >= gridHeightLength || z < 0)
       return NodeOrientation.None;

     return nodeOrientations[getNodeIndexXYZ(x, y, z)];
  }

  bool isInboundV3(IsometricPosition pos ) =>
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
    if (orientation == NodeOrientation.None)
      return false;
    if (orientation == NodeOrientation.Solid)
      return true;

    final percX = ((x % Node_Size) / Node_Size);
    final percY = ((y % Node_Size) / Node_Size);
    return ((z ~/ Node_Height) * Node_Height)
        + (NodeOrientation.getGradient(orientation, percX, percY) * Node_Height)
        >= z;
  }

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
      spawnPoints = Uint16List.fromList(findNodesOfType(NodeType.Spawn));

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

  double getNodePositionX(int index) =>
      (getNodeIndexRow(index) * Node_Size) + Node_Size_Half;

  double getNodePositionY(int index) =>
      (getNodeIndexColumn(index) * Node_Size) + Node_Size_Half;

  double getNodePositionZ(int index) =>
      getNodeIndexZ(index) * Node_Height;

  int getNodeIndexRow(int nodeIndex) => (nodeIndex % gridArea) ~/ gridColumns;

  int getNodeIndexColumn(int nodeIndex) => (nodeIndex) % gridColumns;

  int getNodeIndexZ(int nodeIndex) => nodeIndex ~/ gridArea;

  int findPath(var indexStart, var indexEnd, {int max = 100}){

    if (indexEnd <= 0 ||
        indexEnd >= nodeOrientations.length ||
        nodeOrientations[indexEnd] != NodeOrientation.None
    ) return indexStart;

    for (var i = 0; i <= visitHistoryIndex; i++){
      path[visitHistory[i]] = Not_Visited;
    }

    visitHistoryIndex = 0;
    visitStackIndex = 0;

    visitHistory[visitHistoryIndex++] = indexStart;
    visitStack[visitStackIndex] = indexStart;

    final targetIndexRow = getNodeIndexRow(indexEnd);
    final targetIndexColumn = getNodeIndexColumn(indexEnd);
    final z = getNodeIndexZ(indexEnd);

    while (visitStackIndex >= 0 && max-- > 0) {

      final currentIndex = visitStack[visitStackIndex--];

      if (currentIndex == indexEnd)
        return currentIndex;

      final row = getNodeIndexRow(currentIndex);
      final column = getNodeIndexColumn(currentIndex);

      final targetDirection = convertToDirection(targetIndexRow - row, targetIndexColumn - column);
      final backwardDirection = (targetDirection + 4) % 8;

      visit(
          z: z,
          row: row + IsometricDirection.convertToVelocityRow(backwardDirection),
          column: column + IsometricDirection.convertToVelocityColumn(backwardDirection),
          fromIndex: currentIndex,
      );

      for (var i = 3; i >= 0; i--) {
        final dirLess = (targetDirection - i) % 8;
        final dirLessRow = row + IsometricDirection.convertToVelocityRow(dirLess);
        final dirLessCol = column + IsometricDirection.convertToVelocityColumn(dirLess);

        final dirMore = (targetDirection + i) % 8;
        final dirMoreRow = row + IsometricDirection.convertToVelocityRow(dirMore);
        final dirMoreColumn = column + IsometricDirection.convertToVelocityColumn(dirMore);

        visit(z: z, row: dirLessRow, column: dirLessCol, fromIndex: currentIndex);
        visit(z: z, row: dirMoreRow, column: dirMoreColumn, fromIndex: currentIndex);
      }

      final forwardRow = row + IsometricDirection.convertToVelocityRow(targetDirection);
      final forwardColumn = column + IsometricDirection.convertToVelocityColumn(targetDirection);
      visit(z: z, row: forwardRow, column: forwardColumn, fromIndex: currentIndex);
    }

    return indexStart;
  }

  void visit({
    required int z,
    required int row,
    required int column,
    required int fromIndex,
  }) {
    if (outOfBounds(z, row, column))
      return;

    final index = getNodeIndex(z, row, column);

    if (path[index] != Not_Visited)
      return;
    if (nodeOrientations[index] != NodeOrientation.None)
      return;

    path[index] = fromIndex;
    visitHistory[visitHistoryIndex++] = index;
    visitStackIndex++;
    visitStack[visitStackIndex] = index;
  }

  static int convertToDirection(int diffRows, int diffCols){
    if (diffRows > 0){
      if (diffCols < 0) return 1;
      if (diffCols > 0) return 3;
      return 2;
    }

    if (diffRows < 0) {
      if (diffCols < 0) return 7;
      if (diffCols > 0) return 5;
      return 6;
    }

    if (diffCols < 0) return 0;
    return 4;
  }

  bool isPerceptible(IsometricPosition a, IsometricPosition b) {

    var positionX = a.x;
    var positionY = a.y;
    var positionZ = a.z;
    var angle = b.getAngle(a);

    final distance = a.getDistance3(b);
    final jumpSize = Node_Size_Quarter;
    final jumps = distance ~/ jumpSize;
    final velX = getAdjacent(angle, jumpSize);
    final velY = getOpposite(angle, jumpSize);

    for (var i = 0; i < jumps; i++) {
      positionX += velX;
      positionY += velY;
      final nodeOrientation = getNodeOrientationXYZ(positionX, positionY, positionZ);
      if (nodeOrientation != NodeOrientation.None){
        return false;
      }
    }
    return true;
  }

  int findRandomNodeTypeAround({
    required int z,
    required int row,
    required int column,
    required int radius,
    required int type,
    int attempts = 5,
  }){
    assert (radius >= 1);

    while (attempts-- >= 0) {
      final randomZ = z;
      final randomRow = row + giveOrTake(radius).toInt();
      final randomColumn = column + giveOrTake(radius).toInt();
      if (getGridOrientation(randomZ, randomRow, randomColumn) == type) {
        return getNodeIndex(randomZ, randomRow, randomColumn);
      }
    }
    return -1;
  }

}
