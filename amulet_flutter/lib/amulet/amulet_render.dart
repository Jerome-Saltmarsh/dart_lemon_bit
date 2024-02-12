
import 'package:flutter/material.dart';
import 'package:amulet_flutter/amulet/amulet.dart';
import 'package:amulet_engine/packages/common.dart';

extension AmuletRender on Amulet {

  void renderAmulet(Canvas canvas, Size size) {
    renderPlayerHoverItemRange();

    if (options.renderRunLine){
      renderPlayerRunLine();
    }

    renderActivatedPower();
  }

  void renderPlayerRunLine({Color color = Colors.purple}) {
    if (player.arrivedAtDestination.value)
      return;

    engine.color = color;
    render.line(
      player.x,
      player.y,
      player.z,
      player.runX,
      player.runY,
      player.runZ,
    );
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

    final range = item.range ?? 0;

    if (range <= 0) return;
    engine.color = Colors.white;
    render.circleOutline(
        x: player.x,
        y: player.y,
        z: player.z,
        radius: range,
        sections: 20
    );
  }

  void renderActivatedPower({Color rangeColor = Colors.white}) {

    final activeSlotAmuletItem = activeAmuletItemSlot?.value;

    if (activeSlotAmuletItem == null) {
      return;
    }

    final skillType = activeSlotAmuletItem.skillType;

    if (skillType == null){
      return;
    }

    // final radius = activeSlotAmuletItem.radius;

    // if (radius != null) {
    //   engine.color = Colors.white;
    //   render.circleOutlineAtPosition(
    //     position: activePowerPosition,
    //     radius: radius,
    //   );
    // }

    final range = activeSlotAmuletItem.range;
    if (range != null) {
      engine.color = rangeColor;
      renderCircleAroundPlayer(radius: range);
    }

    engine.color = Colors.white;
  }

  void renderCircleAroundPlayer({required double radius}) =>
      render.circleOutlineAtPosition(
        position: player.position,
        radius: radius,
      );
}

