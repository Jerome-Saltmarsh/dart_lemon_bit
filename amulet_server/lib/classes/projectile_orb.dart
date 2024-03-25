import 'package:amulet_common/src.dart';
import 'package:amulet_server/isometric/classes/position.dart';
import 'package:amulet_server/isometric/classes/projectile.dart';

class ProjectileOrb extends Projectile {

  var speed = 0.0;
  var acceleration = 0.01;

  ProjectileOrb({
    required super.target,
    required super.team,
    required super.x,
    required super.y,
    required super.z,
    required super.materialType,
  }) : super(projectileType: ProjectileType.Orb_Gold) {
    assert (target != null);
  }

  @override
  set target(Position? value) {
    if (value == null){
      throw Exception();
    }
    super.target = value;
  }

  @override
  void update() {
    super.update();
    final target = this.target;
    if (target == null) return;
    final targetAngle = target.getAngle(this);
    setVelocity(targetAngle, speed);
    speed += acceleration;
  }

}