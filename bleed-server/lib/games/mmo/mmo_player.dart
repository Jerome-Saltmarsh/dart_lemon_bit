
import 'package:bleed_server/common/src/isometric/target_category.dart';
import 'package:bleed_server/isometric/src.dart';

class MmoPlayer extends IsometricPlayer {
  MmoPlayer({required super.game});

  @override
  int getTargetCategory(IsometricPosition? value){
    if (value == null) return TargetCategory.Nothing;
    if (value is IsometricGameObject) {
      if (value.interactable) {
        return TargetCategory.Collect;
      }
      return TargetCategory.Nothing;
    }
    if (isAlly(value)) return TargetCategory.Talk;
    if (isEnemy(value)) return TargetCategory.Attack;
    return TargetCategory.Run;
  }


  @override
  void onMouseLeftClicked() {
    final aimTarget = this.aimTarget;
    if (aimTarget == null) {
      setDestinationToMouse();
    }
  }

  @override
  void onMouseLeftHeld() {
    final aimTarget = this.aimTarget;
    if (aimTarget == null) {
      setDestinationToMouse();
    }
  }

  @override
  void customUpdate() {
    super.customUpdate();

    if (!destinationWithinRadius(50)){
      runToDestination();
    } else {
      setCharacterStateIdle();
    }
  }
}