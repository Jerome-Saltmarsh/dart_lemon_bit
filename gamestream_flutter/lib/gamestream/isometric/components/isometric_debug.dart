
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';
import 'package:gamestream_flutter/ui.dart';
import 'package:gamestream_flutter/library.dart';

class IsometricDebug {
  final characterSelected = Watch(false);
  final characterSelectedIsAI = Watch(false);
  final characterSelectedAIDecision = Watch(CaptureTheFlagAIDecision.Idle);
  final characterSelectedAIRole = Watch(CaptureTheFlagAIRole.Defense);
  final characterSelectedDestinationX = Watch(0.0);
  final characterSelectedDestinationY = Watch(0.0);
  final characterSelectedX = Watch(0.0);
  final characterSelectedY = Watch(0.0);
  final characterSelectedZ = Watch(0.0);
  final characterSelectedRuntimeType = Watch("");
  final characterSelectedPath = Uint16List(500);
  final characterSelectedPathIndex = Watch(0);
  final characterSelectedPathEnd = Watch(0);
  final characterSelectedPathRender = WatchBool(true);
  final characterSelectedTarget = Watch(false);
  final characterSelectedTargetType = Watch("");
  final characterSelectedTargetX = Watch(0.0);
  final characterSelectedTargetY = Watch(0.0);
  final characterSelectedTargetZ = Watch(0.0);
  final characterSelectedTargetRenderLine = WatchBool(true);

  Isometric get isometric => gamestream.isometric;

  Widget buildWindowSelectedCharacter() =>
      WatchBuilder(characterSelected, (characterSelected){
        if (!characterSelected) return nothing;
        return Container(
          width: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WatchBuilder(characterSelectedRuntimeType, (runtimeType) => buildText("type: $runtimeType")),
              WatchBuilder(characterSelectedX, (x) => buildText("position-x: ${x.toInt()}")),
              WatchBuilder(characterSelectedY, (y) => buildText("position-y: ${y.toInt()}")),
              WatchBuilder(characterSelectedZ, (z) => buildText("position-z: ${z.toInt()}")),
              WatchBuilder(characterSelectedPathIndex, (pathIndex) => buildText("path-index: $pathIndex")),
              WatchBuilder(characterSelectedPathEnd, (pathEnd) => buildText("path-end: $pathEnd")),
              WatchBuilder(characterSelectedIsAI, (isAI) => !isAI ? nothing : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WatchBuilder(characterSelectedAIDecision, (decision) => buildText("ai-decision: ${decision.name}")),
                  // onPressed(
                  //     action: toggleSelectedCharacterAIRole,
                  //     child: WatchBuilder(characterSelectedAIRole, (role) => buildText("ai-role: ${role.name}"))),
                  // onPressed(
                  //     action: debugSelectAI,
                  //     child: buildText("DEBUG")),
                ],
              )),
              const SizedBox(height: 1,),
              WatchBuilder(characterSelectedTarget, (characterSelectedTarget){
                if (!characterSelectedTarget) return nothing;
                return Container(
                  color: Colors.white12,
                  padding: GameStyle.Container_Padding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildText("TARGET"),
                      WatchBuilder(characterSelectedTargetType, (type) => buildText("type: $type")),
                      WatchBuilder(characterSelectedTargetX, (x) => buildText("x: ${x.toInt()}")),
                      WatchBuilder(characterSelectedTargetY, (y) => buildText("y: ${y.toInt()}")),
                      WatchBuilder(characterSelectedTargetZ, (z) => buildText("z: ${z.toInt()}")),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      });

  void renderCharacterSelected() {
    isometric.renderer.renderCircle(
      characterSelectedX.value,
      characterSelectedY.value,
      characterSelectedZ.value,
      40,
    );

    if (characterSelectedTarget.value &&
        characterSelectedTargetRenderLine.value
    ) {
      isometric.renderer.renderLine(
        characterSelectedX.value,
        characterSelectedY.value,
        characterSelectedZ.value,
        characterSelectedTargetX.value,
        characterSelectedTargetY.value,
        characterSelectedTargetZ.value,
      );
    }

    if (characterSelectedPathRender.value){
      engine.setPaintColor(Colors.blue);
      renderPath(
        path: characterSelectedPath,
        start: 0,
        end: characterSelectedPathIndex.value,
      );

      engine.setPaintColor(Colors.yellow);
      renderPath(
        path: characterSelectedPath,
        start: characterSelectedPathIndex.value,
        end: characterSelectedPathEnd.value,
      );
    }

    engine.setPaintColor(Colors.deepPurpleAccent);
    isometric.renderer.renderLine(
      characterSelectedX.value,
      characterSelectedY.value,
      characterSelectedZ.value,
      characterSelectedDestinationX.value,
      characterSelectedDestinationY.value,
      characterSelectedZ.value,
    );
  }


  void renderPath({required Uint16List path, required int start, required int end}){
    final nodes = gamestream.isometric.nodes;
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


}