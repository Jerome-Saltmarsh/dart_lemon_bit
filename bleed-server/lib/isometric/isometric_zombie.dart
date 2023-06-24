
import 'package:bleed_server/common/src.dart';
import 'package:bleed_server/isometric/src.dart';

class IsometricZombie extends IsometricCharacter {

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
  );

  @override
  void customOnUpdate() {
    super.customOnUpdate();
    if (deadBusyOrWeaponStateBusy) return;

    if (characterStatePerforming && stateDuration == 10){

      final target = this.target;

      if (target is IsometricCollider){
        game.applyHit(
          srcCharacter: this,
          target: target,
          damage: 1,
          hitType: IsometricHitType.Melee,
        );
      }
    }

    updateTarget();
    updateCharacterState();
  }

  void updateTarget(){
    if (targetIsNull) {
      target = game.findNearestEnemy(this, radius: 2000);
    }
  }

  void updateCharacterState(){
    final target = this.target;

    if (target == null) return;

    if (targetWithinAttackRange){
      face(target);
      setCharacterStatePerforming(duration: 30);
    } else {
      face(target);
      setCharacterStateRunning();
    }
  }

}