import '../constants.dart';
import '../maths.dart';

class Block {
  final double x;
  final double y;
  final double width;
  final double length;

  late final double topX;
  late final double topY;
  late final double rightX;
  late final double rightY;
  late final double bottomX;
  late final double bottomY;
  late final double leftX;
  late final double leftY;

  Block(this.x, this.y, this.width, this.length){

    double halfWidth = width * 0.5;
    double halfLength = length * 0.5;

    double aX = adj(piQuarter * 5, halfLength);
    double aY = opp(piQuarter * 5, halfLength);
    double bX = adj(piQuarter * 3, halfWidth);
    double bY = opp(piQuarter * 3, halfWidth);
    double cX = adj(piQuarter * 1, halfLength);
    double cY = opp(piQuarter * 1, halfLength);
    double dX = adj(piQuarter * 7, halfWidth);
    double dY = opp(piQuarter * 7, halfWidth);

    topX = x + cX + dX;
    topY = y + cY + dY;

    rightX = x + cX + bX;
    rightY = y + cY + bY;

    bottomX = x + bX + aX;
    bottomY = y + bY + aY;

    leftX = x + dX + aX;
    leftY = y + dY + aY;
  }
}