
import 'package:bleed_server/common/src/isometric/target_category.dart';
import 'package:bleed_server/isometric/src.dart';

import 'mmo_npc.dart';

class MmoPlayer extends IsometricPlayer {

  static const Destination_Radius_Interact = 50.0;
  static const Destination_Radius_Run = 50.0;

  var destinationRadius = Destination_Radius_Run;

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

    if (isAlly(value)) {
      if (value is MMONpc && value.interact != null) {
        return TargetCategory.Talk;
      }
    }
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

  void setDestinationRadiusToDestinationRadiusInteract() {
    destinationRadius = Destination_Radius_Interact;
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
       setDestinationRadiusToDestinationRadiusRun();
       return;
     }
     if (targetIsAlly){
       setDestinationRadiusToDestinationRadiusInteract();
       return;
     }
  }

  void setDestinationRadiusToDestinationRadiusRun() {
    destinationRadius = Destination_Radius_Run;
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

  bool get targetWithinInteractRadius => targetWithinRadius(Destination_Radius_Interact);
}