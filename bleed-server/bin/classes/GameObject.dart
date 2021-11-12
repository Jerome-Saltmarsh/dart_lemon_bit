import 'Positioned.dart';

int _idCount = 0;


class GameObject extends Positioned {
  final int id = _idCount++;
  double z = 0;
  double xv = 0;
  double yv = 0;
  double zv = 0;
  double radius = 0;
  bool collidable = true;
  bool active = true;

  double get left => x - radius;

  double get right => x + radius;

  double get top => y - radius;

  double get bottom => y + radius;

  bool get inactive => !active;

  GameObject(double x, double y,
      {this.z = 0, this.xv = 0, this.yv = 0, this.zv = 0, this.radius = 5}) : super(x, y);
}