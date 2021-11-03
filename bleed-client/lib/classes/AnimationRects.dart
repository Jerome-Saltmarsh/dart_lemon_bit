import 'dart:ui';

class AnimationRects {
  final List<Rect> down;
  final List<Rect> downRight;
  final List<Rect> right;
  final List<Rect> upRight;
  final List<Rect> up;
  final List<Rect> upLeft;
  final List<Rect> left;
  final List<Rect> downLeft;

  AnimationRects({
    this.down,
    this.downRight,
    this.right,
    this.upRight,
    this.up,
    this.upLeft,
    this.left,
    this.downLeft
  });
}
