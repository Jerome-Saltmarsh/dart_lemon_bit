import 'dart:typed_data';
import 'package:gamestream_ws/packages.dart';

import 'gameobject.dart';
import 'position.dart';

class Scene {

  static const Not_Visited = -1;

  /// The first 2 bytes are use for the index, the other 6 store its information
  var marks = <int>[];
  var keys = <String, int>{};

  Uint8List types;
  Uint8List shapes;
  Uint8List? compiled;



  /// used for pathfinding to contains the the index of a previous path
  Int32List path = Int32List(0);

  static final visitHistory = Uint32List(10000);
  static final visitStack = Uint32List(10000);
  static final compiledPath = Uint32List(10000);

  static var visitHistoryIndex = 0;
  static var visitStackIndex = 0;

  var height = 0;
  var rows = 0;
  var columns = 0;
  var volume = 0;
  var area = 0;
  var name = "";

  late double rowLength;
  late double columnLength;
  late double heightLength;

  final List<GameObject> gameObjects;

  Scene({
    required this.name,
    required this.types,
    required this.shapes,
    required this.height,
    required this.rows,
    required this.columns,
    required this.gameObjects,
    required this.marks,
  }) {
    refreshMetrics();
  }

  void removeUnusedNodes(){
    var totalDeleted = 0;
    final total = types.length;
     for (var i = 0; i < total; i++) {
        if (const [
          // NodeType.Spawn_Player,
          // NodeType.Spawn,
          // NodeType.Spawn_Weapon,
        ].contains(types[i])) {
          types[i] = NodeType.Empty;
          totalDeleted++;
        }
     }
     if (totalDeleted > 0){
       print("total old node types removed: $totalDeleted");
     }
  }

  void refreshMetrics() {
    if (path.length != types.length) {
      path = Int32List(types.length);
      for (var i = 0; i < path.length; i++) {
        path[i] = Not_Visited;
      }
    }
    area = rows * columns;
    volume = height * area;
    rowLength = rows * Node_Size;
    columnLength = columns * Node_Size;
    heightLength = height * Node_Height;
  }

  bool inboundsV3(Position v3) => inboundsXYZ(v3.x, v3.y, v3.z);

  void setNodeZRC(int z, int row, int column, int type, int orientation) {
    if (outOfBounds(z, row, column)) return;
    final index = getIndex(z, row, column);
    setNode(index, type, orientation);
  }

  void setNodeEmpty(int index) =>
      setNode(index, NodeType.Empty, NodeOrientation.None);

  void setNode(int index, int type, int orientation) {
    if (index < 0 || index >= volume){
      throw Exception('scene.setNode(index: $index, type: $type, orientation: $orientation)\n\tthrew: "invalid index"');
    }
    types[index] = type;
    shapes[index] = orientation;
    compiled = null;
  }

  int getTypeXYZ(double x, double y, double z) =>
      inboundsXYZ(x, y, z)
          ? types[getIndexXYZ(x, y, z)]
          : NodeType.Boundary;

  int getIndexPosition(Position position3) =>
      getIndexXYZ(
        position3.x,
        position3.y,
        position3.z,
      );

  int getIndexXYZ(double x, double y, double z) =>
      getIndex(
        z ~/ Node_Size_Half,
        x ~/ Node_Size,
        y ~/ Node_Size,
      );

  int getOrientationXYZ(double x, double y, double z) {
    if (x < 0 || y < 0 || x >= rowLength || y >= columnLength)
      return NodeOrientation.Solid;
    if (z >= heightLength || z < 0)
      return NodeOrientation.None;

    return shapes[getIndexXYZ(x, y, z)];
  }

  bool isInboundV3(Position pos) =>
      inboundsXYZ(pos.x, pos.y, pos.z);

