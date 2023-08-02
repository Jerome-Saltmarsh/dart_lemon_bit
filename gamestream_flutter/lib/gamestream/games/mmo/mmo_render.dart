
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/common/src/isometric/power_mode.dart';
import 'package:gamestream_flutter/common/src/mmo/mmo_item.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_game.dart';

extension MMORender on MmoGame {

  void renderMMO(Canvas canvas, Size size) {
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

  void renderPlayerItemRange(MMOItem item) {
    if (item.range <= 0) return;
    engine.color = Colors.white;
    render.circleOutline(
        player.x,
        player.y,
        player.z,
        item.range,
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
    if (mode == PowerMode.Positional) {
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

