
import 'package:bleed_server/common/src.dart';
import 'package:bleed_server/isometric/src.dart';
import 'package:lemon_math/src.dart';

class IsometricZombie extends IsometricCharacter {

  var _nextWander = 0;
  var wanderRadius = 5;

  final IsometricGame game;

  IsometricZombie({
    required this.game,
    required super.health,
    required super.damage,
    required super.team,
    required super.x,
    required super.y,
    required super.z,
  }) : super(
    characterType: CharacterType.Zombie,
    weaponType: ItemType.Empty,
    weaponRange: 20,
  );

  bool get shouldRunToTarget => target != null;

  bool get shouldApplyHitToTarget => characterStatePerforming && stateDuration == 10;

  bool get shouldIdle => target == null && runDestinationWithinRadius(radius);

  @override
  void customOnUpdate() {
    super.customOnUpdate();
    if (deadBusyOrWeaponStateBusy) return;

    if (shouldApplyHitToTarget){
      applyHitToTarget();
    }

    if (targetWithinAttackRange){
      attackTarget();
      return;
    }

    if (target == null){
      _nextWander--;

      if (_nextWander <= 0) {
        _nextWander = randomInt(300, 500);
        pathTargetIndex = game.scene.findRandomNodeTypeAround(
            z: indexZ,
            row: indexRow,
            column: indexColumn,
            radius: wanderRadius,
            type: NodeType.Empty,
        );
      }
    }
  }

  void applyHitToTarget() {
    final target = this.target;
    if (target is! IsometricCollider) return;
    game.applyHit(
      srcCharacter: this,
      target: target,
      damage: 1,
      hitType: IsometricHitType.Melee,
    );
  }

  void attackTarget() {
    final target = this.target;
    if (target == null) return;
    face(target);
    setCharacterStatePerforming(duration: 30);
  }
}