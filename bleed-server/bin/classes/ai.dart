import 'dart:typed_data';

import 'package:lemon_math/library.dart';

import '../common/library.dart';
import '../functions/withinRadius.dart';
import 'collider.dart';
import 'components.dart';
import 'character.dart';
import 'enemy_spawn.dart';
import 'weapon.dart';

class AI extends Character with Material {
  static const viewRange = 200.0;
  static const chaseRange = 500.0;
  static const maxAIPathLength = 80;
  static const maxAIPathLengthMinusOne = maxAIPathLength - 3;

  final pathX = Float32List(maxAIPathLength);
  final pathY = Float32List(maxAIPathLength);
  var _pathIndex = -1;
  var dest = Vector2(-1, -1);
  var objective;

  EnemySpawn? enemySpawn;

  int get pathIndex => _pathIndex;

  bool get pathSet => _pathIndex >= 0;

  void stopPath(){
    if (deadOrBusy) return;
    _pathIndex = -1;
    state = CharacterState.Idle;
  }

  set pathIndex(int value){
    _pathIndex = value;
    if (value < 0) {
      if (alive) {
        state = CharacterState.Idle;
      }
      return;
    }
    dest.x = pathX[value];
    dest.y = pathY[value];
  }

  void nextPath(){
    pathIndex = _pathIndex - 1;
  }

  bool get arrivedAtDest {
    const radius = 15;
    if ((x - dest.x).abs() > radius) return false;
    if ((y - dest.y).abs() > radius) return false;
    return true;
  }

  AI({
    required double x,
    required double y,
    required double z,
    required int health,
    required Weapon weapon,
    int team = 0,
    double speed = 3.0,
  }): super(
      x: x,
      y: y,
      z: z,
      health: health,
      team: team,
      equippedWeapon: weapon,
      speed: speed
  ) {
    this.material = MaterialType.Flesh;
  }

  void clearTargetIf(Character value){
    if (target != value) return;
    target = objective;
  }

  bool withinViewRange(Position target) {
    if (target == objective) return true;
    return withinRadius(this, target, viewRange);
  }

  bool withinChaseRange(Position target) {
    if (target == objective) return true;
    return withinRadius(this, target, chaseRange);
  }

  @override
  void onCollisionWith(Collider other){
    if (_pathIndex < 0) return;
    if (other is AI) {
      rotateAround(other, 0.2);
    }
    if (!other.withinBounds(dest)) return;
    nextPath();
  }
}
