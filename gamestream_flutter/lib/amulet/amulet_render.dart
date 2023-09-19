
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/amulet/amulet.dart';
import 'package:gamestream_flutter/packages/common.dart';

extension AmuletRender on Amulet {

  void renderAmulet(Canvas canvas, Size size) {
    renderPlayerHoverItemRange();
    renderPlayerRunLine();
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
    if (item.range <= 0) return;
    engine.color = Colors.white;
    render.circleOutline(
        x: player.x,
        y: player.y,
        z: player.z,
        radius: item.range,
        sections: 20
    );
  }

  void renderActivatedPower({Color rangeColor = Colors.white}) {
    if (activatedPowerIndex.value == -1)
      return;

    final activatedPower = weapons[activatedPowerIndex.value].item.value;

    if (activatedPower == null)
      return;

    final mode = activatedPower.attackType?.mode;
    if (mode == AmuletPowerMode.Positional) {
      engine.color = Colors.white;
      render.circleOutlineAtPosition(
        position: activePowerPosition,
        radius: 15,
      );
    }

    engine.color = rangeColor;
    renderCircleAroundPlayer(radius: activatedPower.range);
  }

  void renderCircleAroundPlayer({required double radius}) =>
      render.circleOutlineAtPosition(
        position: player.position,
        radius: radius,
      );
}

