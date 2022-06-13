import 'package:lemon_math/library.dart';

import 'Scene.dart';

class Node with Position {
  /// row - 1
  late Node up;
  /// row - 1, column + 1
  late Node upRight;
  /// column + 1
  late Node right;
  /// row + 1, column + 1
  late Node downRight;
  /// row + 1
  late Node down;
  /// row + 1, column - 1
  late Node downLeft;
  /// column - 1
  late Node left;
  /// row - 1, column - 1
  late Node upLeft;
  late int row;
  late int column;
  bool open;
  bool obstructed = false;
  int searchId = -1;
  int reserveId = -1;
  Node? reserved;
  Node? previous;
  int score = 0;

  int depth = 0;

  bool get visitable {
    if (!open) return false;
    if (obstructed) return false;
    if (searchId == pathFindSearchID) return false;
    return true;
  }

  bool get closed => !open;

  Node(this.open);

  Node getNodeByDirection(int direction){
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

  void set(int row, int column){
    this.row = row;
    this.column = column;
    // this.x = getTilePositionX(row, column);
    // this.y = getTilePositionY(row, column);
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

  void _reserve(Node node){
    if (node.reserveId == pathFindSearchID) return;
    node.reserved = this;
    node.reserveId = pathFindSearchID;
  }
}