  bool getCollisionAt(double x, double y, double z) {
    final orientation = getOrientationXYZ(x, y, z);
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

  double getIndexX(int index) =>
      (getRow(index) * Node_Size) + Node_Size_Half;

  double getIndexY(int index) =>
      (getColumn(index) * Node_Size) + Node_Size_Half;

  double getIndexZ(int index) =>
      getZ(index) * Node_Height;

  int findPath(var indexStart, var indexEnd, {int max = 100}) {

    final shapes = this.shapes;

    if (indexEnd <= 0 ||
        indexEnd >= shapes.length ||
        shapes[indexEnd] == NodeOrientation.Solid
    ) return indexStart;

    final path = this.path;

    for (var i = 0; i <= visitHistoryIndex; i++) {
      path[visitHistory[i]] = Not_Visited;
    }

    visitHistoryIndex = 0;
    visitStackIndex = 0;

    visitHistory[visitHistoryIndex++] = indexStart;
    visitStack[visitStackIndex] = indexStart;

    final targetRow = getRow(indexEnd);
    final targetColumn = getColumn(indexEnd);

    while (visitStackIndex >= 0) {

      final currentIndex = visitStack[visitStackIndex--];

      if (max-- <= 0){
        return currentIndex;
      }

      if (currentIndex == indexEnd)
        return currentIndex;

      final z = getZ(currentIndex);
      final row = getRow(currentIndex);
      final column = getColumn(currentIndex);

      final targetDirection = convertToDirection(
          targetRow - row, targetColumn - column);
      final backwardDirection = (targetDirection + 4) % 8;

      visit(
        z: z,
        row: row + IsometricDirection.convertToVelocityRow(backwardDirection),
        column: column +
            IsometricDirection.convertToVelocityColumn(backwardDirection),
        fromIndex: currentIndex,
      );

      for (var i = 3; i >= 0; i--) {
        final dirLess = (targetDirection - i) % 8;
        final dirLessRow = row +
            IsometricDirection.convertToVelocityRow(dirLess);
        final dirLessCol = column +
            IsometricDirection.convertToVelocityColumn(dirLess);

        final dirMore = (targetDirection + i) % 8;
        final dirMoreRow = row +
            IsometricDirection.convertToVelocityRow(dirMore);
        final dirMoreColumn = column +
            IsometricDirection.convertToVelocityColumn(dirMore);

        visit(
            z: z, row: dirLessRow, column: dirLessCol, fromIndex: currentIndex);
        visit(z: z,
            row: dirMoreRow,
            column: dirMoreColumn,
            fromIndex: currentIndex);
      }

      final forwardRow = row +
          IsometricDirection.convertToVelocityRow(targetDirection);
      final forwardColumn = column +
          IsometricDirection.convertToVelocityColumn(targetDirection);
      visit(z: z,
          row: forwardRow,
          column: forwardColumn,
          fromIndex: currentIndex);
    }

    return indexStart;
  }

  void visit({
    required int z,
    required int row,
    required int column,
    required int fromIndex,
  }) {
    if (outOfBounds(z, row, column) || z <= 0)
      return;

    final index = getIndex(z, row, column);

    if (path[index] != Not_Visited)
      return;


    final indexShape = shapes[index];

    if (NodeOrientation.slopeSymmetric.contains(indexShape)) {
      final fromRow = getRow(fromIndex);
      final fromColumn = getColumn(fromIndex);

      if ((fromRow - row).abs() + (fromColumn - column).abs() > 1)
        return;

      if (fromRow > row) {
        if (indexShape == NodeOrientation.Slope_North) {
          addToStack(index, fromIndex);
          visit(
            z: z + 1,
            row: row - 1,
            column: column,
            fromIndex: index,
          );
        }
        return;
      }

      if (fromRow < row) {
        if (indexShape == NodeOrientation.Slope_South) {
          addToStack(index, fromIndex);
          visit(
            z: z + 1,
            row: row + 1,
            column: column,
            fromIndex: index,
          );
        }
        return;
      }


      if (fromColumn > column) {
        if (indexShape == NodeOrientation.Slope_East) {
          addToStack(index, fromIndex);
          visit(
            z: z + 1,
            row: row,
            column: column - 1,
            fromIndex: index,
          );
        }
        return;
      }

      if (fromColumn < column) {
        if (indexShape == NodeOrientation.Slope_West) {
          visit(
            z: z + 1,
            row: row,
            column: column + 1,
            fromIndex: index,
          );
        }
        return;
      }

      return;
    }

    if (indexShape != NodeOrientation.None) {
      return;
    }

    addToStack(index, fromIndex);

    final indexOrientationBelow = shapes[index - area];
    if (indexOrientationBelow == NodeOrientation.None) {
      visit(z: z - 1, row: row, column: column, fromIndex: index);
    }
  }

  addToStack(int index, int from) {
    assert (path[index] == Not_Visited);
    assert (index != from);
    // print("addToStack(index: $index, from: $from)");
    path[index] = from;
    visitHistory[visitHistoryIndex++] = index;
    visitStackIndex++;
    visitStack[visitStackIndex] = index;
  }

  static int convertToDirectionVertical(int value) {
    if (value < 0)
      return -1;
    if (value > 0)
      return 1;
    return 0;
  }

  static int convertToDirection(int rows, int columns) {
    if (rows > 0) {
      if (columns < 0)
        return IsometricDirection.South_East;
      if (columns > 0)
        return IsometricDirection.South_West;
      return IsometricDirection.South;
    }

    if (rows < 0) {
      if (columns < 0)
        return IsometricDirection.North_East;
      if (columns > 0)
        return IsometricDirection.North_West;
      return IsometricDirection.North;
    }

    if (columns < 0)
      return IsometricDirection.East;

    return IsometricDirection.West;
  }

  bool isPerceptible(Position a, Position b, {double maxRadius = 500}) {

    if (!a.withinRadiusPosition(b, maxRadius))
      return false;

    if (outOfBoundsPosition(a))
      return false;

    if (outOfBoundsPosition(b))
      return false;

    var positionX = a.x;
    var positionY = a.y;
    var positionZ = a.z;
    var angle = a.getAngle(b);

    final distance = a.getDistance(b);

    if (distance < Node_Size) {
      return true;
    }

    final jumpSize = Node_Size_Quarter;
    final jumps = distance ~/ jumpSize;
    final velX = adj(angle, jumpSize);
    final velY = opp(angle, jumpSize);

    for (var i = 0; i < jumps; i++) {
      positionX += velX;
      positionY += velY;
      final nodeOrientation = getOrientationXYZ(
          positionX, positionY, positionZ);
      if (nodeOrientation != NodeOrientation.None) {
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
  }) {
    assert (radius >= 1);

    while (attempts-- >= 0) {
      final randomZ = z;
      final randomRow = row + giveOrTake(radius).toInt();
      final randomColumn = column + giveOrTake(radius).toInt();
      if (getOrientation(randomZ, randomRow, randomColumn) == type) {
        return getIndex(randomZ, randomRow, randomColumn);
      }
    }
    return -1;
  }

  int getType(int z, int row, int column) =>
      outOfBounds(z, row, column)
          ? NodeType.Boundary
          : types[getIndex(z, row, column)];

  int getOrientation(int z, int row, int column) =>
      outOfBounds(z, row, column)
          ? NodeType.Boundary
          : shapes[getIndex(z, row, column)];

  bool inboundsXYZ(double x, double y, double z) =>
      x >= 0 &&
          y >= 0 &&
          z >= 0 &&
          x < rowLength &&
          y < columnLength &&
          z < heightLength;

  int getIndex(int z, int row, int column) {
    assert (!outOfBounds(z, row, column));
    return (z * area) + (row * columns) + column;
  }

  int getIndexUnsafe(int z, int row, int column) {
    return (z * area) + (row * columns) + column;
  }

  bool outOfBounds(int z, int row, int column) =>
      z < 0 ||
          row < 0 ||
          column < 0 ||
          z >= height ||
          row >= rows ||
          column >= columns;

  bool outOfBoundsPosition(Position position) =>
      outOfBoundsXYZ(position.x, position.y, position.z);

  bool outOfBoundsXYZ(double x, double y, double z) =>
      x < 0 ||
      y < 0 ||
      z < 0 ||
      x >= rowLength ||
      y >= columnLength ||
      z >= heightLength;


  int getRow(int nodeIndex) => (nodeIndex % area) ~/ columns;

  int getColumn(int nodeIndex) => (nodeIndex) % columns;

  int getZ(int nodeIndex) => nodeIndex ~/ area;

  int findEmptyIndex(int index) {
    while (index < shapes.length) {
      if (shapes[index] == NodeOrientation.None)
        return index;

      index += area;

    }
    return -1;
  }

  void sortMarks() => marks.sort(compareMarks);

  int compareMarks(int markValueA, int markValueB) =>
      compareIndexes(
        MarkType.getIndex(markValueA),
        MarkType.getIndex(markValueB),
      );

  int compareIndexes(int indexA, int indexB){
     final indexATotal = getIndexTotal(indexA);
     final indexBTotal = getIndexTotal(indexB);
     if (indexATotal > indexBTotal)
       return 1;
     if (indexATotal < indexBTotal)
       return -1;
     return 0;
  }

  int getIndexTotal(int index) =>
      getRow(index) +getColumn(index) + getZ(index);


  int setMarkType({
    required int listIndex,
    required int markType,
  }) {
    if (listIndex < 0){
      throw Exception('invalid index');
    }
    if (listIndex >= marks.length){
      throw Exception('invalid index');
    }

    final markValue = marks[listIndex];
    final markIndex = MarkType.getIndex(markValue);
    final newMarkValue = MarkType.build(index: markIndex, type: markType);
    marks[listIndex] = newMarkValue;
    return newMarkValue;
  }

  void addMark({required int index, required int markType}) {
    if (index < 0){
      throw Exception('invalid index');
    }
    marks.add(MarkType.build(index: index, type: markType));
  }

  void addKey(String name, int value){
    keys[name] = value;
  }

  int getKey(String name) {
    final value = keys[name];
    if (value == null){
      throw Exception('scene.getKey($name) - not found');
    }
    return value;
  }

  void movePositionToKey(Position position, String key) =>
      movePositionToIndex(position, getKey(key));

  void movePositionToIndex(Position position, int nodeIndex) {
    position.x = getIndexX(nodeIndex);
    position.y = getIndexY(nodeIndex);
    position.z = getIndexZ(nodeIndex);
  }
}
