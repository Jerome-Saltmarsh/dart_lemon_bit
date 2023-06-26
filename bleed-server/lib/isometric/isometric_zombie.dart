
import 'package:bleed_server/common/src.dart';
import 'package:bleed_server/isometric/src.dart';
import 'package:lemon_math/functions/give_or_take.dart';

class IsometricZombie extends IsometricCharacter {

  var _nextWander = 0;

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

      if (_nextWander <= 0){
        _nextWander = 500;

        final randomRow = indexRow + giveOrTake(5).toInt();
        final randomColumn = indexColumn + giveOrTake(5).toInt();
        if (game.scene.getGridOrientation(indexZ, randomRow, randomColumn) == NodeOrientation.None){
          pathTargetIndex = game.scene.getNodeIndex(indexZ, randomRow, randomColumn);
        }
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