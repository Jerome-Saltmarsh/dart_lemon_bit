
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_character.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';
import 'package:gamestream_flutter/ui.dart';
import 'package:gamestream_flutter/library.dart';

import 'isometric_render.dart';

class IsometricDebug {
  final character = IsometricCharacter();
  final characterSelected = Watch(false);
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
  final targetSet = Watch(false);
  final targetType = Watch('');
  final targetX = Watch(0.0);
  final targetY = Watch(0.0);
  final targetZ = Watch(0.0);

  final characterState = Watch(0);
  final characterStateDuration = Watch(0);
  final characterStateDurationRemaining = Watch(0);

  final weaponType = Watch(0);
  final weaponDamage = Watch(0);
  final weaponRange = Watch(0);
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
              buildWatchString(text: 'type', watch: runTimeType),
              buildWatchDouble(text: 'x', watch: x, ),
              buildWatchDouble(text: 'y', watch: y),
              buildWatchDouble(text: 'z', watch: z),
              buildWatchInt(text: 'path-index', watch: pathIndex),
              buildWatchInt(text: 'path-end', watch: pathEnd),
              buildRow(text: 'character-state', value: buildWatch(characterState, (t) => buildText(CharacterState.getName(t)))),
              buildWatchInt(text: 'character-state-duration', watch: characterStateDuration),
              buildWatchInt(text: 'character-state-duration-remaining', watch: characterStateDurationRemaining),
              buildRow(text: 'weapon-type', value: buildWatch(weaponType, (t) => buildText(ItemType.getName(t)))),
              buildWatchInt(text: 'weapon-damage', watch: weaponDamage),
              buildWatchInt(text: 'weapon-range', watch: weaponRange),
              buildRow(text: 'weapon-state', value: buildWatch(weaponState, (t) => buildText(WeaponState.getName(t)))),
              buildWatchInt(text: 'weapon-state-duration', watch: weaponStateDuration),
              buildTarget(),
            ],
          ),
        ));

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

  static Widget buildRow({required String text, required Widget value}) => Container(
    margin: const EdgeInsets.only(bottom: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildValue(buildText(text), color: Colors.black12),
        buildValue(value),
      ],
    ),
  );

  static Widget buildValue(Widget child, {Color color = Colors.white12}) => Container(
      width: 140,
      alignment: Alignment.centerLeft,
      color: color,
      padding: const EdgeInsets.all(4),
      child: FittedBox(child: child),
    );

  Widget buildTarget(){

   final columnSet = Column(
     children: [
       buildWatchString(text: 'target-type', watch: targetType),
       buildWatchDouble(text: 'target-x', watch: targetX),
       buildWatchDouble(text: 'target-y', watch: targetY),
       buildWatchDouble(text: 'target-z', watch: targetZ),
     ],
   );

   final notSet = Column(
     children: [
       buildRow(text: 'target-type', value: buildText('-')),
       buildRow(text: 'target-x', value: buildText('-')),
       buildRow(text: 'target-y', value: buildText('-')),
       buildRow(text: 'target-z', value: buildText('-')),
     ],
   );

    return WatchBuilder(targetSet, (targetSet) => targetSet ? columnSet : notSet);
  }
}