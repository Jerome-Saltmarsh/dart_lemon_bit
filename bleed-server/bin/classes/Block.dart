import '../constants.dart';
import '../maths.dart';

class Block {
   late final num topX;
  late final num topY;
  late final num rightX;
  late final num rightY;
  late final num bottomX;
  late final num bottomY;
  late final num leftX;
  late final num leftY;

  static Block build(num x, num y, num width, num length){

    num halfWidth = width * 0.5;
    num halfLength = length * 0.5;

    num aX = adj(piQuarter * 5, halfLength);
    num aY = opp(piQuarter * 5, halfLength);
    num bX = adj(piQuarter * 3, halfWidth);
    num bY = opp(piQuarter * 3, halfWidth);
    num cX = adj(piQuarter * 1, halfLength);
    num cY = opp(piQuarter * 1, halfLength);
    num dX = adj(piQuarter * 7, halfWidth);
    num dY = opp(piQuarter * 7, halfWidth);

    num topX = x + cX + dX;
    num topY = y + cY + dY;
    num rightX = x + cX + bX;
    num rightY = y + cY + bY;
    num bottomX = x + bX + aX;
    num bottomY = y + bY + aY;
    num leftX = x + dX + aX;
    num leftY = y + dY + aY;

    return Block(topX, topY, rightX, rightY, bottomX, bottomY, leftX, leftY);
  }

  Block(this.topX, this.topY, this.rightX, this.rightY, this.bottomX,
      this.bottomY, this.leftX, this.leftY);
}