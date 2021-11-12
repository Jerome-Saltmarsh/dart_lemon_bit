import 'GameObject.dart';
import 'Player.dart';

class Grenade extends GameObject {
  final Player owner;

  Grenade(this.owner, double xv, double yv, double zVel)
      : super(owner.x, owner.y, xv: xv, yv: yv) {
    this.zv = zVel;
  }
}
