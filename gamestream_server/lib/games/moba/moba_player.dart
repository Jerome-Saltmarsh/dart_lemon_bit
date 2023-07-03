import 'package:gamestream_server/isometric/src.dart';

class MobaPlayer extends IsometricPlayer {
  MobaPlayer({required super.game}) {
    pathFindingEnabled = false;
  }

  @override
  void onMouseLeftHeld() {
    onMouseLeftClicked();
  }

  @override
  void onMouseLeftClicked() {
    final debugCharacter = this.selectedCollider;
    if (debugCharacter is IsometricCharacter) {
      debugCharacter.clearTarget();
      if (debugCharacter.pathFindingEnabled){
        debugCharacter.pathTargetIndex = scene.findEmptyIndex(mouseIndex);
      } else if (debugCharacter.runToDestinationEnabled){
        debugCharacter.runX = mouseGridX;
        debugCharacter.runY = mouseGridY;
      }
      return;
    }

    if (aimTarget == null) {
      clearTarget();
      clearPath();
      runToDestinationEnabled = true;
      setDestinationToMouse();
    } else {
      setTargetToAimTarget();
    }
  }
}