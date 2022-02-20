import 'package:lemon_math/Vector2.dart';

class TileNodeVisit {
  TileNodeVisit? previous;
  late int travelled;
  late int score;
  TileNode tileNode;

  TileNodeVisit(this.previous, int remaining, this.tileNode) {
    if (previous != null) {
      travelled = previous!.travelled + 1;
    } else {
      travelled = 0;
    }
    score = travelled + remaining;
  }

  bool isCloserThan(TileNodeVisit that) {
    return this.score < that.score;
  }
}

class TileNode {
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
  late Vector2 position;
  bool open;
  int search = -1;
  TileNode? previous;
  int score = 0;

  TileNode(this.open);
}
