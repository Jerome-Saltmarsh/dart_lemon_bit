import 'package:lemon_math/Vector2.dart';

class TileNodeVisit {
  bool available = true;
  TileNodeVisit? previous;
  late int travelled;
  int remaining;
  late int score;
  TileNode tileNode;

  TileNodeVisit(this.previous, this.remaining, this.tileNode) {
    if (previous != null) {
      travelled = previous!.travelled + 1;
    } else {
      travelled = 0;
    }
    score = travelled + remaining;
  }

  bool isCloserThan(TileNodeVisit that) {
    if (this.score < that.score) return true;
    if (this.score > that.score) return false;
    if (this.remaining < that.remaining) return true;
    if (this.remaining > that.remaining) return false;
    if (this.travelled < that.travelled) return true;
    if (this.travelled > that.travelled) return false;
    return true;
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
