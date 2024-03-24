
import 'package:amulet_common/src.dart';
import 'package:flutter/material.dart';
import 'package:amulet_client/classes/amulet.dart';

extension AmuletRender on Amulet {

  void renderAmulet(Canvas canvas, Size size) {
    renderPlayerHoverItemRange();

    if (amulet.playerDebugEnabled.value){
      renderDebugLines();
      renderDebugPathLines();
    }
  }

  void renderPlayerHoverItemRange() {
    final item = aimTargetItemTypeCurrent.value;
    if (item == null) return;
    renderPlayerItemRange(item);
  }

  void renderPlayerItemRange(AmuletItem item) {
    // final level = amulet.getAmuletPlayerItemLevel(item);
    // final stats = item.getStatsForLevel(level);

    // if (stats == null){
    //   return;
    // }

    // final range = item.range ?? 0;
    //
    // if (range <= 0) return;
    // engine.color = Colors.white;
    // render.circleOutline(
    //     x: player.x,
    //     y: player.y,
    //     z: player.z,
    //     radius: range,
    //     sections: 20
    // );
  }

  // void renderActivatedPower({Color rangeColor = Colors.white}) {
  //
  //   final activeSlotAmuletItem = activeAmuletItemSlot?.value;
  //
  //   if (activeSlotAmuletItem == null) {
  //     return;
  //   }
  //
  //   final skillType = activeSlotAmuletItem.skillType;
  //
  //   if (skillType == null){
  //     return;
  //   }
  //
  //   // final radius = activeSlotAmuletItem.radius;
  //
  //   // if (radius != null) {
  //   //   engine.color = Colors.white;
  //   //   render.circleOutlineAtPosition(
  //   //     position: activePowerPosition,
  //   //     radius: radius,
  //   //   );
  //   // }
  //
  //   // final range = activeSlotAmuletItem.range;
  //   // if (range != null) {
  //   //   engine.color = rangeColor;
  //   //   renderCircleAroundPlayer(radius: range);
  //   // }
  //
  //   // engine.color = Colors.white;
  // }

  void renderCircleAroundPlayer({required double radius}) =>
      render.circleOutlineAtPosition(
        position: player.position,
        radius: radius,
      );

  void renderDebugLines() {

    final total = amulet.debugLinesTotal;
    final debugLines = amulet.debugLines;
    for (var i = 0; i < total; i++) {
       final j = i * 6;
       if (debugLinePerceptable[i]){
         engine.setPaintColor(Colors.green);
       } else {
         engine.setPaintColor(Colors.red);
       }
       render.line(
           debugLines[j + 0].toDouble(),
           debugLines[j + 1].toDouble(),
           debugLines[j + 2].toDouble(),
           debugLines[j + 3].toDouble(),
           debugLines[j + 4].toDouble(),
           debugLines[j + 5].toDouble(),
       );
    }
  }

  void renderDebugPathLines() {
    engine.setPaintColor(Colors.purple);

    final total = amulet.debugPathLinesTotal;
    final lines = amulet.debugPathLines;
    var i = 0;
    while (i < total) {
      final length = lines[i++];
      for (var j = 0; j < length; j++){
         final indexA = lines[i + 0];
         final indexB = lines[i + 1];
         i++;
         render.lineBetweenIndexes(indexA, indexB);
      }
    }
  }
}

