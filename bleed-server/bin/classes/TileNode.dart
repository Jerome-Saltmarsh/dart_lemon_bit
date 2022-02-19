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
  late TileNode up;
  late TileNode upRight;
  late TileNode right;
  late TileNode rightDown;
  late TileNode down;
  late TileNode downLeft;
  late TileNode left;
  late TileNode leftUp;
  late int x;
  late int y;
  late Vector2 position;
  bool open;
  int search = -1;

  TileNode(this.open);
}
