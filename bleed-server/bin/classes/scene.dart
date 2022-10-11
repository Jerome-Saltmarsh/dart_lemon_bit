import 'dart:typed_data';

import '../common/library.dart';
import '../common/node_orientation.dart';
import '../common/node_size.dart';
import 'ai.dart';
import 'gameobject.dart';

late AI pathFindAI;
var pathFindSearchID = 0;

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
  }) {
    refreshGridMetrics();
  }

  void refreshGridMetrics(){
    gridArea = gridRows * gridColumns;
    gridVolume = gridHeight * gridArea;
    gridRowLength = gridRows * tileSize;
    gridColumnLength = gridColumns * tileSize;
    gridHeightLength = gridHeight * nodeHeight;
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
        z ~/ tileSizeHalf,
        x ~/ tileSize,
        y ~/ tileSize,
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
     final percX = ((x % tileSize) / tileSize);
     final percY = ((y % tileSize) / tileSize);
     return ((z ~/ tileHeight) * tileHeight)
         + (NodeOrientation.getGradient(orientation, percX, percY) * nodeHeight)
         >= z;
  }

  double convertNodeIndexToZPosition(int index) =>
      convertNodeIndexToZ(index) * nodeHeight;

  double convertNodeIndexToYPosition(int index) =>
      convertNodeIndexToColumn(index) * nodeSize;

  double convertNodeIndexToXPosition(int index) =>
      convertNodeIndexToRow(index) * nodeSize;

  int convertNodeIndexToRow(int index) =>
      (index - (convertNodeIndexToZ(index) * gridArea)) ~/ gridColumns;

  int convertNodeIndexToColumn(int index) =>
      index - ((convertNodeIndexToZ(index) * gridArea) + (convertNodeIndexToRow(index) * gridColumns));

  int convertNodeIndexToZ(int index) => index ~/ gridArea;

  void modifyGridAddRowAtStart(){

  }
}
