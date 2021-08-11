
import '../classes.dart';

class Block extends GameObject {
  double width = 24;
  double height = 24;
  late double topX;
  late double topY;

  Block(double x, double y) : super(x, y){
    topX = x;
    topY = y - width * 0.5;
    // right
  }
}