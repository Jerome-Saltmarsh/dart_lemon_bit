
import 'package:gamestream_server/common.dart';
import 'package:gamestream_server/lemon_math.dart';
import 'package:gamestream_server/isometric.dart';

class IsometricZombie extends IsometricCharacter {

  var wander = true;
  var nextWander = 0;
  var wanderRadius = 5;
  var applyHitFrame = 10;
  var performAttackDuration = 30;

  final IsometricGame game;

  IsometricZombie({
    required this.game,
    required super.health,
    required super.weaponDamage,
    required super.team,
    required super.x,
    required super.y,
    required super.z,
  }) : super(
    characterType: CharacterType.Zombie,
    weaponType: WeaponType.Unarmed,
    weaponRange: 20,
    weaponCooldown: 20,
  );

  bool get shouldWander => wander && target == null && nextWander-- <= 0;

  bool get shouldApplyHitToTarget =>
      characterStatePerforming && stateDuration == applyHitFrame;

  @override
  void customOnUpdate() {
    if (deadBusyOrWeaponStateBusy) return;

    if (shouldApplyHitToTarget){
      applyHitToTarget();
    }

    if (targetIsEnemy && targetWithinAttackRange){
      attackTarget();
      return;
    }

    if (shouldWander) {
      applyWander();
    }
  }

  void applyWander() {
    nextWander = randomInt(300, 500);
    pathTargetIndex = game.scene.findRandomNodeTypeAround(
      z: indexZ,
      row: indexRow,
      column: indexColumn,
      radius: wanderRadius,
      type: NodeType.Empty,
    );
  }

  void applyHitToTarget() {
    final target = this.target;
    if (target is! IsometricCollider) return;
    game.applyHit(
      srcCharacter: this,
      target: target,
      damage: weaponDamage,
      hitType: IsometricHitType.Melee,
    );
  }

  void attackTarget() {
    final target = this.target;
    if (target == null) return;
    face(target);
    setCharacterStatePerforming(duration: performAttackDuration);
  }
}