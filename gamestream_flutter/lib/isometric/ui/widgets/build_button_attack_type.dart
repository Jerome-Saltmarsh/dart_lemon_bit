
import 'dart:math';

import 'package:bleed_common/attack_type.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/classes/player.dart';
import 'package:gamestream_flutter/isometric/ui/functions/render_atlas_src.dart';
import 'package:gamestream_flutter/isometric/ui/maps/map_attack_type_to_atlas_src.dart';
import 'package:lemon_engine/render_single_atlas.dart';
import 'package:lemon_engine/state/atlas.dart';
import 'package:lemon_engine/state/paint.dart';

Widget buildWidgetAttackSlot(AttackSlot slot) {

  return watch(slot.attackType, (int attackType) {
    return watch(slot.capacity, (int capacity) {
      return watch(slot.rounds, (int rounds) {

        final atlasSrc = mapAttackTypeToAtlasSrc[attackType];

        if (atlasSrc == null)
          throw Exception("Could not find atlas src for attack type $attackType: ${AttackType.getName(attackType)}");

        return Container(
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle
          ),
          width: 64,
          height: 64,
          child: renderAttackSlot(
            srcX: atlasSrc.srcX,
            srcY: atlasSrc.srcY,
            srcWidth: atlasSrc.width,
            srcHeight: atlasSrc.height,
          ),
        );
      });
    });
  });
}

Widget renderAttackSlot({
  required double srcX,
  required double srcY,
  required double srcWidth,
  required double srcHeight,
  double scale = 1.0,
}) =>
    Container(
      alignment: Alignment.center,
      width: srcWidth,
      height: srcHeight,
      child: buildCanvas(
          paint: (Canvas canvas, Size size) {

            final previousColor = paint.color;
            paint.color = Colors.red;
            canvas.drawArc(
                Rect.fromCenter(center: Offset(0,0), width: 64, height: 64),
                0, pi, true, paint);
            paint.color = previousColor;

            canvasRenderAtlas(
              canvas: canvas,
              atlas: atlas,
              srcX: srcX,
              srcY: srcY,
              srcWidth: srcWidth,
              srcHeight: srcHeight,
              dstX: 0,
              dstY: 0,
              scale: scale,
            );
          }
      ),
    );
