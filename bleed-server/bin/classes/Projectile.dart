import '../common/enums/Direction.dart';
import '../common/enums/ProjectileType.dart';
import '../interfaces/HasSquad.dart';
import 'Character.dart';
import 'GameObject.dart';
import 'Positioned.dart';

class Projectile extends GameObject implements HasSquad {
  late double xStart;
  late double yStart;
  late Character owner;
  late double range;
  late int damage;
  late ProjectileType type;
  late Direction direction;
  late Positioned? target;
  late double speed;

  Projectile():super(0, 0);

  int get squad => owner.squad;

  @override
  int getSquad() {
    return owner.squad;
  }
}
