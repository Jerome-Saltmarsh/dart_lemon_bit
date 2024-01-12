
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
    final item = itemHover.value;
    if (item == null) return;
    renderPlayerItemRange(item);
  }

  void renderPlayerItemRange(AmuletItem item) {
    final level = amulet.getAmuletPlayerItemLevel(item);
    final stats = item.getStatsForLevel(level);

    if (stats == null){
      return;
    }

    final range = stats.range;

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

    final activeSlotAmuletItem = activeAmuletItemSlot?.amuletItem.value;

    if (activeSlotAmuletItem == null){
      return;
    }

    final skillType = activeSlotAmuletItem.skillType;

    if (skillType == null){
      return;
    }
    final casteType = skillType.casteType;

    if (casteType == CasteType.Instant){
      return;
    }

    if (casteType == CasteType.Positional) {
      engine.color = Colors.white;
      render.circleOutlineAtPosition(
        position: activePowerPosition,
        radius: 15,
      );
    }

    engine.color = rangeColor;

    final level = amulet.getAmuletPlayerItemLevel(activeSlotAmuletItem);
    final stats = activeSlotAmuletItem.getStatsForLevel(level);

    if (stats == null){
      return;
    }

    renderCircleAroundPlayer(radius: stats.range);
  }

  void renderCircleAroundPlayer({required double radius}) =>
      render.circleOutlineAtPosition(
        position: player.position,
        radius: radius,
      );
}

