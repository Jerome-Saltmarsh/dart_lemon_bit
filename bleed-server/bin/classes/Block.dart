class Block {
  final double x;
  final double y;
  final double width;
  final double height;

  late final double top;
  late final double right;
  late final double bottom;
  late final double left;

  Block(this.x, this.y, this.width, this.height){
    top = y - height * 0.5;
    right = x + width * 0.5;
    bottom = y + height * 0.5;
    left = x - width * 0.5;
  }
}