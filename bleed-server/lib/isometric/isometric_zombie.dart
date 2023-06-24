
import 'package:bleed_server/common/src.dart';
import 'package:bleed_server/isometric/src.dart';

class IsometricZombie extends IsometricCharacter {

  var _refreshTargetTimer = 0;

  double viewRadius;
  int refreshTargetDuration;
  int refreshDurationWander;

  final IsometricGame game;


  IsometricZombie({
    required this.game,
    required super.health,
    required super.damage,
    required super.team,
    required super.x,
    required super.y,
    required super.z,
    this.viewRadius = 500,
    this.refreshTargetDuration = 100,
    this.refreshDurationWander = 500,
  }) : super(
    characterType: CharacterType.Zombie,
    weaponType: ItemType.Empty,
  );

  bool get shouldRefreshTarget => targetIsNull || _refreshTargetTimer-- <= 0;

  bool get shouldRunToTarget => target != null;

  bool get shouldApplyHitToTarget => characterStatePerforming && stateDuration == 10;

  void updateDestination(){

  }

  @override
  void customOnUpdate() {
    super.customOnUpdate();
    if (deadBusyOrWeaponStateBusy) return;

    if (shouldApplyHitToTarget){
      applyHitToTarget();
    }

    if (shouldRefreshTarget) {
      refreshTarget();
    }

    updateDestination();

    if (shouldIdle) {
      setCharacterStateIdle();
      return;
    }

    if (shouldAttackTarget){
      attackTarget();
      return;
    }

    if (shouldRunToTarget){
      runToTarget();
      return;
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

  void refreshTarget() {
    target = game.findNearestEnemy(this, radius: viewRadius);
    _refreshTargetTimer = refreshTargetDuration;
  }

  void attackTarget() {
    final target = this.target;
    if (target == null) return;
    face(target);
    setCharacterStatePerforming(duration: 30);
  }

  void runToTarget() {
    final target = this.target;
    if (target == null) return;
    face(target);
    setCharacterStateRunning();
    setPathToTarget(game.scene);
  }

}