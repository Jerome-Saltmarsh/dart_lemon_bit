
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_character.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';
import 'package:gamestream_flutter/ui.dart';
import 'package:gamestream_flutter/library.dart';

import 'isometric_render.dart';

class IsometricDebug {
  final character = IsometricCharacter();
  final characterSelected = Watch(false);
  final characterSelectedIsAI = Watch(false);
  final characterSelectedAIDecision = Watch(CaptureTheFlagAIDecision.Idle);
  final characterSelectedAIRole = Watch(CaptureTheFlagAIRole.Defense);
  final characterSelectedDestinationX = Watch(0.0);
  final characterSelectedDestinationY = Watch(0.0);
  final characterSelectedX = Watch(0.0);
  final characterSelectedY = Watch(0.0);
  final characterSelectedZ = Watch(0.0);
  final characterSelectedRuntimeType = Watch('');
  final characterSelectedPath = Uint16List(500);
  final characterSelectedPathIndex = Watch(0);
  final characterSelectedPathEnd = Watch(0);
  final characterSelectedPathRender = WatchBool(true);
  final characterSelectedTarget = Watch(false);
  final characterSelectedTargetType = Watch('');
  final characterSelectedTargetX = Watch(0.0);
  final characterSelectedTargetY = Watch(0.0);
  final characterSelectedTargetZ = Watch(0.0);
  final characterSelectedTargetRenderLine = WatchBool(true);

  final weaponType = Watch(0);
  final weaponState = Watch(0);
  final weaponStateDuration = Watch(0);

  Isometric get isometric => gamestream.isometric;

  Widget buildUI() =>
      WatchBuilder(characterSelected, (characterSelected) => !characterSelected ? nothing :
        GSContainer(
          width: 320,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildText('DEBUG'),
                  onPressed(
                      action: () => isometric.camera.target = character,
                      child: buildText('CAMERA TRACK')
                  ),
                ],
              ),
              height8,
              buildWatchString(watch: characterSelectedRuntimeType, text: 'type'),
              height2,
              buildWatchDouble(watch: characterSelectedX, text: 'x'),
              height2,
              buildWatchDouble(watch: characterSelectedY, text: 'y'),
              height2,
              buildWatchDouble(watch: characterSelectedZ, text: 'z'),
              height2,
              buildWatchInt(watch: characterSelectedPathIndex, text: 'path-index'),
              height2,
              buildWatchInt(watch: characterSelectedPathEnd, text: 'path-end'),
              height2,
              buildRow(text: 'weapon-type', value: buildWatch(weaponType, (t) => buildText(ItemType.getName(t)))),
              height2,
              buildRow(text: 'weapon-state', value: buildWatch(weaponState, (t) => buildText(WeaponState.getName(t)))),
              height2,
              buildWatchInt(text: 'weapon-state-duration', watch: weaponStateDuration),
              height2,
              WatchBuilder(characterSelectedTarget, (characterSelectedTarget){
                if (!characterSelectedTarget) return nothing;
                return Container(
                  color: Colors.white12,
                  padding: GameStyle.Container_Padding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildText('TARGET'),
                      WatchBuilder(characterSelectedTargetType, (type) => buildText('type: $type')),
                      WatchBuilder(characterSelectedTargetX, (x) => buildText('x: ${x.toInt()}')),
                      WatchBuilder(characterSelectedTargetY, (y) => buildText('y: ${y.toInt()}')),
                      WatchBuilder(characterSelectedTargetZ, (z) => buildText('z: ${z.toInt()}')),
                    ],
                  ),
                );
              }),
            ],
          ),
        ));

  void render(IsometricRender renderer) {
    if (!characterSelected.value) return;

    renderer.renderCircle(
      characterSelectedX.value,
      characterSelectedY.value,
      characterSelectedZ.value,
      40,
    );

    if (characterSelectedTarget.value &&
        characterSelectedTargetRenderLine.value
    ) {
      renderer.renderLine(
        characterSelectedX.value,
        characterSelectedY.value,
        characterSelectedZ.value,
        characterSelectedTargetX.value,
        characterSelectedTargetY.value,
        characterSelectedTargetZ.value,
      );
    }

    if (characterSelectedPathRender.value ){
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
    renderer.renderLine(
      characterSelectedX.value,
      characterSelectedY.value,
      characterSelectedZ.value,
      characterSelectedDestinationX.value,
      characterSelectedDestinationY.value,
      characterSelectedZ.value,
    );
  }

  void renderPath({required Uint16List path, required int start, required int end}){
    if (start < 0) return;
    if (end < 0) return;
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

  static Widget buildWatchDouble({
    required Watch<double> watch,
    required String text,
  }) => buildRow(
      text: text,
      value: WatchBuilder(watch, (x) => buildText(x.toInt())),
  );

  static Widget buildWatchInt({
    required Watch<int> watch,
    required String text,
  }) => buildRow(text: text, value: WatchBuilder(watch, buildText));

  static Widget buildWatchString({
    required String text,
    required Watch<String> watch,
  }) => buildRow(text: text, value: WatchBuilder(watch, buildText));

  static Widget buildRow({required String text, required Widget value}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      buildText(text),
      buildValue(value),
    ],
  );

  static Widget buildValue(Widget child) => Container(
      width: 120,
      alignment: Alignment.center,
      color: Colors.white12,
      padding: const EdgeInsets.all(4),
      child: FittedBox(child: child),
    );
}