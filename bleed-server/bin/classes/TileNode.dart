import 'package:lemon_math/Vector2.dart';

import 'Scene.dart';

class TileNode with Position {
  /// row - 1
  late TileNode up;
  /// row - 1, column + 1
  late TileNode upRight;
  /// column + 1
  late TileNode right;
  /// row + 1, column + 1
  late TileNode downRight;
  /// row + 1
  late TileNode down;
  /// row + 1, column - 1
  late TileNode downLeft;
  /// column - 1
  late TileNode left;
  /// row - 1, column - 1
  late TileNode upLeft;
  late int row;
  late int column;
  bool open;
  bool obstructed = false;
  int searchId = -1;
  int reserveId = -1;
  TileNode? reserved;
  TileNode? previous;
  int score = 0;

  int depth = 0;

  TileNode(this.open);

  TileNode getNodeByDirection(int direction){
    if (direction <= 3 ) {
      switch (direction) {
        case 0:
          return up;
        case 1:
          return upRight;
        case 2:
          return right;
        case 3:
          return downRight;
        default:
          throw Exception();
      }
    }
    switch(direction) {
      case 4:
        return down;
      case 5:
        return downLeft;
      case 6:
        return left;
      case 7:
        return upLeft;
      default:
        throw Exception();
    }
  }

  void reserveSurroundingNodes(){
    _reserve(up);
    _reserve(upRight);
    _reserve(right);
    _reserve(downRight);
    _reserve(down);
    _reserve(downLeft);
    _reserve(left);
    _reserve(upLeft);
  }

  void _reserve(TileNode node){
    if (node.reserveId == pathFindSearchID) return;
    node.reserved = this;
    node.reserveId = pathFindSearchID;
  }
}
