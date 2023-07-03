
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_character.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/debug/debug_tab.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';
import 'package:gamestream_flutter/library.dart';

import '../isometric_render.dart';

class IsometricDebug {
  final enabled = WatchBool(false);
  final tab = Watch(DebugTab.Character);
  final character = IsometricCharacter();
  final characterSelectedAIDecision = Watch(CaptureTheFlagAIDecision.Idle);
  final characterSelectedAIRole = Watch(CaptureTheFlagAIRole.Defense);
  final destinationX = Watch(0.0);
  final destinationY = Watch(0.0);
  final x = Watch(0.0);
  final y = Watch(0.0);
  final z = Watch(0.0);
  final runTimeType = Watch('');
  final path = Uint16List(500);
  final pathIndex = Watch(0);
  final pathEnd = Watch(0);
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

  late final characterSelected = Watch(false, onChanged: onChangedCharacterSelected);

  Isometric get isometric => gamestream.isometric;


  void render(IsometricRender renderer) {
    if (!characterSelected.value) return;

    renderer.renderCircle(
      x.value,
      y.value,
      z.value,
      40,
    );

    if (targetSet.value) {
      renderer.renderLine(
        x.value,
        y.value,
        z.value,
        targetX.value,
        targetY.value,
        targetZ.value,
      );
    }

      engine.setPaintColor(Colors.blue);
      renderPath(
        path: path,
        start: 0,
        end: pathIndex.value,
      );

      engine.setPaintColor(Colors.yellow);
      renderPath(
        path: path,
        start: pathIndex.value,
        end: pathEnd.value,
      );

    engine.setPaintColor(Colors.deepPurpleAccent);
    renderer.renderLine(
      x.value,
      y.value,
      z.value,
      destinationX.value,
      destinationY.value,
      z.value,
    );

    final pathTargetIndexValue = pathTargetIndex.value;
    if (pathTargetIndexValue != -1) {
      final scene = isometric.scene;
      isometric.renderer.renderWireFrameBlue(
          scene.getIndexZ(pathTargetIndexValue),
          scene.getIndexRow(pathTargetIndexValue),
          scene.getIndexColumn(pathTargetIndexValue),
      );
    }
  }

  void renderPath({required Uint16List path, required int start, required int end}){
    if (start < 0) return;
    if (end < 0) return;
    final nodes = gamestream.isometric.scene;
    for (var i = start; i < end - 1; i++){
      final a = path[i];
      final b = path[i + 1];
      engine.drawLine(
        nodes.getIndexRenderX(a),
        nodes.getIndexRenderY(a),
        nodes.getIndexRenderX(b),
        nodes.getIndexRenderY(b),
      );
    }
  }

  void onChangedCharacterSelected(bool characterSelected){
     if (characterSelected){
       isometric.camera.target = character;
     } else {
       isometric.camera.target = isometric.player.position;
       isometric.camera.followTarget.value = true;
     }
  }


}