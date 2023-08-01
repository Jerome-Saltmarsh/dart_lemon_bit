
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/mixins/component_isometric.dart';
import 'package:gamestream_flutter/isometric/classes/position.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/debug/debug_tab.dart';
import 'package:gamestream_flutter/library.dart';

class IsometricDebug with IsometricComponent {
  final tab = Watch(DebugTab.Selected);
  final health = Watch(0);
  final healthMax = Watch(0);
  final radius = Watch(0);
  final position = Position();
  final characterSelectedAIDecision = Watch(CaptureTheFlagAIDecision.Idle);
  final characterSelectedAIRole = Watch(CaptureTheFlagAIRole.Defense);
  final destinationX = Watch(0.0);
  final destinationY = Watch(0.0);
  final x = Watch(0.0);
  final y = Watch(0.0);
  final z = Watch(0.0);
  final team = Watch(0);
  final runTimeType = Watch('');
  final path = Uint16List(500);
  final pathIndex = Watch(0);
  final pathEnd = Watch(0);
  final characterAction = Watch(0);
  final goal = Watch(0);
  final pathTargetIndex = Watch(0);
  final targetSet = Watch(false);
  final targetType = Watch('');
  final targetX = Watch(0.0);
  final targetY = Watch(0.0);
  final targetZ = Watch(0.0);

  final characterType = Watch(0);
  final characterState = Watch(0);
  final characterStateDuration = Watch(0);
  final characterStateDurationRemaining = Watch(0);

  final weaponType = Watch(0);
  final weaponDamage = Watch(0);
  final weaponRange = Watch(0);
  final weaponState = Watch(0);
  final weaponStateDuration = Watch(0);
  final autoAttack = Watch(false);
  final pathFindingEnabled = Watch(false);
  final runToDestinationEnabled = Watch(false);
  final arrivedAtDestination = Watch(false);
  final selectedColliderType = Watch(-1);

  final selectedGameObjectType = Watch(-1);
  final selectedGameObjectSubType = Watch(-1);

  late final selectedCollider = Watch(false, onChanged: onChangedCharacterSelected);

  void drawCanvas() {
    if (!isometric.player.debugging.value) return;
    if (!selectedCollider.value) return;

    isometric.engine.setPaintColor(Colors.white);
    isometric.render.circleOutline(
      x.value,
      y.value,
      z.value,
      radius.value.toDouble(),
    );

    isometric.engine.setPaintColor(Colors.green);
    isometric.render.circleOutline(
      x.value,
      y.value,
      z.value,
      weaponRange.value.toDouble(),
    );

    isometric.engine.setPaintColor(Colors.red);
    if (selectedColliderType.value == IsometricType.Character) {
      if (targetSet.value) {
        isometric.render.line(
          x.value,
          y.value,
          z.value,
          targetX.value,
          targetY.value,
          targetZ.value,
        );
      }

      isometric.engine.setPaintColor(Colors.blue);
      renderPath(
        path: path,
        start: 0,
        end: pathIndex.value,
      );

      isometric.engine.setPaintColor(Colors.yellow);
      renderPath(
        path: path,
        start: pathIndex.value,
        end: pathEnd.value,
      );

      if (!arrivedAtDestination.value){
        isometric.engine.setPaintColor(Colors.deepPurpleAccent);
        isometric.render.line(
          x.value,
          y.value,
          z.value,
          destinationX.value,
          destinationY.value,
          z.value,
        );
      }


      final pathTargetIndexValue = pathTargetIndex.value;
      if (pathTargetIndexValue != -1) {
        final scene = isometric.scene;
        isometric.render.wireFrameBlue(
          scene.getIndexZ(pathTargetIndexValue),
          scene.getIndexRow(pathTargetIndexValue),
          scene.getIndexColumn(pathTargetIndexValue),
        );
      }
    }
  }

  void renderPath({
    required Uint16List path,
    required int start,
    required int end,
  }){
    if (start < 0) return;
    if (end < 0) return;
    final scene = isometric.scene;
    for (var i = start; i < end - 1; i++){
      final a = path[i];
      final b = path[i + 1];
      isometric.engine.drawLine(
        scene.getIndexRenderX(a) + Node_Size_Half,
        scene.getIndexRenderY(a) + Node_Size_Half,
        scene.getIndexRenderX(b) + Node_Size_Half,
        scene.getIndexRenderY(b) + Node_Size_Half,
      );
    }
  }

  void onChangedCharacterSelected(bool characterSelected){
    if (!isometric.player.debugging.value)
      return;

     if (characterSelected){
       isometric.camera.target = position;
     } else {
       isometric.camera.target = null;
     }
  }

  void onMouseLeftClicked() => network.sendIsometricRequestDebugSelect();

  void onMouseRightClicked() {
    if (isometric.engine.keyPressedShiftLeft){
      network.sendIsometricRequestDebugAttack();
      return;
    }
    network.sendIsometricRequestDebugCommand();
  }

  void onKeyPressed(int key){
    if (key == KeyCode.G) {
      network.sendIsometricRequestMoveSelectedColliderToMouse();
      return;
    }
  }

  void onChangedEnabled(bool enabled){
      if (enabled){
        isometric.camera.target = null;
      } else {
        action.cameraTargetPlayer();
      }
  }
}