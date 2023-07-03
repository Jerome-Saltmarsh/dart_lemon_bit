
import 'package:gamestream_server/common.dart';
import 'package:gamestream_server/isometric.dart';
import 'package:gamestream_server/utils.dart';

import 'mmo_npc.dart';

class MmoPlayer extends IsometricPlayer {

  static const Destination_Radius_Interact = 80.0;
  static const Destination_Radius_Run = 50.0;

  var destinationRadius = Destination_Radius_Run;
  var interacting = false;

  late final npcText = ChangeNotifier("", onChangedNpcText);

  MmoPlayer({required super.game});

  bool get destinationWithinDestinationRadius => runDestinationWithinRadius(destinationRadius);

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
    final debugCharacter = this.debugSelected;
    if (debugCharacter is IsometricCharacter) {
      debugCharacter.clearTarget();
      debugCharacter.pathTargetIndex = scene.findEmptyIndex(mouseIndex);
      return;
    }

    if (aimTarget == null) {
      clearTarget();
      clearPath();
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
  void customOnUpdate() {
    updateDestination();
    updateDestinationRadius();
    updateInteracting();
    updateCharacterState();
  }

  void updateInteracting() {
    final target = this.target;
    if (interacting) {
      if (target == null){
        interacting = false;
        npcText.value = "";
      }
      return;
    }

    if (target is! MMONpc)
      return;

    if (!targetWithinInteractRadius)
      return;

    final interact = target.interact;

    if (interact == null)
      return;

    interact(this);
    interacting = true;
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

  void talk(String text) {
     npcText.value = text;
  }

  void onChangedNpcText(String value) {
    writeNpcText();
  }

  void writeNpcText() {
    writeByte(ServerResponse.MMO);
    writeByte(MMOResponse.Npc_Text);
    writeString(npcText.value);
  }

  void endInteraction() {
    if (!interacting) return;
    clearTarget();
  }
}