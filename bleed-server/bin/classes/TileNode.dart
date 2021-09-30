import '../common/classes/Vector2.dart';

class TileNodeVisit {
  TileNodeVisit? previous;
  late int travelled;
  int remaining;
  TileNode tileNode;

  TileNodeVisit(this.previous, this.remaining, this.tileNode) {
    if (previous != null) {
      travelled = previous!.travelled + 1;
    } else {
      travelled = 0;
    }
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
