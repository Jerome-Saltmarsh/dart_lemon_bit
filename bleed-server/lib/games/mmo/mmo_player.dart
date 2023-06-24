
import 'package:bleed_server/common/src/isometric/target_category.dart';
import 'package:bleed_server/isometric/src.dart';

class MmoPlayer extends IsometricPlayer {

  static const Interact_Radius = 150.0;

  var destinationRadius = 10.0;

  MmoPlayer({required super.game});

  bool get destinationWithinDestinationRadius => destinationWithinRadius(destinationRadius);

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
    if (aimTarget == null) {
      clearTarget();
      setDestinationToMouse();
    } else {
      setTargetToAimTarget();
    }
  }

  void setDestinationRadiusToInteractRadius() {
    destinationRadius = Interact_Radius;
  }

  @override
  void onMouseLeftHeld() {
    onMouseLeftClicked();
  }

  @override
  void customUpdate() {
    super.customUpdate();

    updateDestination();
    updateDestinationRadius();
    updateCharacterState();
  }

  void updateDestination(){
    if (target != null) {
      setDestinationToTarget();
    }
  }

  void updateDestinationRadius(){
     if (targetIsNull) {
       setDestinationRadiusToRunSpeed();
       return;
     }
     if (targetIsAlly){
       setDestinationRadiusToInteractRadius();
       return;
     }
  }

  void setDestinationRadiusToRunSpeed() {
    destinationRadius = 10;
  }

  void updateCharacterState() {
    if (destinationWithinDestinationRadius) {
      setCharacterStateIdle();
    } else {
      runToDestination();
    }
  }

  void runToTarget() {
    setDestinationToTarget();
    runToDestination();
  }

  bool get targetWithinInteractRadius => targetWithinRadius(Interact_Radius);
}